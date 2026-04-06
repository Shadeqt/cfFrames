local icon = TargetFrameSpellBar and TargetFrameSpellBar.Icon
if not icon then return end

local M = cfFrames.M
local _, _, _, defaultX, defaultY = icon:GetPoint()
local defaultSize = icon:GetWidth()

function cfFrames.ApplyTargetCastbarIcon()
	if not cfFramesDB.TargetCastbarIcon then
		cfFramesDB.TargetCastbarIcon = { x = 0, y = 0, scale = 1 }
	end
	local border = TargetFrameSpellBar.cfIconBorder
	if cfFramesDB[M.CastbarTargetIcon] then
		icon:Show()
		if border then border:Show() end
	else
		icon:Hide()
		if border then border:Hide() end
	end
	local db = cfFramesDB.TargetCastbarIcon
	local point, relativeTo, relativePoint = icon:GetPoint()
	if point then
		icon:SetPoint(point, relativeTo, relativePoint, (defaultX or 0) + db.x, (defaultY or 0) + db.y)
	end
	icon:SetSize(defaultSize * db.scale, defaultSize * db.scale)
end

function cfFrames.initTargetCastbarIcon()
	cfFrames.ApplyTargetCastbarIcon()
end
