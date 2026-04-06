function cff.InitToTPortraitFix()
	if not cfFramesDB[cff.MODULES.ToTPortraitFix] then return end
	if not TargetFrameToTPortrait then return end

	local a, b, c = TargetFrameToTPortrait:GetPoint()
	TargetFrameToTPortrait:SetPoint(a, b, c, 4.5, -5.5)
end
