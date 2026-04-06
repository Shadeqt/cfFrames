cff = cff or {}
cff.SENTINEL = "cff"

cff.MODULES = {
	-- General
	"StatusBar",
	"StatusBarTexture",
	"BiggerHealthbar",
	"HealthbarColor",
	"HealthbarColorRaid",
	"HealthbarColorNameplateEnemy",
	"HealthbarColorNameplateFriendly",
	"PlayerCastbarIcon",
	"NameplateCastbar",
	-- Dark Mode
	"DarkMode",
	"DarkModeColor",
	"DarkModeColorSecondary",
	"DarkModeFrames",
	"DarkModeActionBars",
	"DarkModeMinimap",
	"DarkModeChat",
	"DarkModeCastbars",
	"DarkModeNameplates",
	"DarkModeIconBuffs",
	"DarkModeIconActionBars",
	-- Fixes
	"ActionBarAlphaFix",
	"ToTPortraitFix",
	"ToTBackgroundFix",
	"TargetCastbarBorderFix",
	"TargetNameWidthFix",
	"TargetCastbarIconFix",
	"NameplateLevelPositionFix",
	"ActionBarIconPositionFix",
	"PetActionBarCheckedFix",
}

cff.DEFAULTS = {}
for _, key in ipairs(cff.MODULES) do
	cff.DEFAULTS[key] = true
	cff.MODULES[key] = key
end
cff.DEFAULTS.StatusBarTexture = "Interface\\AddOns\\cfFrames\\Media\\StatusBar\\BlizzardRetailBarCrop2"
cff.DEFAULTS.DarkModeColor = 0.25
cff.DEFAULTS.DarkModeColorSecondary = 0.75

EventUtil.ContinueOnAddOnLoaded("cfFrames", function()
	local fresh = not cfFramesDB
	cfFramesDB = cfFramesDB or {}

	-- Add new keys
	for key, value in pairs(cff.DEFAULTS) do
		if cfFramesDB[key] == nil then
			cfFramesDB[key] = value
		end
	end

	-- First install: read CVar state so we don't override user preferences
	if fresh then
		cfFramesDB[cff.MODULES.HealthbarColorRaid] = GetCVarBool("raidFramesDisplayClassColor")
		cfFramesDB[cff.MODULES.HealthbarColorNameplateEnemy] = GetCVarBool("ShowClassColorInNameplate")
		cfFramesDB[cff.MODULES.HealthbarColorNameplateFriendly] = GetCVarBool("ShowClassColorInFriendlyNameplate")
	end

	-- Remove stale keys
	for key in pairs(cfFramesDB) do
		if cff.DEFAULTS[key] == nil then
			cfFramesDB[key] = nil
		end
	end

	local f = CreateFrame("Frame")
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:SetScript("OnEvent", function(self)
		self:UnregisterAllEvents()
		cff.EnableStatusBar()
		cff.EnableBiggerHealthbar()
		cff.EnableHealthbarColor()
		cff.SyncHealthbarCVars()
		cff.EnablePlayerCastbarIcon()
		cff.EnableNameplateCastbar()
		cff.EnableDarkMode()
		cff.EnableDarkModeIcons()

		-- Fixes
		cff.InitActionBarAlphaFix()
		cff.InitToTPortraitFix()
		cff.InitToTBackgroundFix()
		cff.InitTargetCastbarBorderFix()
		cff.InitTargetNameWidthFix()
		cff.InitTargetCastbarIconFix()
		cff.InitNameplateLevelPositionFix()
		cff.InitActionBarIconPositionFix()
		cff.InitPetActionBarCheckedFix()
	end)
end)
