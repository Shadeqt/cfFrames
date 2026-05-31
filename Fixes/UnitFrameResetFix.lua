local _, addon = ...

local function SaveDefaultPosition(frame)
	local point, relativeTo, relativePoint, x, y = frame:GetPoint()
	frame:SetUserPlaced(true)
	frame:ClearAllPoints()
	frame:SetPoint(point, relativeTo, relativePoint, x, y)
end

function addon.SetupUnitFrameResetFix()
	if not cfFramesDB.UnitFrameResetFix then return end

	hooksecurefunc("PlayerFrame_ResetUserPlacedPosition", function()
		SaveDefaultPosition(PlayerFrame)
	end)

	hooksecurefunc("TargetFrame_ResetUserPlacedPosition", function()
		SaveDefaultPosition(TargetFrame)
	end)
end
