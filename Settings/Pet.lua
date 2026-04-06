local M = cff.MODULES
local V = cff.VALUES

function cff.SetupPetSettings()
	local cat = cff.petCategory

	cff.Header(cat, "Pet Frame")
	cff.Slider(cat, V.PetFrameScale, "Scale", "Pet frame scale", 0.5, 2, 0.05, cff.ApplyPetFrame)
	cff.Slider(cat, V.PetFrameX, "X Offset", "Horizontal offset", -500, 500, 1, cff.ApplyPetFrame)
	cff.Slider(cat, V.PetFrameY, "Y Offset", "Vertical offset", -500, 500, 1, cff.ApplyPetFrame)

	cff.Header(cat, "Castbar")
	cff.Checkbox(cat, M.PetCastbar, "Show Pet Castbar", "Show cast bar on pet frame", function()
		if cfFramesDB[M.PetCastbar] then
			cff.EnablePetCastbar()
		else
			cff.DisablePetCastbar()
		end
	end)
	local castbarSliders = {
		cff.Slider(cat, V.PetCastbarScale, "Scale", "Pet castbar scale", 0.5, 2, 0.05, cff.ApplyPetCastbar),
		cff.Slider(cat, V.PetCastbarX, "X Offset", "Horizontal offset", -500, 500, 1, cff.ApplyPetCastbar),
		cff.Slider(cat, V.PetCastbarY, "Y Offset", "Vertical offset", -500, 500, 1, cff.ApplyPetCastbar),
	}
	for _, slider in ipairs(castbarSliders) do
		slider:AddShownPredicate(function() return cfFramesDB[M.PetCastbar] end)
	end

	cff.Header(cat, "Castbar Icon", function() return cfFramesDB[M.PetCastbar] end)
	local iconCheckbox = cff.Checkbox(cat, M.PetCastbarIcon, "Show Castbar Icon", "Show spell icon on pet castbar", function()
		if cfFramesDB[M.PetCastbarIcon] then
			cff.EnablePetCastbarIcon()
		else
			cff.DisablePetCastbarIcon()
		end
	end)
	iconCheckbox:AddShownPredicate(function() return cfFramesDB[M.PetCastbar] end)
	local iconSliders = {
		cff.Slider(cat, V.PetCastbarIconScale, "Scale", "Pet castbar icon scale", 0.5, 2, 0.05, cff.ApplyPetCastbarIcon),
		cff.Slider(cat, V.PetCastbarIconX, "X Offset", "Horizontal offset", -500, 500, 1, cff.ApplyPetCastbarIcon),
		cff.Slider(cat, V.PetCastbarIconY, "Y Offset", "Vertical offset", -500, 500, 1, cff.ApplyPetCastbarIcon),
	}
	for _, slider in ipairs(iconSliders) do
		slider:AddShownPredicate(function() return cfFramesDB[M.PetCastbar] and cfFramesDB[M.PetCastbarIcon] end)
	end
end
