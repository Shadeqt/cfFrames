local M = cff.MODULES
local V = cff.VALUES

function cff.SetupTargetSettings()
	local cat = cff.targetCategory

	cff.Header(cat, "Target Frame")
	cff.Slider(cat, V.TargetFrameScale, "Scale", "Target frame scale", 0.5, 2, 0.05, cff.ApplyTargetFrame)
	cff.Slider(cat, V.TargetFrameX, "X Offset", "Horizontal offset", -500, 500, 1, cff.ApplyTargetFrame)
	cff.Slider(cat, V.TargetFrameY, "Y Offset", "Vertical offset", -500, 500, 1, cff.ApplyTargetFrame)
	cff.InfoText(cat, function()
		local x = math.floor(TargetFrame:GetLeft() + 0.5)
		local y = math.floor(TargetFrame:GetTop() - UIParent:GetTop() + 0.5)
		return format("Position: %d, %d", x, y)
	end)

	cff.Header(cat, "Castbar")
	cff.Checkbox(cat, M.TargetCastbarStatic, "Static Position", "Lock castbar position, ignore buff/debuff repositioning", cff.ApplyTargetCastbar)
	cff.Slider(cat, V.TargetCastbarScale, "Scale", "Target castbar scale", 0.5, 2, 0.05, cff.ApplyTargetCastbar)
	cff.Slider(cat, V.TargetCastbarX, "X Offset", "Horizontal offset", -500, 500, 1, cff.ApplyTargetCastbar)
	cff.Slider(cat, V.TargetCastbarY, "Y Offset", "Vertical offset", -500, 500, 1, cff.ApplyTargetCastbar)

	cff.Header(cat, "Castbar Icon")
	cff.Slider(cat, V.TargetCastbarIconScale, "Scale", "Target castbar icon scale", 0.5, 2, 0.05, cff.ApplyTargetCastbarIcon)
	cff.Slider(cat, V.TargetCastbarIconX, "X Offset", "Horizontal offset", -500, 500, 1, cff.ApplyTargetCastbarIcon)
	cff.Slider(cat, V.TargetCastbarIconY, "Y Offset", "Vertical offset", -500, 500, 1, cff.ApplyTargetCastbarIcon)
end
