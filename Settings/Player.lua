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

	cff.Header(cat, "Castbar")
	cff.Slider(cat, V.PlayerCastbarScale, "Scale", "Player castbar scale", 0.5, 2, 0.05, cff.ApplyPlayerCastbar)
	cff.Slider(cat, V.PlayerCastbarX, "X Offset", "Horizontal offset", -500, 500, 1, cff.ApplyPlayerCastbar)
	cff.Slider(cat, V.PlayerCastbarY, "Y Offset", "Vertical offset", -500, 500, 1, cff.ApplyPlayerCastbar)

	cff.Header(cat, "Castbar Icon")
	cff.Checkbox(cat, M.PlayerCastbarIcon, "Show Castbar Icon", "Show spell icon on player castbar", function()
		if cfFramesDB[M.PlayerCastbarIcon] then
			cff.EnablePlayerCastbarIcon()
		else
			cff.DisablePlayerCastbarIcon()
		end
	end)
	local playerIconSliders = {
		cff.Slider(cat, V.PlayerCastbarIconScale, "Scale", "Castbar icon scale", 0.5, 2, 0.05, cff.ApplyPlayerCastbarIcon),
		cff.Slider(cat, V.PlayerCastbarIconX, "X Offset", "Horizontal offset", -500, 500, 1, cff.ApplyPlayerCastbarIcon),
		cff.Slider(cat, V.PlayerCastbarIconY, "Y Offset", "Vertical offset", -500, 500, 1, cff.ApplyPlayerCastbarIcon),
	}
	for _, slider in ipairs(playerIconSliders) do
		slider:AddShownPredicate(function() return cfFramesDB[M.PlayerCastbarIcon] end)
	end
end
