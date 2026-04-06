function cfFrames.initToTPositionFix()
	if not TargetFrameToT then return end
	local point, relativeTo, relativePoint, x, y = TargetFrameToT:GetPoint()
	--TargetFrameToT:SetPoint(point, relativeTo, relativePoint, x + 15, y)
end
