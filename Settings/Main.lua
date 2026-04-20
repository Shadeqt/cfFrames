local M = cff.MODULES
local V = cff.VALUES

function cff.SetupSettings()
	local cat = cff.category

	-- General
	cff.Checkbox(cat, M.StatusBar, "Custom Status Bar Texture", "Replace default status bar textures", function()
		cff.EnableStatusBar()
		cff.RunCallbacks(M.StatusBar)
	end)

	local SB = "Interface\\AddOns\\cfFrames\\Media\\StatusBar\\"
	local dd = cff.Dropdown(cat, V.StatusBarTexture, "Status Bar Texture", "Choose status bar texture", function()
		local c = Settings.CreateControlTextContainer()
		c:Add(SB .. "BlizzardRetailBarCrop2",    "Retail Bar Crop 2")
		c:Add(SB .. "BlizzardRetailBarCrop",     "Retail Bar Crop")
		c:Add(SB .. "BlizzardRetailBar",         "Retail Bar")
		c:Add(SB .. "DragonflightTexture",       "Dragonflight")
		c:Add(SB .. "DragonflightTextureHD",     "Dragonflight HD")
		c:Add(SB .. "smooth",                    "Smooth")
		c:Add(SB .. "ui-statusbar-cf",           "CF Status Bar")
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


	-- Subcategories
	cff.darkModeCategory = Settings.RegisterVerticalLayoutSubcategory(cat, "Dark Mode")
	local fixes = Settings.RegisterVerticalLayoutSubcategory(cat, "Fixes")
	cff.playerCategory = Settings.RegisterVerticalLayoutSubcategory(cat, "Player")
	cff.petCategory = Settings.RegisterVerticalLayoutSubcategory(cat, "Pet")
	cff.targetCategory = Settings.RegisterVerticalLayoutSubcategory(cat, "Target")
	cff.nameplateCategory = Settings.RegisterVerticalLayoutSubcategory(cat, "Nameplates")

	cff.Header(fixes, "Fixes (requires reload)")

	local fixToggles = {
		[M.ActionBarAlphaFix]         = { name = "Action Bar Alpha Fix",         tooltip = "Reduces action bar button texture alpha to 50%" },
		[M.ToTPortraitFix]            = { name = "ToT Portrait Fix",             tooltip = "Adjusts Target-of-Target portrait position and size" },
		[M.ToTBackgroundFix]          = { name = "ToT Background Fix",           tooltip = "Aligns Target-of-Target background with health and mana bars" },
		[M.TargetNameWidthFix]        = { name = "Target Name Width Fix",        tooltip = "Increases target name text width to reduce truncation" },
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
