function cff.InitToTBackgroundFix()
	if not cfFramesDB[cff.MODULES.ToTBackgroundFix] then return end
	if not TargetFrameToTBackground then return end

	TargetFrameToTBackground:ClearAllPoints()
	TargetFrameToTBackground:SetPoint("TOPLEFT", TargetFrameToTHealthBar, "TOPLEFT", 0, 0)
	TargetFrameToTBackground:SetPoint("BOTTOMRIGHT", TargetFrameToTManaBar, "BOTTOMRIGHT", 0, 0)
end
