if PotionTakenSoundFix == nil then PotionTakenSoundFix = {} end
local PTSF = PotionTakenSoundFix
------------------------------------------------------------------------------------------------------------
-- Sounds for notifications
------------------------------------------------------------------------------------------------------------
    PTSF.sounds              = {
    "ACTIVE_SKILL_MORPH_CHOSEN",
    "ALCHEMY_CREATE_TOOLTIP_GLOW_SUCCESS",
    "ALCHEMY_SOLVENT_PLACED",
    "ALCHEMY_SOLVENT_REMOVED",
    "BLACKSMITH_EXTRACTED_BOOSTER",
    "CHAMPION_CYCLED_TO_MAGE",
    "CHAMPION_DAMAGE_TAKEN",
    "CHAMPION_PENDING_POINTS_CLEARED",
    "CHAMPION_POINTS_COMMITTED",
    "CHAMPION_STAR_LOCKED",
    "CHAMPION_STAR_MOUSEOVER",
    "CHAMPION_STAR_UNLOCKED",
    "CHAMPION_SYSTEM_UNLOCKED",
    "CROWN_CRATES_PURCHASED_WITH_GEMS",
    "DAEDRIC_ENERGY_LOW",
    "DEATH_RECAP_ATTACK_SHOWN",
    "DEATH_RECAP_KILLING_BLOW_SHOWN",
    "DUEL_ACCEPTED",
    "DUEL_START",
    "DYEING_APPLY_CHANGES",
    "DYEING_TOOL_DYE_USED",
    "DYEING_TOOL_FILL_USED",
    "DYEING_UNDO_CHANGES",
    "GAMEPAD_STATS_SINGLE_PURCHASE",
    "GIFT_INVENTORY_VIEW_FANFARE_SPARKS",
    "INVENTORY_ITEM_APPLY_CHARGE",
    "INVENTORY_ITEM_APPLY_ENCHANT",
    "JUSTICE_PICKPOCKET_BONUS",
    "JUSTICE_PICKPOCKET_FAILED",
    "LOCKPICKING_BREAK",
    "NEW_TIMED_NOTIFICATION",
    "RETRAITING_RETRAIT_TOOLTIP_GLOW_SUCCESS",
    "RETRAITING_START_RETRAIT",
    "ZONE_STORIES_TRACK_ACTIVITY",
}

table.sort(PTSF.sounds)
table.insert(PTSF.sounds, 1, "DEFAULT")
table.insert(PTSF.sounds, 2, "NONE")

local debug_sounds = false

if(debug_sounds) then
    if PTSF.sounds then
        for i, soundName in pairs(PTSF.sounds) do
	d(i.."- soundName="..soundName)
        end
    end
end
