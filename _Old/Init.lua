cfFrames = {}

local M = {}
cfFrames.M = M

M.CastbarPlayerIcon = "CastbarPlayerIcon"
M.CastbarTargetIcon = "CastbarTargetIcon"
M.CastbarTargetFix = "CastbarTargetFix"
M.NameplateCastbar = "NameplateCastbar"
M.NameplateClassification = "NameplateClassification"
M.StatusBarTexture = "StatusBarTexture"
M.HealthbarColor = "HealthbarColor"
M.NameBackground = "NameBackground"
M.DruidBar = "DruidBar"
M.BiggerHealthbar = "BiggerHealthbar"
M.HitIndicator = "HitIndicator"
M.CombatGlow = "CombatGlow"
M.PetLevel = "PetLevel"
M.PetXpBar = "PetXpBar"
M.PetName = "PetName"
M.PetDebuffs = "PetDebuffs"
M.GroupIndicator = "GroupIndicator"
M.ToTPortraitFix = "ToTPortraitFix"
M.ToTPositionFix = "ToTPositionFix"
M.BuffSorting = "BuffSorting"
M.NameTargetFix = "NameTargetFix"
M.NameplateLevelFix = "NameplateLevelFix"

local DEFAULTS = {}
for _, key in pairs(M) do
	DEFAULTS[key] = true
end
DEFAULTS[M.StatusBarTexture] = "Interface\\AddOns\\cfFrames\\Media\\StatusBar\\BlizzardRetailBarCrop2"
DEFAULTS[M.DruidBar] = "Interface\\FriendsFrame\\UI-Toast-Border"

local function init()
	local db = cfFramesDB

	if db[M.StatusBarTexture] ~= "blizzard" then cfFrames.initStatusBarTexture() end
	if cfFrames.InitMovables then cfFrames.InitMovables() end

	if db[M.HealthbarColor] then cfFrames.initHealthbarColor() end
	if db[M.NameBackground] then cfFrames.initNameBackground() end
	if db[M.BiggerHealthbar] then cfFrames.initBiggerHealthbar() end
	if cfFrames.initCastbarPlayerIcon then cfFrames.initCastbarPlayerIcon() end
	if cfFrames.initTargetCastbarIcon then cfFrames.initTargetCastbarIcon() end
	if db[M.NameplateCastbar] then cfFrames.initNameplateCastbar() end
	if db[M.NameplateClassification] then cfFrames.initNameplateClassification() end
	if db[M.DruidBar] ~= "blizzard" and cfFrames.initDruidBar then cfFrames.initDruidBar() end
	if db[M.HitIndicator] then cfFrames.initHitIndicator() end
	if db[M.CombatGlow] then cfFrames.initCombatGlow() end
	if db[M.PetLevel] then cfFrames.initPetLevel() end
	if db[M.PetXpBar] then cfFrames.initPetXpBar() end
	if db[M.PetName] then cfFrames.initPetName() end
	if db[M.PetDebuffs] then cfFrames.initPetDebuffs() end
	if db[M.GroupIndicator] then cfFrames.initGroupIndicator() end
	if db[M.ToTPositionFix] then cfFrames.initToTPositionFix() end
	--if db[M.BuffSorting] then cfFrames.initBuffSorting() end

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
