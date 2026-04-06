EventUtil.ContinueOnAddOnLoaded("cfFrames", function()
	local M = cff.MODULES
	local cat = cff.category

	cff.Dropdown(cat, M.StatusBar, "Status Bar Texture", "Choose status bar texture", function()
		local c = Settings.CreateControlTextContainer()
		c:Add("Interface\\TargetingFrame\\UI-StatusBar", "Blizzard")
		c:Add("Interface\\AddOns\\cfFrames\\Media\\StatusBar\\BlizzardRetailBarCrop2", "Retail Bar")
		c:Add("Interface\\AddOns\\cfFrames\\Media\\StatusBar\\DragonflightTexture", "Dragonflight")
		return c:GetData()
	end, function() cff.EnableStatusBar(); cff.RunCallbacks(cff.MODULES.StatusBar) end)

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

	cff.Checkbox(cat, M.PlayerCastbarIcon, "Player Castbar Icon", "Show spell icon on player castbar", function()
		if cfFramesDB[M.PlayerCastbarIcon] then
			cff.EnablePlayerCastbarIcon()
		else
			cff.DisablePlayerCastbarIcon()
		end
	end)

	cff.Checkbox(cat, M.HealthbarColor, "Class Health Colors", "Color health bars by class for players, by reaction for NPCs", function()
		if cfFramesDB[M.HealthbarColor] then
			cff.EnableHealthbarColor()
		else
			cff.DisableHealthbarColor()
		end
	end)

	cff.Header(cat, "Fixes (requires reload)")

	local fixes = {
		[M.ActionBarAlphaFix]         = { name = "Action Bar Alpha Fix",         tooltip = "Reduces action bar button texture alpha to 50%" },
		[M.ToTPortraitFix]            = { name = "ToT Portrait Fix",             tooltip = "Adjusts Target-of-Target portrait position and size" },
		[M.ToTBackgroundFix]          = { name = "ToT Background Fix",           tooltip = "Aligns Target-of-Target background with health and mana bars" },
		[M.TargetCastbarBorderFix]    = { name = "Target Castbar Border Fix",    tooltip = "Widens target castbar border to align properly" },
		[M.TargetNameWidthFix]        = { name = "Target Name Width Fix",        tooltip = "Increases target name text width to reduce truncation" },
		[M.TargetCastbarIconFix]      = { name = "Target Castbar Icon Fix",      tooltip = "Adjusts target castbar icon vertical position" },
		[M.NameplateLevelPositionFix] = { name = "Nameplate Level Position Fix", tooltip = "Centers level text on compact unit frame nameplates" },
		[M.ActionBarIconPositionFix]  = { name = "Action Bar Icon Position Fix", tooltip = "Shifts action bar icons 1px left and down to center in border" },
		[M.PetActionBarCheckedFix]    = { name = "Pet Action Bar Checked Fix",  tooltip = "Aligns pet action button checked texture with icon" },
	}
	for _, key in ipairs(M) do
		local fix = fixes[key]
		if fix then cff.Checkbox(cat, key, fix.name, fix.tooltip) end
	end
end)
