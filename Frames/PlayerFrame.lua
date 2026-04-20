local V = cff.VALUES

-- Save position on drag stop
PlayerFrame:HookScript("OnDragStop", function(self)
	local p, _, rp, x, y = self:GetPoint()
	cfFramesDB.PlayerFramePos = { p, rp, x, y }
end)

-- Clear saved position on reset
hooksecurefunc("PlayerFrame_ResetUserPlacedPosition", function()
	cfFramesDB.PlayerFramePos = false
end)

function cff.ApplyPlayerFrame()
	PlayerFrame:SetScale(cfFramesDB[V.PlayerFrameScale])
	local pos = cfFramesDB.PlayerFramePos
	if pos then
		PlayerFrame:ClearAllPoints()
		PlayerFrame:SetPoint(pos[1], UIParent, pos[2], pos[3] + cfFramesDB[V.PlayerFrameX], pos[4] + cfFramesDB[V.PlayerFrameY])
		PlayerFrame:SetUserPlaced(true)
	elseif cfFramesDB[V.PlayerFrameX] ~= 0 or cfFramesDB[V.PlayerFrameY] ~= 0 then
		local p, _, rp, x, y = PlayerFrame:GetPoint()
		if p then
			PlayerFrame:ClearAllPoints()
			PlayerFrame:SetPoint(p, UIParent, rp, (x or 0) + cfFramesDB[V.PlayerFrameX], (y or 0) + cfFramesDB[V.PlayerFrameY])
		end
	end
end
