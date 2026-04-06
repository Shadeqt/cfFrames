cff = cff or {}
cff.SENTINEL = "cff"

cff.MODULES = {
	-- General
	"StatusBar",
	"BiggerHealthbar",
	"HealthbarColor",
	"PlayerCastbarIcon",
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
	"NameplateCastbar",
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
cff.DEFAULTS.StatusBar = "Interface\\AddOns\\cfFrames\\Media\\StatusBar\\BlizzardRetailBarCrop2"
cff.DEFAULTS.DarkModeColor = 0.25
cff.DEFAULTS.DarkModeColorSecondary = 0.75

EventUtil.ContinueOnAddOnLoaded("cfFrames", function()
	cfFramesDB = cfFramesDB or {}

	-- Add new keys
	for key, value in pairs(cff.DEFAULTS) do
		if cfFramesDB[key] == nil then
			cfFramesDB[key] = value
		end
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
