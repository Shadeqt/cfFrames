local icon

local function GetCurrentSpellIcon()
	local _, _, texture = UnitCastingInfo("player")
	if not texture then
		_, _, texture = UnitChannelInfo("player")
	end
	return texture
end

local function UpdateIcon()
	local iconTexture = GetCurrentSpellIcon()
	if iconTexture then
		icon:SetTexture(iconTexture)
		icon:Show()
	else
		icon:Hide()
	end
end

local function CreateIcon()
	local iconSize = CastingBarFrame:GetHeight() * 2
	icon = CastingBarFrame:CreateTexture(nil, "ARTWORK")
	icon:SetSize(iconSize, iconSize)
	icon:SetPoint("RIGHT", CastingBarFrame, "LEFT", -10, 2.5)
	icon:Hide()
	cfFrames.styleIcon(icon)
end

local function HookCastbar()
	hooksecurefunc(CastingBarFrame, "Show", UpdateIcon)
	CastingBarFrame:HookScript("OnHide", function()
		icon:Hide()
	end)
end

function cfFrames.initCastbarPlayerIcon()
	if not CastingBarFrame then return end
	CreateIcon()
	HookCastbar()
end
