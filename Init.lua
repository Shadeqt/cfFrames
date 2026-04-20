cff = cff or {}
cff.SENTINEL = "cff"

cff.MODULES = {
	-- General
	"StatusBar",
	"BiggerHealthbar",
	"HealthbarColor",
	"HealthbarColorRaid",
	"HealthbarColorNameplateEnemy",
	"HealthbarColorNameplateFriendly",
	"NameplateClassification",
	-- Dark Mode
	"DarkMode",
	"DarkModeFrames",
	"DarkModeActionBars",
	"DarkModeMinimap",
	"DarkModeChat",
	"DarkModeNameplates",
	"DarkModeIconBuffs",
	"DarkModeIconActionBars",
	-- Fixes
	"ActionBarAlphaFix",
	"ToTPortraitFix",
	"ToTBackgroundFix",
	"TargetNameWidthFix",
	"NameplateLevelPositionFix",
	"ActionBarIconPositionFix",
	"PetActionBarCheckedFix",
	"UnitFrameResetFix",
}

cff.DEFAULTS = {}
for _, key in ipairs(cff.MODULES) do
	cff.DEFAULTS[key] = true
	cff.MODULES[key] = key
end

cff.VALUES = {
	"StatusBarTexture",
	"DarkModeColor",
	"DarkModeColorSecondary",
	"PlayerFrameScale",
	"PlayerFrameX",
	"PlayerFrameY",
	"PetFrameScale",
	"PetFrameX",
	"PetFrameY",
	"TargetFrameScale",
	"TargetFrameX",
	"TargetFrameY",
	"NameplateScale",
}
for _, key in ipairs(cff.VALUES) do
	cff.VALUES[key] = key
end

cff.DEFAULTS.StatusBarTexture       = "Interface\\AddOns\\cfFrames\\Media\\StatusBar\\BlizzardRetailBarCrop2"
cff.DEFAULTS.DarkModeColor          = 0.25
cff.DEFAULTS.DarkModeColorSecondary = 0.75
cff.DEFAULTS.PlayerFramePos         = false
cff.DEFAULTS.PlayerFrameScale       = 1
cff.DEFAULTS.PlayerFrameX           = 0
cff.DEFAULTS.PlayerFrameY           = 0
cff.DEFAULTS.PetFrameScale          = 1
cff.DEFAULTS.PetFrameX              = 0
cff.DEFAULTS.PetFrameY              = 0
cff.DEFAULTS.TargetFramePos                = false
cff.DEFAULTS.TargetFrameScale              = 1
cff.DEFAULTS.TargetFrameX                  = 0
cff.DEFAULTS.TargetFrameY                  = 0
cff.DEFAULTS.NameplateScale                = 1

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
		cff.ApplyPlayerFrame()
		cff.ApplyPetFrame()
		cff.ApplyTargetFrame()
		cff.ApplyNameplateScale()
		cff.EnableNameplateClassification()
		cff.EnableDarkMode()
		cff.EnableDarkModeIcons()

		-- Fixes
		cff.InitActionBarAlphaFix()
		cff.InitToTPortraitFix()
		cff.InitToTBackgroundFix()
		cff.InitTargetNameWidthFix()
		cff.InitNameplateLevelPositionFix()
		cff.InitActionBarIconPositionFix()
		cff.InitPetActionBarCheckedFix()
		cff.InitUnitFrameResetFix()
	end)
end)
