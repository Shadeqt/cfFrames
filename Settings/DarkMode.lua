local M = cff.MODULES
local V = cff.VALUES

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

function cff.SetupDarkModeSettings()
	local cat = cff.darkModeCategory

	cff.Checkbox(cat, M.DarkMode, "Dark Mode", "Darken UI frame textures", function()
		if cfFramesDB[M.DarkMode] then
			cff.EnableDarkMode()
		else
			cff.DisableDarkMode()
		end
	end)

	local dmColor = cff.Slider(cat, V.DarkModeColor, "Dark Mode Color", "Darkness level (0 = black, 1 = white)", 0, 1, 0.05, refreshDarkMode)
	dmColor:AddShownPredicate(function() return cfFramesDB[M.DarkMode] end)
	local dmSecondary = cff.Slider(cat, V.DarkModeColorSecondary, "Secondary Color", "Small elements without a separate border (0 = black, 1 = white)", 0, 1, 0.05, refreshDarkMode)
	dmSecondary:AddShownPredicate(function() return cfFramesDB[M.DarkMode] end)

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
end
