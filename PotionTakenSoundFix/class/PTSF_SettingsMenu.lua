if PotionTakenSoundFix == nil then PotionTakenSoundFix = {} end
local PTSF = PotionTakenSoundFix

--=============================================================================================================
-- LibAddonMenu (LAM) Settings panel
--=============================================================================================================
function PTSF.buildAddonMenu()
    if PTSF.addonMenu == nil then return nil end
    --Local "speed up arrays/tables" variables
    local addonVars =       PTSF.addonVars
    local settings =        PTSF.settingsVars.settings
    local defaults =        PTSF.settingsVars.defaults
    
    local lockSoundPlay_Potion 					= false
    local lockSoundPlay_BuffLost				= false
    local lockSoundPlay_Cooldown 				= false
    local toggle_potion_buffs_check_enabled 	= false
    PTSF.panelData    = {
        type                = "panel",
        name                = addonVars.settingsName,
        displayName         = addonVars.settingsDisplayName,
        author              = addonVars.addonAuthor,
        version             = tostring(addonVars.addonRealVersion),
        registerForRefresh  = true,
        registerForDefaults = true,
        slashCommand 		= "/PTSF",
        website             = addonVars.addonWebsite,
        feedback			= addonVars.addonFeedback,
        donation			= addonVars.addonDonate
    }

    local savedVariablesOptions = {
        [1] = "Per character",
        [2] = "Account Wide",
    }

    --Create our buffs list options
    local PotionTakenSoundFix_Settings_Potionbufflostfilters_controls = {}
    if PTSF.buffs then
        for i, buffName in pairs(PTSF.buffs) do
       		PotionTakenSoundFix_Settings_Potionbufflostfilters_controls[i] = { type = "checkbox", name = buffName, tooltip = PTSF.buffs_description[i], getFunc = function() return settings.buffFilters[buffName] end, setFunc = function(value)	if(value) then settings.buffFilters[buffName] = value else settings.buffFilters[buffName] = nil end end, default = false, width = "half", }
        end
    end
--=============================================================================================================
-- updateDisabledControl {{{
--=============================================================================================================
local function updateDisabledControl(control, soundEnded)
    if(soundEnded) then
    	lockSoundPlay_Potion 	= false
    	lockSoundPlay_BuffLost	= false
    	lockSoundPlay_Cooldown 	= false
    end
    if(not control) then
        PTSF.D("No control to update in function updateDisabledControl()!")
        return
    end
    local disable
    if type(control.data.disabled) == "function" then
        disable = control.data.disabled()
    else
        disable = control.data.disabled
    end

    control.slider:SetEnabled(not disable)
    control.slidervalue:SetEditEnabled(not disable)
    if disable then
        control.label:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
        control.minText:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
        control.maxText:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
        control.slidervalue:SetColor(ZO_DEFAULT_DISABLED_MOUSEOVER_COLOR:UnpackRGBA())
    else
        control.label:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
        control.minText:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
        control.maxText:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
        control.slidervalue:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
    end
end --}}}

--=============================================================================================================
-- setControlValues {{{
--=============================================================================================================
local function setControlValues(control, value, doNotPlaySound)
    if(not control) then
        PTSF.D("No control to update in function updateDisabledControl()!")
        return
    end
--    if(control == PotionTakenSoundFix_Settings_potionTakenSound) then --If we're selecting default potion taken sound, volume boost has nothing to do with it so play our "selected" sound
--        control.data.setFunc(value, false)
--    else
        control.data.setFunc(value, doNotPlaySound)
--    end
    control.slider:SetValue(value)
    control.slidervalue:SetText(value)
    --PTSF.addonMenu.util.RequestRefreshIfNeeded(control)
end --}}}

    --=============================================================================================================
    -- Load our custom values into panel {{{
    --=============================================================================================================
    local function addonMenuOnLoadCallback(panel)
        if panel == PTSF.addonMenuPanel then
            --UnRegister the callback for the LAM2 panel created function
            CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", addonMenuOnLoadCallback)
            --Set the text for the selected sounds
            PotionTakenSoundFix_Settings_potionTakenSound.label:SetText("Sound: " .. PTSF.sounds[settings.potionTakenSound])
            PotionTakenSoundFix_Settings_potionLostBuffSound.label:SetText("Sound: " .. PTSF.sounds[settings.potionLostBuffSound])
            PotionTakenSoundFix_Settings_potionCooldownEndedSound.label:SetText("Sound: " .. PTSF.sounds[settings.potionCooldownEndedSound])
            --Set the color on dev's fav buttons
            PotionTakenSoundFix_Settings_devPotionTakenButton.button:SetNormalFontColor(0,0.75,0.61,1) --rgba(0, 191, 156, 255)
            PotionTakenSoundFix_Settings_devPotionLostBuffButton.button:SetNormalFontColor(0,0.75,0.61,1)
            PotionTakenSoundFix_Settings_devPotionCooldownEndedButton.button:SetNormalFontColor(0,0.75,0.61,1)
            --Set the color on volume boost's warning icons
            PotionTakenSoundFix_Settings_potionTakenVolumeBoost.warning:SetColor(1,0.65,0,1)
            PotionTakenSoundFix_Settings_potionLostBuffVolumeBoost.warning:SetColor(1,0.65,0,1)
            PotionTakenSoundFix_Settings_potionCooldownEndedVolumeBoost.warning:SetColor(1,0.65,0,1)
            --Open the buff filters submenu
            if(settings.enableBuffFilter and settings.potionLostBuffSound > 2) then
            	PotionTakenSoundFix_Settings_Potionbufflostfilters.open = true
               	PotionTakenSoundFix_Settings_Potionbufflostfilters.animation:PlayFromEnd()
            end
        end
    end --}}}
    
    --Register the callback for the LAM panel created function
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", addonMenuOnLoadCallback)

    --=============================================================================================================
    -- Options Panel Data {{{
    --=============================================================================================================

    PTSF.optionsData  = {
        {
            type             = "description",
            text              = "|cFFFF00Fixes potion sound to ONLY play when successfully taken.\n"
            					.."Also adds the ability to:\n"
            					.."-Change the potion taken sound\n"
            					.."-Add a custom sound when you lose a potion buff with optional buff filters\n"
            					.."-Add a custom sound when potion cooldown is over (you can take another one)\n"
            					.."-Volume booster for chosen sounds (few ones can't be boosted)|r",
        },
        
        --=============================================================================================================
        -- Save mode {{{
        --=============================================================================================================
        {
            type = 'header',
            name = "Account-wide/per character",
        },
        {
            type = 'dropdown',
            name = "Save as:",
            tooltip = "Save the addon settings per account or for each character",
            choices = savedVariablesOptions,
            getFunc = function() return savedVariablesOptions[PTSF.settingsVars.defaultSettings.saveMode] end,
            setFunc = function(value)
                for i,v in pairs(savedVariablesOptions) do
                    if v == value then
                        PTSF.settingsVars.defaultSettings.saveMode = i
                        ReloadUI()
                    end
                end
            end,
            warning = "CAUTION: Changing the saving mode will cause a reloadui!",
        },
        {
            type = 'description',
            text = "CAUTION: Changing the saving mode will cause a reloadui!",
        }, --}}}

        --=============================================================================================================
        -- Potion Taken {{{
        --=============================================================================================================
        {
            type = 'header',
            name = "Sound to play |l1:1:0:5%:8:FF0000|lONLY|l when a potion is taken",
        },
        {
            type = 'description',
            text = "|cFFFF00You can use the mouse scroll wheel to slide!|r",
        },
        {
            type = 'slider',
            name = "Sound:",
            tooltip = "Plays this sound to confirm your potion has been taken successfully.\n\nSlide to 2 (NONE) if you don't want to hear any sound!",
            min = 1,
            max = #PTSF.sounds,
            getFunc = function()
                return settings.potionTakenSound
            end,
            setFunc = function(idx, doNotPlaySound)
                settings.potionTakenSound = idx
                PotionTakenSoundFix_Settings_potionTakenSound.label:SetText("Sound: " .. PTSF.sounds[idx])
                 if SOUNDS ~= nil then
                    if(idx == 1 and SOUNDS[PTSF.sounds[idx]] == nil) then --Default ESO potion taken sound
                    	PTSF.D("Played: DEFAULT potion sound")
                    	PlayItemSound(ITEM_SOUND_CATEGORY_POTION, ITEM_SOUND_ACTION_USE, true)
                    elseif(idx ~= 2 and SOUNDS[PTSF.sounds[idx]] ~= nil and not doNotPlaySound) then
                    	PTSF.D("Played: "..SOUNDS[PTSF.sounds[settings.potionTakenSound]])
                    	PlaySound(SOUNDS[PTSF.sounds[idx]])
                    end
                 end
            end,
            default = defaults.potionTakenSound,
            reference = "PotionTakenSoundFix_Settings_potionTakenSound",
        },

        {
            type = 'slider',
            name = "Volume Booster",
            tooltip = "Boost this sound's volume by a factor of this slider value\n\n|cFFA500Please see WARNING (triangle)|r",
            min = 1,
            max = 10,
            getFunc = function()
                return settings.potionTakenVolumeBoost
            end,
            setFunc = function(idy)
            settings.potionTakenVolumeBoost = idy
                if(SOUNDS ~= nil and settings.potionTakenSound > 2 and SOUNDS[PTSF.sounds[settings.potionTakenSound]] ~= nil) then
                    for i = 1, idy do
                    	PTSF.D(i.."-LoopPlayed: "..SOUNDS[PTSF.sounds[settings.potionTakenSound]])
                        PlaySound(SOUNDS[PTSF.sounds[settings.potionTakenSound]])
                    end
                    lockSoundPlay_Potion = true
                    zo_callLater(function() updateDisabledControl(PotionTakenSoundFix_Settings_potionTakenVolumeBoost, lockSoundPlay_Potion) end, 1000)
                end
            end,
            disabled = function() return settings.potionTakenSound <= 2 or lockSoundPlay_Potion end,
            default = defaults.potionTakenVolumeBoost,
            warning = "|cFFA500WARNING:|r This is meant to help boost up the volume of softer sounds, but seriously watch your speakers cranking it up on an already loud sound\n\nGenerally speaking, a boost of up to 6 is a lot, please be cautious!",
            reference = "PotionTakenSoundFix_Settings_potionTakenVolumeBoost",
        },
        {
            type = "button",
            name = "Addon's Default",
            tooltip = "Set this addon's default values",
            func = function() setControlValues(PotionTakenSoundFix_Settings_potionTakenSound, PTSF.settingsVars.defaults.potionTakenSound, true) setControlValues(PotionTakenSoundFix_Settings_potionTakenVolumeBoost, PTSF.settingsVars.defaults.potionTakenVolumeBoost) end,
            width = "half",
        },
        {
            type = "button",
            name = "Dev's Fav",
            tooltip = "Set |cFFA500"..addonVars.addonAuthor.."'s|r favorite values",
            func = function() setControlValues(PotionTakenSoundFix_Settings_potionTakenSound, 21, true) setControlValues(PotionTakenSoundFix_Settings_potionTakenVolumeBoost, 2) end,
            width = "half",
            reference = "PotionTakenSoundFix_Settings_devPotionTakenButton",
        }, --}}}

        --=============================================================================================================
        -- Potion Buff Lost {{{
        --=============================================================================================================
        {
            type = 'header',
            name = "Sound when you lose a potion buff",
        },
        {
            type = 'slider',
            name = "Sound:",
            tooltip = "Plays this sound every time you lose a potion buff (Major Intellect, Major Fortitude, Major Endurance, Immovable, etc.)\n\nSlide to 1 (NONE) if you don't want to hear any sound!",
            min = 1,
            max = #PTSF.sounds-1,
            getFunc = function()
                return settings.potionLostBuffSound - 1
            end,
            setFunc = function(idx, doNotPlaySound)
                idx = idx + 1 --Tricking the system so we don't use sound #1 as it's default potion sound
                settings.potionLostBuffSound = idx
                PotionTakenSoundFix_Settings_potionLostBuffSound.label:SetText("Sound: " .. PTSF.sounds[idx])
                --Update our buff list submenu
                if(idx > 2 and settings.enableBuffFilter and not PotionTakenSoundFix_Settings_Potionbufflostfilters.open) then
               		PotionTakenSoundFix_Settings_Potionbufflostfilters.open = true
               		PotionTakenSoundFix_Settings_Potionbufflostfilters.animation:PlayFromEnd()
                end
                 if SOUNDS ~= nil and not doNotPlaySound then
                   if(idx > 2 and SOUNDS[PTSF.sounds[idx]] ~= nil) then
                       PTSF.D("Played: "..SOUNDS[PTSF.sounds[settings.potionLostBuffSound]])
                       PlaySound(SOUNDS[PTSF.sounds[idx]])
                   end
                 end
            end,
            default = defaults.potionLostBuffSound,
            reference = "PotionTakenSoundFix_Settings_potionLostBuffSound",
        },
        {
            type = 'slider',
            name = "Volume Booster",
            tooltip = "Boost this sound's volume by a factor of this slider value\n\n|cFFA500Please see WARNING (triangle)|r",
            min = 1,
            max = 10,
            getFunc = function()
                return settings.potionLostBuffVolumeBoost
            end,
            setFunc = function(idy)
            settings.potionLostBuffVolumeBoost = idy
                if(SOUNDS ~= nil and settings.potionLostBuffSound > 2 and SOUNDS[PTSF.sounds[settings.potionLostBuffSound]] ~= nil) then
                    for i = 1, idy do
                       PTSF.D(i.."-LoopPlayed: "..SOUNDS[PTSF.sounds[settings.potionLostBuffSound]])
                       PlaySound(SOUNDS[PTSF.sounds[settings.potionLostBuffSound]])
                    end
                    lockSoundPlay_BuffLost = true
                    zo_callLater(function() updateDisabledControl(PotionTakenSoundFix_Settings_potionLostBuffVolumeBoost, lockSoundPlay_BuffLost) end, 1000)
                end
            end,
            disabled = function() return settings.potionLostBuffSound <= 2 or lockSoundPlay_BuffLost end,
            default = defaults.potionLostBuffVolumeBoost,
            reference = "PotionTakenSoundFix_Settings_potionLostBuffVolumeBoost",
            warning = "|cFFA500WARNING:|r This is meant to help boost up the volume of softer sounds, but seriously watch your speakers cranking it up on an already loud sound\n\nGenerally speaking, a boost of up to 6 is a lot, please be cautious!",
        },
        {
            type = "button",
            name = "Addon's Default",
            tooltip = "Set this addon's default values",
            func = function() setControlValues(PotionTakenSoundFix_Settings_potionLostBuffSound, PTSF.settingsVars.defaults.potionLostBuffSound, true) setControlValues(PotionTakenSoundFix_Settings_potionLostBuffVolumeBoost, PTSF.settingsVars.defaults.potionLostBuffVolumeBoost) end,
            width = "half",
        },
        {
            type = "button",
            name = "Dev's Fav",
            tooltip = "Set |cFFA500"..addonVars.addonAuthor.."'s|r favorite values",
            func = function() setControlValues(PotionTakenSoundFix_Settings_potionLostBuffSound, 5, true) setControlValues(PotionTakenSoundFix_Settings_potionLostBuffVolumeBoost, 6) end,
            width = "half",
            reference = "PotionTakenSoundFix_Settings_devPotionLostBuffButton",
        },
            {
            	type = "checkbox",
            	name = "Enable Potion buffs filters",
            	tooltip = "Enabling this will play the buff lost sound ONLY for selected buffs",
            	getFunc = function() return settings.enableBuffFilter end,
            	setFunc = function(value)
               		settings.enableBuffFilter = value
               		if(value) then --Open the buff filters submenu
               			PotionTakenSoundFix_Settings_Potionbufflostfilters.open = true
               			PotionTakenSoundFix_Settings_Potionbufflostfilters.animation:PlayFromEnd()
               		end
               	end,
               	disabled = function() return settings.potionLostBuffSound <= 2 end,
               	default = defaults.enableBuffFilter,
               	width = "full",
            },
        {
            type = "submenu",
            name = "Potion buff lost filters",
            tooltip = "Allows filtering lost potion buff sound to play for specific buffs only",
            disabled = function() return not settings.enableBuffFilter or settings.potionLostBuffSound <= 2 end,
            reference = "PotionTakenSoundFix_Settings_Potionbufflostfilters",
            controls = PotionTakenSoundFix_Settings_Potionbufflostfilters_controls,
        }, --submenu

        --=============================================================================================================
        -- Potion Cooldown Ended {{{
        --=============================================================================================================
        {
            type = 'header',
            name = "Sound when potion cooldown is over",
        },
        {
            type = 'slider',
            name = "Sound:",
            tooltip = "Plays this sound when you can take another potion.\n\nSlide to 1 (NONE) if you don't want to hear any sound!",
            min = 1,
            max = #PTSF.sounds-1,
            getFunc = function()
                return settings.potionCooldownEndedSound - 1
            end,
            setFunc = function(idx, doNotPlaySound)
                idx = idx + 1 --Tricking the system so we don't use sound #1 as it's default potion sound
                settings.potionCooldownEndedSound = idx
                PotionTakenSoundFix_Settings_potionCooldownEndedSound.label:SetText("Sound: " .. PTSF.sounds[idx])
                 if SOUNDS ~= nil and not doNotPlaySound then --Minor bug: "Game's restore defaults" will play it twice since it doesn't throw our doNotPlaySound value
                   if(idx > 2 and SOUNDS[PTSF.sounds[idx]] ~= nil) then
                    	PlaySound(SOUNDS[PTSF.sounds[idx]])
                    	PTSF.D("Played: "..SOUNDS[PTSF.sounds[settings.potionCooldownEndedSound]])
                    end
                 end
            end,
            default = defaults.potionCooldownEndedSound,
            reference = "PotionTakenSoundFix_Settings_potionCooldownEndedSound",
        },
        {
            type = 'slider',
            name = "Volume Booster",
            tooltip = "Boost this sound's volume by a factor of this slider value\n\n|cFFA500Please see WARNING (triangle)|r",
            min = 1,
            max = 10,
            getFunc = function()
                return settings.potionCooldownEndedVolumeBoost
            end,
            setFunc = function(idy)
            settings.potionCooldownEndedVolumeBoost = idy
                if(SOUNDS ~= nil and settings.potionCooldownEndedSound > 2 and SOUNDS[PTSF.sounds[settings.potionCooldownEndedSound]] ~= nil) then
                    for i = 1, idy do
                       PTSF.D(i.."-LoopPlayed: "..SOUNDS[PTSF.sounds[settings.potionCooldownEndedSound]])
                       PlaySound(SOUNDS[PTSF.sounds[settings.potionCooldownEndedSound]])
                    end
                    lockSoundPlay_Cooldown = true
                    zo_callLater(function() updateDisabledControl(PotionTakenSoundFix_Settings_potionCooldownEndedVolumeBoost, lockSoundPlay_Cooldown) end, 1000)
                end
            end,
            disabled = function() return settings.potionCooldownEndedSound <= 2 or lockSoundPlay_Cooldown end,
            default = defaults.potionCooldownEndedVolumeBoost,
            reference = "PotionTakenSoundFix_Settings_potionCooldownEndedVolumeBoost",
            warning = "|cFFA500WARNING:|r This is meant to help boost up the volume of softer sounds, but seriously watch your speakers cranking it up on an already loud sound\n\nGenerally speaking, a boost of up to 6 is a lot, please be cautious!",
        },
        {
            type = "button",
            name = "Addon's Default",
            tooltip = "Set this addon's default values",
            func = function() setControlValues(PotionTakenSoundFix_Settings_potionCooldownEndedSound, PTSF.settingsVars.defaults.potionCooldownEndedSound, true) setControlValues(PotionTakenSoundFix_Settings_potionCooldownEndedVolumeBoost, PTSF.settingsVars.defaults.potionCooldownEndedVolumeBoost) end,
            width = "half",
        },
        {
            type = "button",
            name = "Dev's Fav",
            tooltip = "Set |cFFA500"..addonVars.addonAuthor.."'s|r favorite values",
            func = function() setControlValues(PotionTakenSoundFix_Settings_potionCooldownEndedSound, 26, true) setControlValues(PotionTakenSoundFix_Settings_potionCooldownEndedVolumeBoost, 4) end,
            width = "half",
            reference = "PotionTakenSoundFix_Settings_devPotionCooldownEndedButton",
        }, --}}}
        --=============================================================================================================
        -- Debug {{{
        --=============================================================================================================
        {
        	type = "divider",
        	width = "full",
        	height = 40,
        	alpha = 1,
        },
        {
            type = "submenu",
            name = "Debug",
            tooltip = "Debug options, use if requested. None of those options are permanent (They don't save when reloading the game or between reloadui)",
            controls = {
            {
            	type = "checkbox",
            	name = "Master switch",
            	tooltip = "Turn off this addon's functionalities (sound fix along with custom sounds etc).",
            	getFunc = function() return PTSF.masterSwitch end,
            	setFunc = function(value)
               		PTSF.masterSwitch = value
               		if (value) then --only preHook is kept
               			PTSF.libPB:RegisterAbilityIdsFilterOnEventEffectChanged(PTSF.addonVars.addonName, PTSF_potTaken, REGISTER_FILTER_UNIT_TAG, "player")
               			PTSF.DG("Master Switch is |c00FF00ON|r")
               		else
               			PTSF.libPB:UnRegisterAbilityIdsFilterOnEventEffectChanged(PTSF.addonVars.addonName)
               			PTSF.D("Master Switch is |cFF0000OFF|r (default sound without fix will play)", true)
               		end
               	end,
               	default = true,
               	width = "half",
            },
            {
            	type = "checkbox",
            	name = "Unknown Potion Buffs Finder",
            	tooltip = "Debug option, use if requested. Activating this will display potion buffs in chat by using an alternative way of tracking potion buffs.\n\n"
            			.."INSTRUCTIONS:\n"
            			.."If you have no potion taken sound and/or no lost buff sound for a specific potion,\n"
            			.."1- Enable this option and please let your buffs run out and don't re-buff yourself with any ability\n"
            			.."2- Use that specific potion, you'll see debug lines in chat\n"
            			.."3- Click on the potion link to show which potion it is and ideally take a screen shot of the chat lines along with the potion tooltip\n"
            			.."4- Post the screen shot on ESOUI, you can use the 'feedback' button up top of this options' menu\n"
            			.."5- You can now disable this option and wait for a fix\n\n"
            			.."Thank you!",
            	getFunc = function() return toggle_potion_buffs_check_enabled end,
            	setFunc = function(value)
                	toggle_potion_buffs_check_enabled = value
                	PTSF_toggle_potion_buffs_check(value)
                end,
                default = toggle_potion_buffs_check_enabled,
                width = "half",
            },
            }, --controls
        }, --submenu
    } --}}}
    PTSF.addonMenuPanel = PTSF.addonMenu:RegisterAddonPanel("PotionTakenSoundFix_SettingsMenu", PTSF.panelData)
    PTSF.addonMenu:RegisterOptionControls("PotionTakenSoundFix_SettingsMenu", PTSF.optionsData)

    PTSF.addonMenu.isBuilt = true
end

