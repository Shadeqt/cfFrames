local _, addon = ...

function addon.SetupNameplateLevelPositionFix()
	if not cfFramesDB.NameplateLevelPositionFix then return end

	hooksecurefunc("CompactUnitFrame_UpdateLevel", function(frame)
		local levelText = frame.LevelFrame and frame.LevelFrame.levelText
		if not levelText then return end
		levelText:ClearAllPoints()
		levelText:SetPoint("CENTER", frame.LevelFrame, "CENTER", -1, -0.5)
	end)
end
