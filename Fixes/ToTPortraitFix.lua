local _, addon = ...

function addon.SetupToTPortraitFix()
	if not cfFramesDB.ToTPortraitFix then return end
	if not TargetFrameToTPortrait then return end

	local point, relativeTo, relativePoint = TargetFrameToTPortrait:GetPoint()
	TargetFrameToTPortrait:SetPoint(point, relativeTo, relativePoint, 4.5, -5.5)
end
