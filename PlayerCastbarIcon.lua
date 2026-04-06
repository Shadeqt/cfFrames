local function ApplyIcon()
	local icon = CastingBarFrame.Icon
	local h = CastingBarFrame:GetHeight()
	icon:SetSize(h * 2, h * 2)
	icon:ClearAllPoints()
	icon:SetPoint("RIGHT", CastingBarFrame, "LEFT", -10, 2)
	icon:Show()
end

function cff.EnablePlayerCastbarIcon()
	if not cfFramesDB[cff.MODULES.PlayerCastbarIcon] then return end
	if not CastingBarFrame or not CastingBarFrame.Icon then return end

	ApplyIcon()

	if not CastingBarFrame.cffIconHooked then
		CastingBarFrame.cffIconHooked = true
		hooksecurefunc(CastingBarFrame, "Show", function()
			if cfFramesDB[cff.MODULES.PlayerCastbarIcon] then
				ApplyIcon()
				cff.ApplyPlayerCastbarIcon()
			end
		end)
	end
end

function cff.DisablePlayerCastbarIcon()
	if not CastingBarFrame or not CastingBarFrame.Icon then return end
	CastingBarFrame.Icon:Hide()
end
