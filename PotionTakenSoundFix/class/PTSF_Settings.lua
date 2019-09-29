if PotionTakenSoundFix == nil then PotionTakenSoundFix = {} end
local PTSF = PotionTakenSoundFix

--=============================================================================================================
-- Settings
--=============================================================================================================
function PTSF.loadSettings()
    --The default value for save mode
    local firstRunSettings = {
        saveMode     		    = 2, --Standard: Account wide settings
    }
    PTSF.settingsVars.defaults = {

        potionTakenSound				= 1, --default game sound
        potionTakenVolumeBoost			= 1, --default game volume
        
        potionLostBuffSound				= 1, --NONE (slider value)
        potionLostBuffVolumeBoost		= 1,
        
        potionCooldownEndedSound		= 4, --ALCHEMY_SOLVENT_PLACED. "Game's restore defaults" will play it twice since it doesn't throw our doNotPlaySound value
        potionCooldownEndedVolumeBoost	= 1,
        enableBuffFilter				= false,
        buffFilters						= {},
    }
    --=============================================================================================================
    --	LOAD USER SETTINGS
    --=============================================================================================================
    local addonVars = PTSF.addonVars
    local defaults  = PTSF.settingsVars.defaults
    --Save Mode Load the user's settings from SavedVariables file -> Account wide of addonSavedVarsModeVersion at first
    PTSF.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVars, PTSF.addonVars.addonSavedVarsModeVersion, "SettingsForAll", firstRunSettings) --Make the save mode static

    --Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
    --Use the current addon version to read the settings now
    if (PTSF.settingsVars.defaultSettings.saveMode == 1) then
        PTSF.settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings(addonVars.addonSavedVars, addonVars.addonSavedVarsVersion , "Settings", defaults)

    elseif (PTSF.settingsVars.defaultSettings.saveMode == 2) then
        PTSF.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVars, addonVars.addonSavedVarsVersion, "Settings", defaults)
    else
        PTSF.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVars, addonVars.addonSavedVarsVersion, "Settings", defaults)
    end
    PTSF.settingsVars.settings.debug = nil --Remove this value from users' savedvars from prior v1.02
    --=============================================================================================================
end

