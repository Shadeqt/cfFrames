local M = cfFrames.M

EventUtil.ContinueOnAddOnLoaded("cfFrames", function()
	local category = Settings.RegisterVerticalLayoutCategory("cfFrames (New)")

	local function AddCheckbox(cat, variable, dbKey, label, tooltip)
		local setting = Settings.RegisterAddOnSetting(
			cat, variable, dbKey, cfFramesDB,
			Settings.VarType.Boolean, label, Settings.Default.True
		)
		Settings.CreateCheckbox(cat, setting, tooltip)
		return setting
	end

	local function AddDropdown(cat, variable, dbKey, label, default, options, tooltip)
		local setting = Settings.RegisterAddOnSetting(
			cat, variable, dbKey, cfFramesDB,
			Settings.VarType.String, label, default
		)
		Settings.CreateDropdown(cat, setting, options, tooltip)
		return setting
	end

	-- Main category: Fixes + General
	AddCheckbox(category, "CFF_NAMEPLATE_LEVEL_FIX", M.NameplateLevelFix, "Nameplate Level Fix", "Adjust nameplate level text position")
	AddCheckbox(category, "CFF_CASTBAR_TARGET_FIX", M.CastbarTargetFix, "Target Castbar Fix", "Widen target castbar border")
	AddCheckbox(category, "CFF_TOT_PORTRAIT_FIX", M.ToTPortraitFix, "ToT Portrait Fix", "Fix Target of Target portrait alignment")
	AddCheckbox(category, "CFF_NAME_TARGET_FIX", M.NameTargetFix, "Target Name Fix", "Widen target name to reduce truncation")

	AddDropdown(category, "CFF_DRUID_BAR", M.DruidBar, "Druid Bar",
		"Interface\\FriendsFrame\\UI-Toast-Border",
		function()
			local c = Settings.CreateControlTextContainer()
			c:Add("blizzard", "Blizzard")
			c:Add("Interface\\FriendsFrame\\UI-Toast-Border", "Toast")
			c:Add("Interface\\DialogFrame\\UI-DialogBox-Border", "Dialog")
			return c:GetData()
		end,
		"Choose druid mana bar border"
	)

	-- Subcategory: Unit Frames
	local unitFrames = Settings.RegisterVerticalLayoutSubcategory(category, "Unit Frames")

	AddDropdown(unitFrames, "CFF_STATUS_BAR_TEXTURE", M.StatusBarTexture, "Status Bar Texture",
		"Interface\\AddOns\\cfFrames\\Media\\StatusBar\\BlizzardRetailBarCrop2",
		function()
			local c = Settings.CreateControlTextContainer()
			c:Add("blizzard", "Blizzard")
			c:Add("Interface\\AddOns\\cfFrames\\Media\\StatusBar\\BlizzardRetailBarCrop2", "Retail Bar")
			c:Add("Interface\\AddOns\\cfFrames\\Media\\StatusBar\\DragonflightTexture", "Dragonflight")
			return c:GetData()
		end,
		"Choose status bar texture"
	)

	AddCheckbox(unitFrames, "CFF_BIGGER_HEALTHBAR", M.BiggerHealthbar, "Bigger Healthbars", "Enlarge player and target health bars")
	AddCheckbox(unitFrames, "CFF_HEALTHBAR_COLOR", M.HealthbarColor, "Healthbar Color", "Class-colored health bars")
	AddCheckbox(unitFrames, "CFF_HIT_INDICATOR", M.HitIndicator, "Hide Hit Indicator", "Hide hit text on player and pet")
	AddCheckbox(unitFrames, "CFF_COMBAT_GLOW", M.CombatGlow, "Hide Combat Glow", "Hide combat glow on player and pet")
	AddCheckbox(unitFrames, "CFF_NAME_BACKGROUND", M.NameBackground, "Hide Name Background", "Hide the target name background")
	AddCheckbox(unitFrames, "CFF_GROUP_INDICATOR", M.GroupIndicator, "Hide Group Indicator", "Hide group number on player frame")

	-- Subcategory: Nameplates
	local nameplates = Settings.RegisterVerticalLayoutSubcategory(category, "Nameplates")

	AddCheckbox(nameplates, "CFF_NAMEPLATE_CASTBAR", M.NameplateCastbar, "Nameplate Castbar", "Show cast bars on nameplates")
	AddCheckbox(nameplates, "CFF_NAMEPLATE_CLASSIFICATION", M.NameplateClassification, "Classification Icons", "Show elite/rare icons on nameplates")

	-- Subcategory: Castbars
	local castbars = Settings.RegisterVerticalLayoutSubcategory(category, "Castbars")

	AddCheckbox(castbars, "CFF_CASTBAR_PLAYER_ICON", M.CastbarPlayerIcon, "Player Castbar Icon", "Show spell icon on player cast bar")

	-- Subcategory: Pet
	local pet = Settings.RegisterVerticalLayoutSubcategory(category, "Pet")

	AddCheckbox(pet, "CFF_PET_LEVEL", M.PetLevel, "Pet Level", "Show pet level when different from player")
	AddCheckbox(pet, "CFF_PET_XP_BAR", M.PetXpBar, "Pet XP Bar", "Show pet experience bar")
	AddCheckbox(pet, "CFF_PET_NAME", M.PetName, "Pet Name", "Reposition pet name above health bar")
	AddCheckbox(pet, "CFF_PET_DEBUFFS", M.PetDebuffs, "Pet Debuffs", "Show debuff icons on pet frame")

	Settings.RegisterAddOnCategory(category)
end)
