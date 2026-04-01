function cfFrames.initToTPortraitFix()
	if not TargetFrameToTPortrait then return end
	local a, b, c = TargetFrameToTPortrait:GetPoint()
	TargetFrameToTPortrait:SetPoint(a, b, c, 4, -4)

	local w, h = TargetFrameToTPortrait:GetSize()
	TargetFrameToTPortrait:SetSize(w + 2, h + 2)

end
