local M = cff.MODULES
local V = cff.VALUES

function cff.SetupPetSettings()
	local cat = cff.petCategory

	cff.Header(cat, "Pet Frame")
	cff.Slider(cat, V.PetFrameScale, "Scale", "Pet frame scale", 0.5, 2, 0.05, cff.ApplyPetFrame)
	cff.Slider(cat, V.PetFrameX, "X Offset", "Horizontal offset", -500, 500, 1, cff.ApplyPetFrame)
	cff.Slider(cat, V.PetFrameY, "Y Offset", "Vertical offset", -500, 500, 1, cff.ApplyPetFrame)
end
