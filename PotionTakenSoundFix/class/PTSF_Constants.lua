if PotionTakenSoundFix == nil then PotionTakenSoundFix = {} end
local PTSF = PotionTakenSoundFix

--=============================================================================================================
-- Constants & variables
--=============================================================================================================
--LAM addon menu
PTSF.addonMenu = {}
PTSF.addonMenu.isShown = false
PTSF.addonMenu.isBuilt = false

--Settings
PTSF.settingsVars			= {}
PTSF.settingsVars.defaults		= {}
PTSF.settingsVars.settings		= {}
PTSF.settingsVars.defaultSettings	= {}
PTSF.localizationVars			= {}