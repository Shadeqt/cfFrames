local V = cff.VALUES

-- Save position on drag stop
PlayerFrame:HookScript("OnDragStop", function(self)
	local p, _, rp, x, y = self:GetPoint()
	cfFramesDB.PlayerFramePos = { p, rp, x, y }
end)

-- Clear saved position on reset
hooksecurefunc("PlayerFrame_ResetUserPlacedPosition", function()
	cfFramesDB.PlayerFramePos = false
end)

function cff.ApplyPlayerFrame()
	PlayerFrame:SetScale(cfFramesDB[V.PlayerFrameScale])
	local pos = cfFramesDB.PlayerFramePos
	if pos then
		PlayerFrame:ClearAllPoints()
		PlayerFrame:SetPoint(pos[1], UIParent, pos[2], pos[3] + cfFramesDB[V.PlayerFrameX], pos[4] + cfFramesDB[V.PlayerFrameY])
		PlayerFrame:SetUserPlaced(true)
	elseif cfFramesDB[V.PlayerFrameX] ~= 0 or cfFramesDB[V.PlayerFrameY] ~= 0 then
		local p, _, rp, x, y = PlayerFrame:GetPoint()
		if p then
			PlayerFrame:ClearAllPoints()
			PlayerFrame:SetPoint(p, UIParent, rp, (x or 0) + cfFramesDB[V.PlayerFrameX], (y or 0) + cfFramesDB[V.PlayerFrameY])
		end
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
