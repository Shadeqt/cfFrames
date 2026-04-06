function cff.EnablePlayerCastbarIcon()
	if not cfFramesDB[cff.MODULES.PlayerCastbarIcon] then return end
	if not CastingBarFrame or not CastingBarFrame.Icon then return end

	local h = CastingBarFrame:GetHeight()
	CastingBarFrame.Icon:SetSize(h * 2, h * 2)
	CastingBarFrame.Icon:ClearAllPoints()
	CastingBarFrame.Icon:SetPoint("RIGHT", CastingBarFrame, "LEFT", -10, 2)
	CastingBarFrame.Icon:Show()
end

function cff.DisablePlayerCastbarIcon()
	if not CastingBarFrame or not CastingBarFrame.Icon then return end
	CastingBarFrame.Icon:Hide()
end
