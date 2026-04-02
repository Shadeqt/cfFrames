cfFrames = {}

local M = {}
cfFrames.M = M

M.BlueShamans = "BlueShamans"
M.DarkMode = "DarkMode"
M.CastbarPlayerIcon = "CastbarPlayerIcon"
M.CastbarTargetIcon = "CastbarTargetIcon"
M.CastbarTargetFix = "CastbarTargetFix"
M.NameplateCastbar = "NameplateCastbar"
M.NameplateClassification = "NameplateClassification"
M.StatusText = "StatusText"
M.StatusBarTexture = "StatusBarTexture"
M.HealthbarColor = "HealthbarColor"
M.NameBackground = "NameBackground"
M.DruidBar = "DruidBar"
M.BiggerHealthbar = "BiggerHealthbar"
M.ExperienceBarQuests = "ExperienceBarQuests"
M.HitIndicator = "HitIndicator"
M.CombatGlow = "CombatGlow"
M.IconZoom = "IconZoom"
M.IconBorder = "IconBorder"
M.PetLevel = "PetLevel"
M.PetXpBar = "PetXpBar"
M.PetName = "PetName"
M.PetDebuffs = "PetDebuffs"
M.PetStatusText = "PetStatusText"
M.NameplateLevelFix = "NameplateLevelFix"
M.GroupIndicator = "GroupIndicator"
M.ToTPortraitFix = "ToTPortraitFix"
M.ToTPositionFix = "ToTPositionFix"
M.BuffSorting = "BuffSorting"
M.NameTargetFix = "NameTargetFix"

local DEFAULTS = {}
for _, key in pairs(M) do
	DEFAULTS[key] = true
end
DEFAULTS[M.StatusBarTexture] = "Interface\\AddOns\\cfFrames\\Media\\StatusBar\\BlizzardRetailBarCrop2"
DEFAULTS[M.IconBorder] = "Interface\\Tooltips\\UI-Tooltip-Border"
DEFAULTS[M.DruidBar] = "Interface\\FriendsFrame\\UI-Toast-Border"

local function init()
	local db = cfFramesDB

	if db[M.BlueShamans] then cfFrames.initBlueShamans() end

	-- Style providers first (register into Core registries)
	if db[M.DarkMode] then cfFrames.initDarkMode() end
	if db[M.IconBorder] ~= "blizzard" then cfFrames.initIconBorder() end
	if db[M.IconZoom] then cfFrames.initIconZoom() end
	if db[M.StatusText] then cfFrames.initStatusText() end
	if db[M.StatusBarTexture] ~= "blizzard" then cfFrames.initStatusBarTexture() end

	if cfFrames.InitMovables then cfFrames.InitMovables() end

	-- Then features that consume styles
	if db[M.HealthbarColor] then cfFrames.initHealthbarColor() end
	if db[M.NameBackground] then cfFrames.initNameBackground() end
	if db[M.BiggerHealthbar] then cfFrames.initBiggerHealthbar() end
	if cfFrames.initCastbarPlayerIcon then cfFrames.initCastbarPlayerIcon() end
	if cfFrames.initTargetCastbarIcon then cfFrames.initTargetCastbarIcon() end
	if db[M.CastbarTargetFix] then cfFrames.initCastbarTargetFix() end
	if db[M.NameplateCastbar] then cfFrames.initNameplateCastbar() end
	if db[M.NameplateClassification] then cfFrames.initNameplateClassification() end
	if db[M.DruidBar] ~= "blizzard" and cfFrames.initDruidBar then cfFrames.initDruidBar() end
	if db[M.ExperienceBarQuests] then cfFrames.initExperienceBarQuests() end
	if db[M.HitIndicator] then cfFrames.initHitIndicator() end
	if db[M.CombatGlow] then cfFrames.initCombatGlow() end
	if db[M.PetLevel] then cfFrames.initPetLevel() end
	if db[M.PetXpBar] then cfFrames.initPetXpBar() end
	if db[M.PetName] then cfFrames.initPetName() end
	if db[M.PetDebuffs] then cfFrames.initPetDebuffs() end
	if db[M.PetStatusText] then cfFrames.initPetStatusText() end
	if db[M.NameplateLevelFix] then cfFrames.initNameplateLevelFix() end
	if db[M.GroupIndicator] then cfFrames.initGroupIndicator() end
	if db[M.ToTPortraitFix] then cfFrames.initToTPortraitFix() end
	if db[M.ToTPositionFix] then cfFrames.initToTPositionFix() end
	--if db[M.BuffSorting] then cfFrames.initBuffSorting() end
	--if db[M.NameTargetFix] then cfFrames.initNameTargetFix() end

end

EventUtil.ContinueOnAddOnLoaded("cfFrames", function()
	-- Load saved DB or create a new one
	cfFramesDB = cfFramesDB or {}

	-- Add new keys found in defaults
	for key, value in pairs(DEFAULTS) do
		if cfFramesDB[key] == nil then
			cfFramesDB[key] = value
		end
	end

	-- Remove keys not found in defaults (preserve subtables like elements)
	for key in pairs(cfFramesDB) do
		if DEFAULTS[key] == nil and type(cfFramesDB[key]) ~= "table" then
			cfFramesDB[key] = nil
		end
	end

	init()
end)
