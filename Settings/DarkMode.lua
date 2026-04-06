local M = cff.MODULES

local function refreshDarkMode()
	if cfFramesDB[M.DarkMode] then
		cff.DisableDarkMode()
		cff.EnableDarkMode()
	end
end

EventUtil.ContinueOnAddOnLoaded("cfFrames", function()
	local sub = Settings.RegisterVerticalLayoutSubcategory(cff.category, "Dark Mode")

	cff.Checkbox(sub, M.DarkMode, "Dark Mode", "Darken UI frame textures", function()
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
			local slider = cff.Slider(sub, key, sl.name, sl.tooltip, 0, 1, 0.05, refreshDarkMode)
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
			local cb = cff.Checkbox(sub, key, toggle.name, toggle.tooltip, refreshDarkMode)
			cb:AddShownPredicate(function() return cfFramesDB[M.DarkMode] end)
		end
	end

	local function refreshIcons()
		cff.DisableDarkModeIcons()
		if cfFramesDB[M.DarkMode] then
			cff.EnableDarkModeIcons()
		end
	end

	cff.Header(sub, "Icons")

	local iconToggles = {
		[M.DarkModeIconBuffs]      = { name = "Buffs",       tooltip = "Borders on player, target, pet, and compact raid buff icons" },
		[M.DarkModeIconActionBars] = { name = "Action Bars",  tooltip = "Borders on action bar, pet bar, stance bar, and bag icons" },
	}
	for _, key in ipairs(M) do
		local toggle = iconToggles[key]
		if toggle then
			local cb = cff.Checkbox(sub, key, toggle.name, toggle.tooltip, refreshIcons)
			cb:AddShownPredicate(function() return cfFramesDB[M.DarkMode] end)
		end
	end
end)
