if PotionTakenSoundFix == nil then PotionTakenSoundFix = {} end
local PTSF = PotionTakenSoundFix
--=============================================================================================================
-- Addon info {{{
--=============================================================================================================

PTSF.addonVars =  {}
PTSF.addonVars.addonRealVersion			= 1.04
PTSF.addonVars.addonRealVersionPreText  = "" --Release is empty string. Pre-Release = "PR " and Release Candicate = "RC "
PTSF.addonVars.addonSavedVarsVersion	= 1.00
PTSF.addonVars.addonSavedVarsModeVersion= 1.00
PTSF.addonVars.addonName				= "PotionTakenSoundFix"
PTSF.addonVars.addonSavedVars			= "PotionTakenSoundFix_Settings"
PTSF.addonVars.settingsName   			= "Potion Taken Sound Fix"
PTSF.addonVars.settingsDisplayName   	= "|cFF0000Potion Taken|r|l0:1:0:5%:2:FF0000|l Sound Fix|l"
PTSF.addonVars.addonAuthor				= "|c00BF9CTrader08|r"
PTSF.addonVars.addonWebsite				= "https://www.esoui.com/downloads/info2463-PotionTakenSoundFix.html"
PTSF.addonVars.addonFeedback			= "https://www.esoui.com/downloads/info2463-PotionTakenSoundFix.html#comments"
PTSF.addonVars.addonDonate				= "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=MGLYRE7N8VTEN&item_name=Support+"..PTSF.addonVars.addonName.."+by+buying+me+a+skooma%21&currency_code=USD&source=url"

--}}}

--=============================================================================================================
-- Libraries {{{
--=============================================================================================================

--libLoadedAddons (not as a dependency for now)
local LIBLA = LibLoadedAddons
PTSF.libLA = LIBLA
--[[LibPotionBuff
local libPB = LibPotionBuff
if libPB == nil and LibStub then libPB = LibStub:GetLibrary("LibPotionBuff") end --deprecated
PTSF.libPB = libPB --]]
--LibAddonMenu-2.0
PTSF.addonMenu = LibAddonMenu2
--if PTSF.addonMenu == nil and LibStub then PTSF.addonMenu = LibStub:GetLibrary("LibAddonMenu-2.0") end --deprecated
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
	
    --Check if this is a new install (we had no saved vars prior to this so the sound settings didn't go thru our "tricked" options menu)
    if(tonumber(settings.potionLostBuffSound) <= 1 ) then --default is 1, but in reality it is sound 2 in our sounds table
    	PTSF.D("Updating save values")
    	settings.potionLostBuffSound = 2
    	if(tonumber(settings.potionCooldownEndedSound) == tonumber(defaults.potionCooldownEndedSound)) then
    		settings.potionCooldownEndedSound = settings.potionCooldownEndedSound + 1
    		PTSF.D("Updated settings.potionCooldownEndedSound="..settings.potionCooldownEndedSound.." from default defaults.potionCooldownEndedSound="..defaults.potionCooldownEndedSound)
    	end
    end
    
	EVENT_MANAGER:UnregisterForEvent(eventName)
	
	--Update user's UI volume
--	userInterfaceVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME)) --tempo
	
	PTSF.RegisterAbilityIdsFilterOnEventEffectChanged(PTSF.addonVars.addonName, PTSF.potTaken, REGISTER_FILTER_UNIT_TAG, "player") --Only on self (player)
	
	-- Not a dependency, but for those who have libLoadedAddon loaded as a library, why not
	if(PTSF.libLA) then
		PTSF.libLA:RegisterAddon(PTSF.addonVars.addonName, PTSF.addonVars.addonRealVersion)
	end
	
	PTSF.D("Loaded successfully")
	eventRegistered = true
	
end --}}}

--=============================================================================================================
--	Some prehook magic {{{
--=============================================================================================================

local function PTSF_PlayItemSound_Hook(sound, action, force)
    PTSF.D("PTSF_PlayItemSound_Hook sound="..sound.." action="..action.." force="..tostring(force).." potionCooldown_ms="..potionCooldown_ms)
    if(sound == ITEM_SOUND_CATEGORY_POTION and action == ITEM_SOUND_ACTION_USE and not force and PTSF.masterSwitch) then
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

function PTSF.Player_Activated(...)
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

function PTSF.potTaken(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
--(integer eventCode, integer changeType, integer effectSlot, string effectName, string unitTag, number beginTime, number endTime, integer stackCount, string iconName, string buffType, integer effectType, integer abilityType, integer statusEffectType, string unitName, integer unitId, integer abilityId, integer sourceUnitType
	PTSF.D("eventCode="..tostring(eventCode).." changeType="..tostring(changeType).." effectSlot="..tostring(effectSlot).." effectName="..tostring(effectName).." unitTag="..tostring(unitTag).." beginTime="..tostring(beginTime).." endTime="..tostring(endTime).." stackCount="..tostring(stackCount).." iconName="..tostring(iconName)
	.." buffType="..tostring(buffType).." effectType="..tostring(effectType).." abilityType="..tostring(abilityType).." statusEffectType="..tostring(statusEffectType).." unitName="..tostring(unitName).." unitId="..tostring(unitId).." abilityId="..tostring(abilityId).." sourceUnitType="..tostring(sourceUnitType)
	.."\n")
	if(unitTag ~= "player") then
	     PTSF.D("PTSF.potTaken triggered not on player")
	     return
	end
	if(changeType == 1 and unitTag == "player" and beginTime > 0 and endTime > 0) then --changeType = 1 seems to be gained while = 2 lost. beginTime and endTime always return a float value when we just took a potion. Else they return no value or 0 and it's called when pot buffs run out
	    --PTSF.DecreaseUIVolume()
	    potionCooldown_ms = PTSF.GetPotionSlotCooldown(PTSF.debug) --potion cooldown from currently selected quickslot
        PTSF.PlaySound("potionTaken")
        
        --[[In case we use a potion that gives buffs you already have, prevent the lost buff sound to play
        	because using a potion that will "renew" your buffs, it removes the old (so you lose it) and creates a new one.
        	The only bug this might cause is if we actually lose a buff from another potion @ the same time
        	Quite rare and both pot taken and lost buff sounds would play simultaneously anyway--]]
	 	isPlayingPotionLostBuff = true
	 	zo_callLater(function() isPlayingPotionLostBuff = false end, PlaySoundLockDelay)
	    
	    --Since we know the potion duration from the currently selected quickslot and we know we just took a potion and had to be doing it from a quickslot, assume we got the cooldown right.
	    --So we're delay calling the "potion cooldown ended" sound after that said cooldown
	    zo_callLater(function() PTSF.PlaySound("potionCooldownEnded") end, potionCooldown_ms)

	elseif(unitTag == "player" and changeType == 2 and not isPlayingPotionLostBuff) then --Any potion Buff lost
		if(settings.enableBuffFilter) then
			if(settings.buffFilters[PTSF.buffs_abilityIds[abilityId]]) then
				PTSF.PlaySound("potionLostBuff")
			end
		else
	    	PTSF.PlaySound("potionLostBuff")
	    end
	end
end --}}}

--=============================================================================================================
--	Our PlaySound function {{{
--=============================================================================================================

function PTSF.PlaySound(category)
	if (SOUNDS == nil or not PTSF.masterSwitch) then return end
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

--=============================================================================================================
--	NEW 1.02 Unknown Potion Buffs Finder {{{
--=============================================================================================================
function PTSF.toggle_potion_buffs_check(enable)
	if(enable) then
    	EVENT_MANAGER:RegisterForEvent(PTSF.addonVars.addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, PTSF.INVENTORY_SINGLE_SLOT_UPDATE)
    	EVENT_MANAGER:RegisterForEvent(PTSF.addonVars.addonName, EVENT_INVENTORY_ITEM_USED, PTSF.INVENTORY_ITEM_USED)
    	EVENT_MANAGER:RegisterForEvent(PTSF.addonVars.addonName, EVENT_EFFECT_CHANGED, PTSF.EFFECT_CHANGED) --Not using a different name because libPotionBuff' EVENT_EFFECT_CHANGED creates different ones
    	PTSF.DG("Unknown Potion Buffs Finder is |c00FF00ON|r")
    else
    	EVENT_MANAGER:UnregisterForEvent(PTSF.addonVars.addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    	EVENT_MANAGER:UnregisterForEvent(PTSF.addonVars.addonName, EVENT_INVENTORY_ITEM_USED)
    	EVENT_MANAGER:UnregisterForEvent(PTSF.addonVars.addonName, EVENT_EFFECT_CHANGED)
    	PTSF.DG("Unknown Potion Buffs Finder is |c00FF00OFF|r")
    end
end

local counter = 1
local tookPotionCheck = 0

-- PTSF.INVENTORY_ITEM_USED {{{
function PTSF.INVENTORY_ITEM_USED(eventCode, itemSoundCategory)
--EVENT_INVENTORY_ITEM_USED (*integer* _itemSoundCategory_)
--This one gets called 1st but gets called as a false positive if potion is on gcd
	if itemSoundCategory == ITEM_SOUND_CATEGORY_POTION then
		counter = 1
		PTSF.DG(counter.."- Potion buffs check begins")
        --PTSF.DG("EVENT_INVENTORY_ITEM_USED")
        if(tookPotionCheck ~= 0) then
        	EVENT_MANAGER:UnregisterForUpdate(tookPotionCheck)
        end
        tookPotionCheck = zo_callLater(tookPotionCheckEnded, 250) --250ms time window should be plenty
    end
end
--}}}
-- PTSF.INVENTORY_SINGLE_SLOT_UPDATE {{{
function PTSF.INVENTORY_SINGLE_SLOT_UPDATE(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
--(*integer* _bagId_, *integer* _slotId_, *bool* _isNewItem_, *integer* _itemSoundCategory_, *integer* _updateReason_)
--Gets called when successfully taking a potion but also if we loot/deposit/withdraw/etc any potion. In other words, any potion change in inventory
	if itemSoundCategory == ITEM_SOUND_CATEGORY_POTION and tookPotionCheck ~= 0 then
		local itemLink = GetItemLink(bagId, slotId)
		counter = counter + 1
		PTSF.DG(counter.."- Potion "..itemLink.." successfully taken") --We actually took a potion!
        --PTSF.DG("EVENT_INVENTORY_SINGLE_SLOT_UPDATE")
    end
end
--}}}
-- PTSF.EFFECT_CHANGED {{{
function PTSF.EFFECT_CHANGED(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, StatusEffectType, unitName, unitId, abilityId, sourceUnitType)
--(integer eventCode, integer changeType, integer effectSlot, string effectName, string unitTag, number beginTime, number endTime, integer stackCount, string iconName, string buffType, integer effectType, integer abilityType, integer statusEffectType, string unitName, integer unitId, integer abilityId, integer sourceUnitType
	if(tookPotionCheck ~= 0 and unitTag == "player" and string.find(iconName, "achievement") == nil and string.find(effectName, "Dodge Fatigue") == nil) then --We filter to not display achievement buffs nor dodge fatique (roll dodged then used a potion)
		counter = counter + 1
    	PTSF.DG(counter.."- Buff: "..effectName.." abilityId: "..abilityId)
		--PTSF.DG("EVENT_EFFECT_CHANGED changeType="..changeType.." effectSlot="..effectSlot.." effectName="..effectName.." unitTag="..unitTag.." beginTime="..beginTime.." endTime="..endTime.." stackCount="..stackCount)
    	--PTSF.DG("iconName="..iconName.." buffType="..buffType.." effectType="..effectType.." abilityType="..abilityType.." StatusEffectType="..StatusEffectType.." unitName="..unitName.." unitId="..unitId)
    	--PTSF.DG("abilityId="..abilityId.." sourceUnitType="..sourceUnitType)
    end
end
--}}}
function tookPotionCheckEnded()
	tookPotionCheck = 0
	counter = 1
end
--end of NEW 1.02 Unknown Potion Buffs Finder }}}

--=============================================================================================================
--	Register abilities {{{ Based on Baertram's code
--=============================================================================================================
function PTSF.RegisterAbilityIdsFilterOnEventEffectChanged(addonEventNameSpace, callbackFunc, filterType, filterParameter)
	if addonEventNameSpace == nil or addonEventNameSpace == "" then return nil end
	if callbackFunc == nil or type(callbackFunc) ~= "function" then return nil end
	local eventCounter = 0
	for abilityId, _ in pairs(PTSF.buffs_abilityIds) do
		eventCounter = eventCounter + 1
		local eventName = addonEventNameSpace .. eventCounter
		EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, callbackFunc)
		EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId, filterType, filterParameter)
	end
	return true
end

-- Unregister the register function above
function PTSF.UnRegisterAbilityIdsFilterOnEventEffectChanged(addonEventNameSpace)
    local eventCounter = 0
    if addonEventNameSpace == nil or addonEventNameSpace == "" then return nil end
    for abilityId, _ in pairs(PTSF.buffs_abilityIds) do
        eventCounter = eventCounter + 1
        local eventName = addonEventNameSpace .. eventCounter
        EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_EFFECT_CHANGED)
    end
    return true
end

function PTSF.GetPotionSlotCooldown(chatOutput)
    -- Parameter:   boolean chatOutput: true = output the info to the chat; false = do not show anyhting into the chat
    -- Returns:     number timeLeftInMilliseconds, number buffTotalCooldownInMilliseconds
    chatOutput = chatOutput or false
    -- GetSlotCooldownInfo(*luaindex* _slotIndex_)
    -- _Returns:_ *integer* _remain_, *integer* _duration_, *bool* _global_, *[ActionBarSlotType|#ActionBarSlotType]* _globalSlotType_

    --Get the quicklsot index slot ID (quickslot index) = 9
    local remain, duration = GetSlotCooldownInfo(GetCurrentQuickslot())
    if chatOutput then
        PTSF.D("Potion cooldown active, remaining: " .. tostring(remain) .. " of " .. tostring(duration))
    end
    return remain, duration
end

--=============================================================================================================
--	onArgCommand (command lines) {{{
--=============================================================================================================
function PTSF.onArgCommand(arg)
--	if(arg == "" or arg == "help" or string.find(arg, "-") == 1) then

	if(string.lower(arg) == "master_switch") then
		if(PTSF.masterSwitch) then
        	PTSF.UnRegisterAbilityIdsFilterOnEventEffectChanged(PTSF.addonVars.addonName)
        	PTSF.D("Master Switch is |cFF0000OFF|r (default sound without fix will play)", true)
        	PTSF.masterSwitch = false
        else
        	PTSF.RegisterAbilityIdsFilterOnEventEffectChanged(PTSF.addonVars.addonName, PTSF.potTaken, REGISTER_FILTER_UNIT_TAG, "player")
            PTSF.DG("Master Switch is |c00FF00ON|r")
            PTSF.masterSwitch = true
        end
    elseif(string.lower(arg) == "buffs_finder") then
    	PTSF.toggle_potion_buffs_check_enabled = not PTSF.toggle_potion_buffs_check_enabled
        PTSF.toggle_potion_buffs_check(PTSF.toggle_potion_buffs_check_enabled)
    elseif(string.lower(arg) == "debug") then
    	PTSF.debug = not PTSF.debug
    	if(PTSF.debug) then
    		PTSF.D("Debug is |c00FF00ON|r", true)
    	else
    		PTSF.D("Debug is |cFF0000OFF|r", true)
    	end
    elseif(string.lower(arg) == "list_buffs") then
    	PTSF.list_abilities_to_chat()
    else
		PTSF.DG("======= Arguments =======")
		PTSF.DG("/ptsf master_switch (Toggles ON/OFF the addon's inner workings)")
		PTSF.DG("/ptsf buffs_finder (Toggles ON/OFF potion buffs finder)")
		PTSF.DG("/ptsf debug (Toggles ON/OFF debug to chat. Mainly used for dev)")
		PTSF.DG("/ptsf list_buffs (List this addon's internal abilityId's linked to potion buffs)")
	end
end --}}}

--=============================================================================================================
--	userInterfaceVolume {{{
--=============================================================================================================
--[[ UI VOLUME
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
	EVENT_MANAGER:RegisterForEvent(PTSF.addonVars.addonName, EVENT_PLAYER_ACTIVATED, PTSF.Player_Activated)
	EVENT_MANAGER:RegisterForEvent(PTSF.addonVars.addonName, EVENT_ADD_ON_LOADED, PTSF_addonLoaded)
	SLASH_COMMANDS["/ptsf"] = PTSF.onArgCommand
end --}}}

--Initialize the addon
PTSF.initialize()
