local icon
local DEFAULT_X = -10
local DEFAULT_Y = 2.5
local defaultSize

local function GetCurrentSpellIcon()
	local _, _, texture = UnitCastingInfo("player")
	if not texture then
		_, _, texture = UnitChannelInfo("player")
	end
	return texture
end

local function SetIconVisible(visible)
	if visible then
		icon:Show()
	else
		icon:Hide()
	end
	local border = CastingBarFrame.cfIconBorder
	if border then
		if visible then border:Show() else border:Hide() end
	end
end

local function UpdateIcon()
	if not cfFramesDB[cfFrames.M.CastbarPlayerIcon] then
		SetIconVisible(false)
		return
	end
	local iconTexture = GetCurrentSpellIcon()
	if iconTexture then
		icon:SetTexture(iconTexture)
		SetIconVisible(true)
	else
		SetIconVisible(false)
	end
end

local function CreateIcon()
	defaultSize = CastingBarFrame:GetHeight() * 2
	icon = CastingBarFrame:CreateTexture(nil, "ARTWORK")
	icon:SetSize(defaultSize, defaultSize)
	icon:SetPoint("RIGHT", CastingBarFrame, "LEFT", DEFAULT_X, DEFAULT_Y)
	icon:Hide()
	cfFrames.styleIcon(icon)
	cfFrames.playerCastbarIcon = icon
end

local function HookCastbar()
	hooksecurefunc(CastingBarFrame, "Show", UpdateIcon)
	CastingBarFrame:HookScript("OnHide", function()
		icon:Hide()
	end)
end

function cfFrames.ApplyPlayerCastbarIcon()
	if not icon then return end
	if not cfFramesDB.PlayerCastbarIcon then
		cfFramesDB.PlayerCastbarIcon = { x = 0, y = 0, scale = 1 }
	end
	SetIconVisible(cfFramesDB[cfFrames.M.CastbarPlayerIcon] and true or false)
	local db = cfFramesDB.PlayerCastbarIcon
	icon:SetPoint("RIGHT", CastingBarFrame, "LEFT", DEFAULT_X + db.x, DEFAULT_Y + db.y)
	icon:SetSize(defaultSize * db.scale, defaultSize * db.scale)
end

function cfFrames.initCastbarPlayerIcon()
	if not CastingBarFrame then return end
	CreateIcon()
	HookCastbar()
	cfFrames.ApplyPlayerCastbarIcon()
end
