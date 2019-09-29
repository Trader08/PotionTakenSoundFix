if PotionTakenSoundFix == nil then PotionTakenSoundFix = {} end
local PTSF = PotionTakenSoundFix
------------------------------------------------------------------------------------------------------------
-- Sounds for notifications
------------------------------------------------------------------------------------------------------------
    PTSF.buffs              = {
    "Unstoppable",
    "Lingering Restore Health",
    "Major Brutality",
    "Major Savagery",
    "Major Sorcery",
    "Major Prophecy",
    "Major Fortitude",
    "Major Endurance",
    "Major Intellect",
    "Major Vitality",
    "Minor Protection",
    "Minor Heroism", 
    "Major Resolve",
    "Major Ward",
    "Major Expedition",
    "Increase Detection",
    "Vanish",
    "Invisibility",
}

    PTSF.buffs_description   = {
    "Become immune to knockback and disabling effects",
    "Restore health every second",
    "+20% Weapon Damage",
    "2191 (+10% @ cp160) Weapon Critical",
    "+20% Spell Damage",
    "2191 (+10% @ cp160) Spell Critical",
    "+20% Health Recovery",
    "+20% Stamina Recovery",
    "+20% Magicka Recovery",
    "+30% Healing Taken",
    "-8% Damage Taken",
    "+1 Ultimate every 1.5 second",
    "Increase Physical Resistance by 5280",
    "Increase Spell Resistance by 5280",
    "+30% Movement Speed",
    "Increase your Stealth Detection by 20 meters",
    "Vanish (become invisible, crafted/looted potion)",
    "Become invisible (Crown-Store potion)",
}

local debug_buffs = false

if(debug_buffs) then
    if PTSF.buffs then
        for i, buffName in pairs(PTSF.buffs) do
	d(i.."- buffName="..buffName.." description="..PTSF.buffs_description[i])
        end
    end
end