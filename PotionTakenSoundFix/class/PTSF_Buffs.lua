if PotionTakenSoundFix == nil then PotionTakenSoundFix = {} end
local PTSF = PotionTakenSoundFix
------------------------------------------------------------------------------------------------------------
-- Sounds for notifications
------------------------------------------------------------------------------------------------------------
    PTSF.buffs          = { 	--Used in options
    { name = "Unstoppable", 				description = "Become immune to knockback and disabling effects", },
    { name = "Lingering Restore Health", 	description = "Restore x health every second", },
    { name = "Major Brutality", 			description = "+20% Weapon Damage", },
    { name = "Major Savagery", 				description = "2191 (+10% @ cp160) Weapon Critical", },
    { name = "Major Sorcery", 				description = "+20% Spell Damage", },
    { name = "Major Prophecy", 				description = "2191 (+10% @ cp160) Spell Critical", },
    { name = "Major Fortitude", 			description = "+20% Health Recovery", },
    { name = "Major Endurance", 			description = "+20% Stamina Recovery", },
    { name = "Major Intellect", 			description = "+20% Magicka Recovery", },
    { name = "Major Vitality", 				description = "+30% Healing Taken", },
    { name = "Minor Protection", 			description = "-8% Damage Taken", },
    { name = "Minor Heroism", 				description = "+1 Ultimate every 1.5 second", },
    { name = "Physical Resistance",			description = "Increase Physical Resistance by 5280\nActually is Major Resolve in Scalebreaker\nIts own resistance additive in Dragonhold+", },
    { name = "Spell Resistance",			description = "Increase Spell Resistance by 5280\nActually is Major Ward in Scalebreaker\nIts own resistance additive in Dragonhold+", },
    { name = "Major Expedition", 			description = "+30% Movement Speed", },
    { name = "Increase Detection",		 	description = "Increase your Stealth Detection by 20 meters", },
    { name = "Invisibility", 				description = "Become invisible", },
    
--    { name = "Vanish", 	description = "Vanish (become invisible, crafted/looted potion)", },
}

--if(PTSF.APIVersion == 100028) then
PTSF.buffs_abilityIds          = { --We're doing it this way so we'll be able to do a direct compare instead of looping within arrays. We want to keep performance hit to a minimim
    [45239] = "Unstoppable", 				--crafted
    [72930] = "Unstoppable",				--bought/looted
    [86698] = "Unstoppable",				--crown-store
    [79705] = "Lingering Restore Health", 	--crafted
    [64555] = "Major Brutality",			--crafted
    [72936] = "Major Brutality",			--bought/looted
    [86695] = "Major Brutality",			--crown-store
    [64568] = "Major Savagery",				--crafted
    [86694] = "Major Savagery",				--crown-store
    [64558] = "Major Sorcery",				--crafted
    [72933] = "Major Sorcery",				--bought/looted
    [86685] = "Major Sorcery",				--crown-store
    [64570] = "Major Prophecy",				--crafted
    [86684] = "Major Prophecy",				--crown-store
    [45222] = "Major Fortitude",			--crafted
    [63672] = "Major Fortitude",			--bought/looted
    [72928] = "Major Fortitude",			--bought/looted
    [68405] = "Major Fortitude",			--crown-store
    [86697] = "Major Fortitude",			--crown-store
    [45226] = "Major Endurance",			--crafted
    [63683] = "Major Endurance",			--bought/looted
    [72935] = "Major Endurance",			--bought/looted
    [78054] = "Major Endurance",			--bought/looted
    [78080] = "Major Endurance",			--bought/looted
    [68408] = "Major Endurance",			--crown-store
    [86693] = "Major Endurance",			--crown-store
    [45224] = "Major Intellect",			--crafted
    [63678] = "Major Intellect",			--bought/looted
    [72932] = "Major Intellect",			--bought/looted
    [68406] = "Major Intellect",			--crown-store
    [86683] = "Major Intellect",			--crown-store
    [79848] = "Major Vitality",				--crafted
    [79712] = "Minor Protection",			--crafted
    [125027] = "Minor Heroism",				--crafted (currently missing in LibPotionBuff)
	[64564] = "Physical Resistance",		--crafted (currently missing in LibPotionBuff)
	[64562] = "Spell Resistance",			--crafted
	[64566] = "Major Expedition",			--crafted
	[78081] = "Major Expedition",			--bought/looted
	[45236] = "Increase Detection",			--crafted
	[45237] = "Invisibility",				--crafted (it's actually "vanish")
	[78058] = "Invisibility",				--bought/looted (it's actually "vanish")
	[86699] = "Invisibility",				--crown-store
	[86780] = "Invisibility",				--crown-store
}

local debug_buffs = false

function PTSF.list_abilities_to_chat()
--[[		if(PTSF.APIVersion ~= nil) then
			PTSF.DG("Using data for API Version: "..PTSF.APIVersion)
		else
			PTSF.D("Unknown API Version, using latest data from API Version 100029 Dragonhold", true)
		end--]]
		local count = 0
		local text = ""
		local abilityIds = {}
        for i, buff in pairs(PTSF.buffs) do
        	if(buff.name) then
        		for j, buffName in pairs(PTSF.buffs_abilityIds) do
        			if(buffName == buff.name) then
        				count = count + 1
        				abilityIds[count] = j
        			end
        		end
        		d(i.."- |c9853C6buff.name="..buff.name.."|r |c008B21.description="..buff.description.."|r")
        		if(count ~= 0) then
        			text = "    -> abilityId's |cFFAC03"
        			for k = 1, count do
        				text = text.." "..k.."-["..abilityIds[k].."]"
        			end
        			d(text.."|r")
        			count = 0
        			abilityIds = {}
        		end
        	end
        end
end

if(debug_buffs) then PTSF.list_abilities_to_chat() end