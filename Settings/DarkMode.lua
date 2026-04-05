EventUtil.ContinueOnAddOnLoaded("cfFrames", function()
	local M = cff.MODULES
	local d = cff.DEFAULTS
	local subcategory = Settings.RegisterVerticalLayoutSubcategory(cff.category, "Dark Mode")

	local function refreshDarkMode()
		if cfFramesDB[M.DarkMode] then
			cff.DisableDarkMode()
			cff.EnableDarkMode()
		end
	end

	local setting = Settings.RegisterAddOnSetting(
		subcategory, M.DarkMode, M.DarkMode, cfFramesDB,
		Settings.VarType.Boolean, "Dark Mode", d[M.DarkMode]
	)
	Settings.CreateCheckbox(subcategory, setting, "Darken UI frame textures")
	Settings.SetOnValueChangedCallback(M.DarkMode, function()
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
			local s = Settings.RegisterAddOnSetting(subcategory, key, key, cfFramesDB, Settings.VarType.Number, sl.name, d[key])
			local opts = Settings.CreateSliderOptions(0, 1, 0.05)
			opts:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return format("%.2f", value) end)
			local slider = Settings.CreateSlider(subcategory, s, opts, sl.tooltip)
			slider:AddShownPredicate(function() return cfFramesDB[M.DarkMode] end)
			Settings.SetOnValueChangedCallback(key, refreshDarkMode)
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
			local s = Settings.RegisterAddOnSetting(subcategory, key, key, cfFramesDB, Settings.VarType.Boolean, toggle.name, d[key])
			local cb = Settings.CreateCheckbox(subcategory, s, toggle.tooltip)
			cb:AddShownPredicate(function() return cfFramesDB[M.DarkMode] end)
			Settings.SetOnValueChangedCallback(key, refreshDarkMode)
		end
	end

end)
