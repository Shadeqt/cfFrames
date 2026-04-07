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
	"PlayerCastbarIcon",
	"PetCastbar",
	"PetCastbarIcon",
	"NameplateCastbar",
	"NameplateCastbarIcon",
	"NameplateClassification",
	"TargetCastbarStatic",
	-- Dark Mode
	"DarkMode",
	"DarkModeFrames",
	"DarkModeActionBars",
	"DarkModeMinimap",
	"DarkModeChat",
	"DarkModeCastbars",
	"DarkModeNameplates",
	"DarkModeIconBuffs",
	"DarkModeIconActionBars",
	"DarkModeIconCastbars",
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
	"PlayerCastbarScale",
	"PlayerCastbarX",
	"PlayerCastbarY",
	"PlayerCastbarIconScale",
	"PlayerCastbarIconX",
	"PlayerCastbarIconY",
	"TargetCastbarScale",
	"TargetCastbarX",
	"TargetCastbarY",
	"TargetCastbarIconScale",
	"TargetCastbarIconX",
	"TargetCastbarIconY",
	"PlayerFrameScale",
	"PlayerFrameX",
	"PlayerFrameY",
	"PetFrameScale",
	"PetFrameX",
	"PetFrameY",
	"PetCastbarScale",
	"PetCastbarX",
	"PetCastbarY",
	"PetCastbarIconScale",
	"PetCastbarIconX",
	"PetCastbarIconY",
	"TargetFrameScale",
	"TargetFrameX",
	"TargetFrameY",
	"NameplateScale",
	"NameplateCastbarScale",
	"NameplateCastbarX",
	"NameplateCastbarY",
	"NameplateCastbarIconScale",
	"NameplateCastbarIconX",
	"NameplateCastbarIconY",
}
for _, key in ipairs(cff.VALUES) do
	cff.VALUES[key] = key
end

cff.DEFAULTS.TargetCastbarStatic    = false
cff.DEFAULTS.TargetCastbarIconScale = 1
cff.DEFAULTS.TargetCastbarIconX     = 0
cff.DEFAULTS.TargetCastbarIconY     = 0
cff.DEFAULTS.StatusBarTexture       = "Interface\\AddOns\\cfFrames\\Media\\StatusBar\\BlizzardRetailBarCrop2"
cff.DEFAULTS.DarkModeColor          = 0.25
cff.DEFAULTS.DarkModeColorSecondary = 0.75
cff.DEFAULTS.PlayerCastbarScale     = 1
cff.DEFAULTS.PlayerCastbarX         = 0
cff.DEFAULTS.PlayerCastbarY         = 0
cff.DEFAULTS.PlayerCastbarIconScale = 1
cff.DEFAULTS.PlayerCastbarIconX     = 0
cff.DEFAULTS.PlayerCastbarIconY     = 0
cff.DEFAULTS.TargetCastbarScale     = 1
cff.DEFAULTS.TargetCastbarX         = 0
cff.DEFAULTS.TargetCastbarY         = 0
cff.DEFAULTS.PlayerFrameScale       = 1
cff.DEFAULTS.PlayerFrameX           = 0
cff.DEFAULTS.PlayerFrameY           = 0
cff.DEFAULTS.PetFrameScale          = 1
cff.DEFAULTS.PetFrameX              = 0
cff.DEFAULTS.PetFrameY              = 0
cff.DEFAULTS.PetCastbarScale        = 1
cff.DEFAULTS.PetCastbarX            = 0
cff.DEFAULTS.PetCastbarY            = 0
cff.DEFAULTS.PetCastbarIconScale    = 1
cff.DEFAULTS.PetCastbarIconX        = 0
cff.DEFAULTS.PetCastbarIconY        = 0
cff.DEFAULTS.TargetFrameScale              = 1
cff.DEFAULTS.TargetFrameX                  = 0
cff.DEFAULTS.TargetFrameY                  = 0
cff.DEFAULTS.NameplateScale                = 1
cff.DEFAULTS.NameplateCastbarScale         = 1
cff.DEFAULTS.NameplateCastbarX             = 0
cff.DEFAULTS.NameplateCastbarY             = 0
cff.DEFAULTS.NameplateCastbarIconScale     = 1
cff.DEFAULTS.NameplateCastbarIconX         = 0
cff.DEFAULTS.NameplateCastbarIconY         = 0

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
		cff.EnablePlayerCastbarIcon()
		cff.EnablePetCastbar()
		cff.EnablePetCastbarIcon()
		cff.ApplyNameplateScale()
		cff.EnableNameplateCastbar()
		cff.EnableNameplateCastbarIcon()
		cff.EnableNameplateClassification()
		cff.ApplyPlayerCastbar()
		cff.ApplyPlayerCastbarIcon()
		cff.ApplyTargetCastbar()
		cff.ApplyTargetCastbarIcon()
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
		cff.InitUnitFrameResetFix()
	end)
end)
