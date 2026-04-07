local M = cff.MODULES
local V = cff.VALUES

function cff.SetupNameplateSettings()
	local cat = cff.nameplateCategory

	cff.Header(cat, "Classification")
	cff.Checkbox(cat, M.NameplateClassification, "Show Classification Icons", "Show elite and rare icons on nameplates", function()
		if cfFramesDB[M.NameplateClassification] then
			cff.EnableNameplateClassification()
		else
			cff.DisableNameplateClassification()
		end
	end)

	cff.Header(cat, "Nameplates")
	cff.Slider(cat, V.NameplateScale, "Scale", "Global nameplate scale", 0.5, 3, 0.05, cff.ApplyNameplateScale)

	local castbarHeader = cff.Header(cat, "Castbar")
	cff.Checkbox(cat, M.NameplateCastbar, "Show Castbars", "Show cast bars on enemy nameplates", function()
		if cfFramesDB[M.NameplateCastbar] then
			cff.EnableNameplateCastbar()
		else
			cff.DisableNameplateCastbar()
		end
	end)
	local castbarSliders = {
		cff.Slider(cat, V.NameplateCastbarScale, "Scale", "Nameplate castbar scale", 0.5, 3, 0.05, cff.ApplyNameplateCastbar),
		cff.Slider(cat, V.NameplateCastbarX, "X Offset", "Horizontal offset", -100, 100, 1, cff.ApplyNameplateCastbar),
		cff.Slider(cat, V.NameplateCastbarY, "Y Offset", "Vertical offset", -100, 100, 1, cff.ApplyNameplateCastbar),
	}
	for _, s in ipairs(castbarSliders) do
		s:AddShownPredicate(function() return cfFramesDB[M.NameplateCastbar] end)
	end

	local iconHeader = cff.Header(cat, "Castbar Icon", function() return cfFramesDB[M.NameplateCastbar] end)
	local iconCheckbox = cff.Checkbox(cat, M.NameplateCastbarIcon, "Show Castbar Icon", "Show spell icon on nameplate castbars", function()
		if cfFramesDB[M.NameplateCastbarIcon] then
			cff.EnableNameplateCastbarIcon()
		else
			cff.DisableNameplateCastbarIcon()
		end
	end)
	iconCheckbox:AddShownPredicate(function() return cfFramesDB[M.NameplateCastbar] end)
	local iconSliders = {
		cff.Slider(cat, V.NameplateCastbarIconScale, "Scale", "Castbar icon scale", 0.5, 3, 0.05, cff.ApplyNameplateCastbarIcon),
		cff.Slider(cat, V.NameplateCastbarIconX, "X Offset", "Horizontal offset", -100, 100, 1, cff.ApplyNameplateCastbarIcon),
		cff.Slider(cat, V.NameplateCastbarIconY, "Y Offset", "Vertical offset", -100, 100, 1, cff.ApplyNameplateCastbarIcon),
	}
	for _, s in ipairs(iconSliders) do
		s:AddShownPredicate(function() return cfFramesDB[M.NameplateCastbar] and cfFramesDB[M.NameplateCastbarIcon] end)
	end
end
