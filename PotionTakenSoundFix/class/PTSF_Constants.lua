if PotionTakenSoundFix == nil then PotionTakenSoundFix = {} end
local PTSF = PotionTakenSoundFix

--=============================================================================================================
-- Constants & variables
--=============================================================================================================
--LAM addon menu
PTSF.addonMenu = {}
PTSF.addonMenu.isShown = false
PTSF.addonMenu.isBuilt = false

-- Debug
PTSF.debug				= false

--Settings
PTSF.settingsVars						= {}
PTSF.settingsVars.defaults				= {}
PTSF.settingsVars.settings				= {}
PTSF.settingsVars.defaultSettings		= {}
PTSF.localizationVars					= {}
PTSF.settingsVars.settings.buffFilters	= {}
PTSF.masterSwitch						= true
PTSF.toggle_potion_buffs_check_enabled	= false