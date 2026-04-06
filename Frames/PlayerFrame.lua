local V = cff.VALUES

-- PlayerFrame: store raw Blizzard args and inject offset
local pfRaw = {}
pfRaw.point, pfRaw.relativeTo, pfRaw.relativePoint, pfRaw.x, pfRaw.y = PlayerFrame:GetPoint()
pfRaw.x = pfRaw.x or 0
pfRaw.y = pfRaw.y or 0

local origPFSetPoint = PlayerFrame.SetPoint
PlayerFrame.SetPoint = function(self, point, relativeTo, relativePoint, x, y, ...)
	pfRaw.point, pfRaw.relativeTo, pfRaw.relativePoint, pfRaw.x, pfRaw.y = point, relativeTo, relativePoint, x or 0, y or 0
	origPFSetPoint(self, point, relativeTo, relativePoint, pfRaw.x + cfFramesDB[V.PlayerFrameX], pfRaw.y + cfFramesDB[V.PlayerFrameY], ...)
end

function cff.ApplyPlayerFrame()
	PlayerFrame:SetScale(cfFramesDB[V.PlayerFrameScale])
	if pfRaw.point then
		PlayerFrame:SetPoint(pfRaw.point, pfRaw.relativeTo, pfRaw.relativePoint, pfRaw.x, pfRaw.y)
	end
end

-- PlayerCastbar: store raw Blizzard args and inject offset
local cbRaw = {}
local origCBSetPoint = CastingBarFrame.SetPoint
CastingBarFrame.SetPoint = function(self, point, relativeTo, relativePoint, x, y, ...)
	cbRaw.point, cbRaw.relativeTo, cbRaw.relativePoint, cbRaw.x, cbRaw.y = point, relativeTo, relativePoint, x or 0, y or 0
	origCBSetPoint(self, point, relativeTo, relativePoint, cbRaw.x + cfFramesDB[V.PlayerCastbarX], cbRaw.y + cfFramesDB[V.PlayerCastbarY], ...)
end

function cff.ApplyPlayerCastbar()
	CastingBarFrame:SetScale(cfFramesDB[V.PlayerCastbarScale])
	if cbRaw.point then
		CastingBarFrame:SetPoint(cbRaw.point, cbRaw.relativeTo, cbRaw.relativePoint, cbRaw.x, cbRaw.y)
	end
end

function cff.ApplyPlayerCastbarIcon()
	if not CastingBarFrame or not CastingBarFrame.Icon then return end
	local icon = CastingBarFrame.Icon
	icon:SetScale(cfFramesDB[V.PlayerCastbarIconScale])
	icon:ClearAllPoints()
	icon:SetPoint("RIGHT", CastingBarFrame, "LEFT", -10 + cfFramesDB[V.PlayerCastbarIconX], 2 + cfFramesDB[V.PlayerCastbarIconY])
end

