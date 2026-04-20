local V = cff.VALUES

-- Save position on drag stop
TargetFrame:HookScript("OnDragStop", function(self)
	local p, _, rp, x, y = self:GetPoint()
	cfFramesDB.TargetFramePos = { p, rp, x, y }
end)

-- Clear saved position on reset
hooksecurefunc("TargetFrame_ResetUserPlacedPosition", function()
	cfFramesDB.TargetFramePos = false
end)

function cff.ApplyTargetFrame()
	TargetFrame:SetScale(cfFramesDB[V.TargetFrameScale])
	local pos = cfFramesDB.TargetFramePos
	if pos then
		TargetFrame:ClearAllPoints()
		TargetFrame:SetPoint(pos[1], UIParent, pos[2], pos[3] + cfFramesDB[V.TargetFrameX], pos[4] + cfFramesDB[V.TargetFrameY])
		TargetFrame:SetUserPlaced(true)
	elseif cfFramesDB[V.TargetFrameX] ~= 0 or cfFramesDB[V.TargetFrameY] ~= 0 then
		local p, _, rp, x, y = TargetFrame:GetPoint()
		if p then
			TargetFrame:ClearAllPoints()
			TargetFrame:SetPoint(p, UIParent, rp, (x or 0) + cfFramesDB[V.TargetFrameX], (y or 0) + cfFramesDB[V.TargetFrameY])
		end
	end
end
