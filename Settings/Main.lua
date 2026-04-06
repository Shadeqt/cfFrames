local M = cff.MODULES

local function refreshDarkMode()
	if cfFramesDB[M.DarkMode] then
		cff.DisableDarkMode()
		cff.EnableDarkMode()
	end
end

local function refreshIcons()
	cff.DisableDarkModeIcons()
	if cfFramesDB[M.DarkMode] then
		cff.EnableDarkModeIcons()
	end
end

function cff.SetupSettings()
	local cat = cff.category

	-- General
	cff.Checkbox(cat, M.StatusBar, "Custom Status Bar Texture", "Replace default status bar textures", function()
		cff.EnableStatusBar()
		cff.RunCallbacks(M.StatusBar)
	end)

	local dd = cff.Dropdown(cat, M.StatusBarTexture, "Status Bar Texture", "Choose status bar texture", function()
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

	cff.Checkbox(cat, M.PlayerCastbarIcon, "Player Castbar Icon", "Show spell icon on player castbar", function()
		if cfFramesDB[M.PlayerCastbarIcon] then
			cff.EnablePlayerCastbarIcon()
		else
			cff.DisablePlayerCastbarIcon()
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

	-- Dark Mode
	cff.Header(cat, "Dark Mode")

	cff.Checkbox(cat, M.DarkMode, "Dark Mode", "Darken UI frame textures", function()
		if cfFramesDB[M.DarkMode] then
			cff.EnableDarkMode()
		else
			cff.DisableDarkMode()
		end
	end)

	local sliders = {
		[M.DarkModeColor]          = { name = "Dark Mode Color", tooltip = "Darkness level (0 = black, 1 = white)" },
		[M.DarkModeColorSecondary] = { name = "Secondary Color", tooltip = "Small elements without a separate border (0 = black, 1 = white)" },
	}
	for _, key in ipairs(M) do
		local sl = sliders[key]
		if sl then
			local slider = cff.Slider(cat, key, sl.name, sl.tooltip, 0, 1, 0.05, refreshDarkMode)
			slider:AddShownPredicate(function() return cfFramesDB[M.DarkMode] end)
		end
	end

	local toggles = {
		[M.DarkModeFrames]     = { name = "Unit Frames", tooltip = "Player, target, pet, party, compact raid frames" },
		[M.DarkModeActionBars] = { name = "Action Bars", tooltip = "Action buttons, bag slots, menu bar" },
		[M.DarkModeMinimap]    = { name = "Minimap",     tooltip = "Minimap borders, zoom buttons, addon icons" },
		[M.DarkModeChat]       = { name = "Chat",        tooltip = "Chat edit box and tab textures" },
		[M.DarkModeCastbars]   = { name = "Castbars",    tooltip = "Player and target castbar borders" },
		[M.DarkModeNameplates] = { name = "Nameplates",  tooltip = "Nameplate health bar borders" },
	}
	for _, key in ipairs(M) do
		local toggle = toggles[key]
		if toggle then
			local cb = cff.Checkbox(cat, key, toggle.name, toggle.tooltip, refreshDarkMode)
			cb:AddShownPredicate(function() return cfFramesDB[M.DarkMode] end)
		end
	end

	cff.Header(cat, "Icons", function() return cfFramesDB[M.DarkMode] end)

	local iconToggles = {
		[M.DarkModeIconBuffs]      = { name = "Buffs",       tooltip = "Borders on player, target, pet, and compact raid buff icons" },
		[M.DarkModeIconActionBars] = { name = "Action Bars",  tooltip = "Borders on action bar, pet bar, stance bar, and bag icons" },
	}
	for _, key in ipairs(M) do
		local toggle = iconToggles[key]
		if toggle then
			local cb = cff.Checkbox(cat, key, toggle.name, toggle.tooltip, refreshIcons)
			cb:AddShownPredicate(function() return cfFramesDB[M.DarkMode] end)
		end
	end

	-- Fixes
	local fixes = Settings.RegisterVerticalLayoutSubcategory(cat, "Fixes")

	-- Player
	local player = Settings.RegisterVerticalLayoutSubcategory(cat, "Player")
	cff.Header(player, "Player Frame")

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
	}
	for _, key in ipairs(M) do
		local fix = fixToggles[key]
		if fix then cff.Checkbox(fixes, key, fix.name, fix.tooltip) end
	end
end
