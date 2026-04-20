local M = cff.MODULES
local V = cff.VALUES

function cff.SetupPlayerSettings()
	local cat = cff.playerCategory

	cff.Header(cat, "Player Frame")
	cff.Slider(cat, V.PlayerFrameScale, "Scale", "Player frame scale", 0.5, 2, 0.05, cff.ApplyPlayerFrame)
	cff.Slider(cat, V.PlayerFrameX, "X Offset", "Horizontal offset", -500, 500, 1, cff.ApplyPlayerFrame)
	cff.Slider(cat, V.PlayerFrameY, "Y Offset", "Vertical offset", -500, 500, 1, cff.ApplyPlayerFrame)
	cff.InfoText(cat, function()
		local x = math.floor(PlayerFrame:GetLeft() + 0.5)
		local y = math.floor(PlayerFrame:GetTop() - UIParent:GetTop() + 0.5)
		return format("Position: %d, %d", x, y)
	end)
end
