local function AdjustLevel(frame)
	local levelText = frame.LevelFrame and frame.LevelFrame.levelText
	if not levelText then return end
	levelText:ClearAllPoints()
	levelText:SetPoint("CENTER", frame.LevelFrame, "CENTER", -1, -0.5)
end

function cfFrames.initNameplateLevelFix()
	hooksecurefunc("CompactUnitFrame_UpdateLevel", AdjustLevel)
end
