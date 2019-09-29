if PotionTakenSoundFix == nil then PotionTakenSoundFix = {} end
local PTSF = PotionTakenSoundFix
--=============================================================================================================
-- Addon info {{{
--=============================================================================================================

PTSF.addonVars =  {}
PTSF.addonVars.addonRealVersion			= 1.00
PTSF.addonVars.addonSavedVarsVersion	= 1.00
PTSF.addonVars.addonName				= "PotionTakenSoundFix"
PTSF.addonVars.addonSavedVars			= "PotionTakenSoundFix_Settings"
PTSF.addonVars.settingsName   			= "Potion Taken Sound Fix"
PTSF.addonVars.settingsDisplayName   	= "|cFF0000Potion Taken|r|l0:1:0:5%:2:FF0000|l Sound Fix|l"
PTSF.addonVars.addonAuthor				= "|c00BF9CTrader08|r"
PTSF.addonVars.addonWebsite				= ""
PTSF.addonVars.addonFeedback			= ""
PTSF.addonVars.addonDonate				= "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=MGLYRE7N8VTEN&item_name=Support+this+addon+by+buying+me+a+skooma%21&currency_code=USD&source=url"

-- Debug
PTSF.debug				= false
--}}}

--=============================================================================================================
-- Libraries {{{
--=============================================================================================================

--LibPotionBuff
local libPB = LibPotionBuff
if libPB == nil and LibStub then libPB = LibStub:GetLibrary("LibPotionBuff") end
PTSF.libPB = libPB
--LibAddonMenu-2.0
PTSF.addonMenu = LibAddonMenu2
if PTSF.addonMenu == nil and LibStub then PTSF.addonMenu = LibStub:GetLibrary("LibAddonMenu-2.0") end
--}}}

--=============================================================================================================
--	Local variables {{{
--=============================================================================================================

local settings = PTSF.settingsVars.settings
local defaults = PTSF.settingsVars.defaults

local eventRegistered = false
local potionCooldown_ms = 0

--local userInterfaceVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME))

local isPlayingPotionTaken 			= false --The 3 "isPlaying" are locks to prevent mutliple calls
local isPlayingPotionLostBuff		= false --Because the event is called for every buff given/lost by the potion
local isPlayingPotionCooldownEnded	= false --This way we make sure we're not calling sound over sound
local PlaySoundLockDelay			= 1000	 --1000ms delay should be enough yet accurate
--}}}

--=============================================================================================================
--	Addon Loaded {{{
--=============================================================================================================

local function PTSF_addonLoaded(eventName, addon)
	if addon ~= PTSF.addonVars.addonName then return end
	if eventRegistered then PTSF.D("Event already Registered") return end
	
	--Load the SavedVariables settings
	PTSF.loadSettings()

    settings = PTSF.settingsVars.settings
    defaults = PTSF.settingsVars.defaults
	
	EVENT_MANAGER:UnregisterForEvent(eventName)
	
	--Update user's UI volume
--	userInterfaceVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME)) --tempo
	
	libPB:RegisterAbilityIdsFilterOnEventEffectChanged(PTSF.addonVars.addonName, PTSF_potTaken, REGISTER_FILTER_UNIT_TAG, "player") --Only on self (player)
	PTSF.D("Loaded successfully")
	eventRegistered = true
	
end --}}}

--=============================================================================================================
--	Some prehook magic {{{
--=============================================================================================================

local function PTSF_PlayItemSound_Hook(sound, action, force)
    PTSF.D("PTSF_PlayItemSound_Hook sound="..sound.." action="..action.." force="..tostring(force).." potionCooldown_ms="..potionCooldown_ms)
    if(sound == ITEM_SOUND_CATEGORY_POTION and action == ITEM_SOUND_ACTION_USE and not force) then
    	return true --We handle the function call ourselves (Original sound won't play)
    end
    return false --Let thru everything else (all other sounds)
end

local function PTSF_Hook_functions()
	--preHook PlayItemSound function
    ZO_PreHook("PlayItemSound", PTSF_PlayItemSound_Hook)
end --}}}

--=============================================================================================================
--	Player Activated (load hooks and build addon menu) {{{
--=============================================================================================================

function PTSF_Player_Activated(...)
	--Prevent this event to be fired over and over on zone changes
	EVENT_MANAGER:UnregisterForEvent(PTSF.addonVars.addonName, EVENT_PLAYER_ACTIVATED)

	--Load the hooks
	PTSF_Hook_functions()
	
	--Build addon Menu
	if not PTSF.addonMenu.isBuilt then
	    PTSF.buildAddonMenu()
	end
end --}}}

--=============================================================================================================
--	Potion Taken handler {{{
--=============================================================================================================

function PTSF_potTaken(arg1, arg2, arg3, arg4, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22)
	PTSF.D("arg1="..tostring(arg1).." arg2="..tostring(arg2).." arg3="..tostring(arg3).." arg4="..tostring(arg4).." arg5="..tostring(arg5).." arg6="..tostring(arg6).." arg7="..tostring(arg7).." arg8="..tostring(arg8).." arg9="..tostring(arg9)
	.." arg10="..tostring(arg10).." arg11="..tostring(arg11).." arg12="..tostring(arg12).." arg13="..tostring(arg13).." arg14="..tostring(arg14).." arg15="..tostring(arg15).." arg16="..tostring(arg16).." arg17="..tostring(arg17).." arg18="..tostring(arg18).." arg19="..tostring(arg19)
	.." arg20="..tostring(arg20).." arg21="..tostring(arg21).." arg22="..tostring(arg22))
	if(arg6 ~= "player") then
	     PTSF.D("PTSF_potTaken triggered not on player")
	end
	if(arg6 == "player" and arg7 > 0 and arg8 > 0) then --arg7 and arg8 always return a float value when we just took a potion. Else they return no value or 0 and it's called when pot buffs run out
	    --PTSF.DecreaseUIVolume()
	    potionCooldown_ms = libPB:GetPotionSlotCooldown(PTSF.debug) --potion cooldown from currently selected quickslot
        PTSF.PlaySound("potionTaken")
	    
	    --Since we can know the potion duration from the currently selected quickslot and we know we just took a potion and had to be doing it from a quickslot, assume we got the cooldown right.
	    --So we're delay calling the "potion cooldown ended" sound after that said cooldown
	    zo_callLater(function() PTSF.PlaySound("potionCooldownEnded") end, potionCooldown_ms) --PlaySound(SOUNDS.ALCHEMY_CREATE_TOOLTIP_GLOW_SUCCESS)

	elseif(arg6 == "player") then --Any potion Buff lost
	    PTSF.PlaySound("potionLostBuff")
	end
end --}}}

--=============================================================================================================
--	Our PlaySound function {{{
--=============================================================================================================

function PTSF.PlaySound(category)
	if (SOUNDS == nil) then return end
	local sound
	local volume
	-- PotionTaken {{{
	if (category == "potionTaken") then
	 	if(isPlayingPotionTaken) then return end
		isPlayingPotionTaken = true
		zo_callLater(function() isPlayingPotionTaken = false end, PlaySoundLockDelay)
	    PTSF.D("PlaySound category is "..category)
		if(settings.potionTakenSound > 2 and SOUNDS[PTSF.sounds[settings.potionTakenSound]]) then -- ~= nil
			sound = SOUNDS[PTSF.sounds[settings.potionTakenSound]]
			volume = settings.potionTakenVolumeBoost
			PTSF.D("PlaySound sound="..sound.." volume="..volume)
		elseif(settings.potionTakenSound == 2) then
		    PTSF.D("PlaySound sound is muted")
			return --No sound to play
		else --Defaults to game's potion taken sound
			sound = "DEFAULT"
			volume = 1
			PTSF.D("PlaySound sound="..sound.." volume="..volume)
		end --}}}
	-- potionLostBuff {{{
	elseif(category == "potionLostBuff") then
	  	if(isPlayingPotionLostBuff) then return end
	 	isPlayingPotionLostBuff = true
	 	zo_callLater(function() isPlayingPotionLostBuff = false end, PlaySoundLockDelay)
	    PTSF.D("PlaySound category is "..category)
		if(settings.potionLostBuffSound > 1 and SOUNDS[PTSF.sounds[settings.potionLostBuffSound]]) then -- ~= nil
			sound = SOUNDS[PTSF.sounds[settings.potionLostBuffSound]]
			volume = settings.potionLostBuffVolumeBoost
			PTSF.D("PlaySound sound="..sound.." volume="..volume)
		elseif(settings.potionLostBuffSound == 1) then
		    PTSF.D("PlaySound sound is muted")
			return --No sound to play
		else
			PTSF.D("PlaySound didn't find any sound to play (code: 5001)")
		end	 --}}}
	-- potionCooldownEnded {{{
	elseif(category == "potionCooldownEnded") then
		if(isPlayingPotionCooldownEnded) then return end
		isPlayingPotionCooldownEnded = true
		zo_callLater(function() isPlayingPotionCooldownEnded = false end, PlaySoundLockDelay)
	    PTSF.D("PlaySound category is "..category)
		if(settings.potionCooldownEndedSound > 1 and SOUNDS[PTSF.sounds[settings.potionCooldownEndedSound]]) then -- ~= nil
			sound = SOUNDS[PTSF.sounds[settings.potionCooldownEndedSound]]
			volume = settings.potionCooldownEndedVolumeBoost
			PTSF.D("PlaySound sound="..sound.." volume="..volume)
		elseif(settings.potionCooldownEndedSound == 1) then
		    PTSF.D("PlaySound sound is muted")
			return --No sound to play
		else
			PTSF.D("PlaySound didn't find any sound to play (code: 5002)")
		end
	else
		PTSF.D("PlaySound unknown category ["..tostring(category).."]")
	end --}}}
	
	--Now play our sound
	if(sound == "DEFAULT") then
		PlayItemSound(ITEM_SOUND_CATEGORY_POTION, ITEM_SOUND_ACTION_USE, true)
	elseif(sound and volume) then --Volume Booster
    	for i = 1, volume do
        	PlaySound(sound)
        	PTSF.D(tostring(i).."- Playing "..tostring(sound))
        end
    else
    	PTSF.D("PlaySound didn't find any sound to play (code: 5003)")
	end
end --}}}

--[[ UI VOLUME {{{
--Increase the Interface Volume
function PTSF.ResetUIVolume()
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, userInterfaceVolume)
end

--Decrease the Interface Volume
function PTSF.MuteUIVolume()
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, 0)
    zo_callLater(function() PTSF.IncreaseUIVolume() end, 500)
end --}}}]]

--=============================================================================================================
--	Addon Initialization {{{
--=============================================================================================================

function PTSF.initialize()
	EVENT_MANAGER:RegisterForEvent(PTSF.addonVars.addonName, EVENT_PLAYER_ACTIVATED, PTSF_Player_Activated)
	EVENT_MANAGER:RegisterForEvent(PTSF.addonVars.addonName, EVENT_ADD_ON_LOADED, PTSF_addonLoaded)
end --}}}

--=============================================================================================================
--	Debug function {{{
--=============================================================================================================
function PTSF.D(message, force)
    if(PTSF.debug or force) then
        d("|cFF0000["..PTSF.addonVars.addonName.."]|r "..tostring(message))
    end
end --}}}

--Initialize the addon
PTSF.initialize()
