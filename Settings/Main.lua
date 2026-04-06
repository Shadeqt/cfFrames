local M = cff.MODULES
local V = cff.VALUES

function cff.SetupSettings()
	local cat = cff.category

	-- General
	cff.Checkbox(cat, M.StatusBar, "Custom Status Bar Texture", "Replace default status bar textures", function()
		cff.EnableStatusBar()
		cff.RunCallbacks(M.StatusBar)
	end)

	local dd = cff.Dropdown(cat, V.StatusBarTexture, "Status Bar Texture", "Choose status bar texture", function()
		local c = Settings.CreateControlTextContainer()
		c:Add("Interface\\AddOns\\cfFrames\\Media\\StatusBar\\BlizzardRetailBarCrop2", "Retail Bar")
		c:Add("Interface\\AddOns\\cfFrames\\Media\\StatusBar\\DragonflightTexture", "Dragonflight")
		return c:GetData()
	end, function() cff.EnableStatusBar(); cff.RunCallbacks(M.StatusBar) end)
	dd:AddShownPredicate(function() return cfFramesDB[M.StatusBar] end)

	cff.Checkbox(cat, M.BiggerHealthbar, "Bigger Health Bars", "Enlarge player and target health bars", function()
		if cfFramesDB[M.BiggerHealthbar] then
			cff.EnableBiggerHealthbar()
		else
			cff.DisableBiggerHealthbar()
		end
	end)

	cff.Checkbox(cat, M.NameplateCastbar, "Nameplate Castbars", "Show cast bars on enemy nameplates", function()
		if cfFramesDB[M.NameplateCastbar] then
			cff.EnableNameplateCastbar()
		else
			cff.DisableNameplateCastbar()
		end
	end)

	cff.Header(cat, "Class Health Colors")

	cff.Checkbox(cat, M.HealthbarColor, "Unit Frames", "Color player, target, party health bars by class", function()
		if cfFramesDB[M.HealthbarColor] then
			cff.EnableHealthbarColor()
		else
			cff.DisableHealthbarColor()
		end
	end)

	cff.Checkbox(cat, M.HealthbarColorRaid, "Raid Frames", "Color compact raid frame health bars by class", function()
		cff.SyncHealthbarCVars()
	end)

	cff.Checkbox(cat, M.HealthbarColorNameplateEnemy, "Enemy Nameplates", "Color enemy nameplate health bars by class (requires reload)", function()
		cff.SyncHealthbarCVars()
		StaticPopup_Show("CFF_RELOAD_UI")
	end)

	cff.Checkbox(cat, M.HealthbarColorNameplateFriendly, "Friendly Nameplates", "Color friendly nameplate health bars by class (requires reload)", function()
		cff.SyncHealthbarCVars()
		StaticPopup_Show("CFF_RELOAD_UI")
	end)

	-- Subcategories
	cff.darkModeCategory = Settings.RegisterVerticalLayoutSubcategory(cat, "Dark Mode")
	local fixes = Settings.RegisterVerticalLayoutSubcategory(cat, "Fixes")
	cff.playerCategory = Settings.RegisterVerticalLayoutSubcategory(cat, "Player")
	cff.petCategory = Settings.RegisterVerticalLayoutSubcategory(cat, "Pet")
	cff.targetCategory = Settings.RegisterVerticalLayoutSubcategory(cat, "Target")

	cff.Header(fixes, "Fixes (requires reload)")

	local fixToggles = {
		[M.ActionBarAlphaFix]         = { name = "Action Bar Alpha Fix",         tooltip = "Reduces action bar button texture alpha to 50%" },
		[M.ToTPortraitFix]            = { name = "ToT Portrait Fix",             tooltip = "Adjusts Target-of-Target portrait position and size" },
		[M.ToTBackgroundFix]          = { name = "ToT Background Fix",           tooltip = "Aligns Target-of-Target background with health and mana bars" },
		[M.TargetCastbarBorderFix]    = { name = "Target Castbar Border Fix",    tooltip = "Widens target castbar border to align properly" },
		[M.TargetNameWidthFix]        = { name = "Target Name Width Fix",        tooltip = "Increases target name text width to reduce truncation" },
		[M.TargetCastbarIconFix]      = { name = "Target Castbar Icon Fix",      tooltip = "Adjusts target castbar icon vertical position" },
		[M.NameplateLevelPositionFix] = { name = "Nameplate Level Position Fix", tooltip = "Centers level text on compact unit frame nameplates" },
		[M.ActionBarIconPositionFix]  = { name = "Action Bar Icon Position Fix", tooltip = "Shifts action bar icons 1px left and down to center in border" },
		[M.PetActionBarCheckedFix]    = { name = "Pet Action Bar Checked Fix",  tooltip = "Aligns pet action button checked texture with icon" },
		[M.UnitFrameResetFix]         = { name = "Unit Frame Reset Fix",       tooltip = "Makes reset-to-default position persist on reload for player and target frames" },
	}
	for _, key in ipairs(M) do
		local fix = fixToggles[key]
		if fix then cff.Checkbox(fixes, key, fix.name, fix.tooltip) end
	end
end
