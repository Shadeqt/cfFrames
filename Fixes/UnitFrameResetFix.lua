local function saveDefaultPosition(frame)
	local p, rt, rp, x, y = frame:GetPoint()
	frame:SetUserPlaced(true)
	frame:ClearAllPoints()
	frame:SetPoint(p, rt, rp, x, y)
end

function cff.InitUnitFrameResetFix()
	if not cfFramesDB[cff.MODULES.UnitFrameResetFix] then return end

	hooksecurefunc("PlayerFrame_ResetUserPlacedPosition", function()
		saveDefaultPosition(PlayerFrame)
	end)

	hooksecurefunc("TargetFrame_ResetUserPlacedPosition", function()
		saveDefaultPosition(TargetFrame)
	end)
end
