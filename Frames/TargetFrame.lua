local M = cff.MODULES
local V = cff.VALUES

-- Save position on drag stop
TargetFrame:HookScript("OnDragStop", function(self)
	local p, _, rp, x, y = self:GetPoint()
	cfFramesDB.TargetFramePos = { p, rp, x, y }
end)

-- Clear saved position on reset
hooksecurefunc("TargetFrame_ResetUserPlacedPosition", function()
	cfFramesDB.TargetFramePos = false
end)

function cff.ApplyTargetFrame()
	TargetFrame:SetScale(cfFramesDB[V.TargetFrameScale])
	local pos = cfFramesDB.TargetFramePos
	if pos then
		TargetFrame:ClearAllPoints()
		TargetFrame:SetPoint(pos[1], UIParent, pos[2], pos[3] + cfFramesDB[V.TargetFrameX], pos[4] + cfFramesDB[V.TargetFrameY])
		TargetFrame:SetUserPlaced(true)
	elseif cfFramesDB[V.TargetFrameX] ~= 0 or cfFramesDB[V.TargetFrameY] ~= 0 then
		local p, _, rp, x, y = TargetFrame:GetPoint()
		if p then
			TargetFrame:ClearAllPoints()
			TargetFrame:SetPoint(p, UIParent, rp, (x or 0) + cfFramesDB[V.TargetFrameX], (y or 0) + cfFramesDB[V.TargetFrameY])
		end
	end
end

-- TargetCastbar: store raw Blizzard args, supports static mode
local cbRaw = {}
if TargetFrameSpellBar then
	local origSetPoint = TargetFrameSpellBar.SetPoint
	cff._targetCastbarOrigSetPoint = origSetPoint

	TargetFrameSpellBar.SetPoint = function(self, point, relativeTo, relativePoint, x, y, ...)
		cbRaw.point, cbRaw.relativeTo, cbRaw.relativePoint, cbRaw.x, cbRaw.y = point, relativeTo, relativePoint, x or 0, y or 0
		if cfFramesDB[M.TargetCastbarStatic] then
			origSetPoint(self, "TOPLEFT", TargetFrame, "BOTTOMLEFT",
				20 + cfFramesDB[V.TargetCastbarX], -15 + cfFramesDB[V.TargetCastbarY])
		else
			origSetPoint(self, point, relativeTo, relativePoint, cbRaw.x + cfFramesDB[V.TargetCastbarX], cbRaw.y + cfFramesDB[V.TargetCastbarY], ...)
		end
	end
end

local iconRaw = {}
if TargetFrameSpellBar and TargetFrameSpellBar.Icon then
	local icon = TargetFrameSpellBar.Icon
	iconRaw.point, iconRaw.relativeTo, iconRaw.relativePoint, iconRaw.x, iconRaw.y = icon:GetPoint()
end

function cff.ApplyTargetCastbarIcon()
	if not TargetFrameSpellBar or not TargetFrameSpellBar.Icon then return end
	if not iconRaw.point then return end
	local icon = TargetFrameSpellBar.Icon
	icon:SetScale(cfFramesDB[V.TargetCastbarIconScale])
	icon:SetPoint(iconRaw.point, iconRaw.relativeTo, iconRaw.relativePoint,
		iconRaw.x + cfFramesDB[V.TargetCastbarIconX], iconRaw.y + cfFramesDB[V.TargetCastbarIconY])
end

function cff.ApplyTargetCastbar()
	if not TargetFrameSpellBar then return end
	TargetFrameSpellBar:SetScale(cfFramesDB[V.TargetCastbarScale])
	if cfFramesDB[M.TargetCastbarStatic] then
		cff._targetCastbarOrigSetPoint(TargetFrameSpellBar, "TOPLEFT", TargetFrame, "BOTTOMLEFT",
			20 + cfFramesDB[V.TargetCastbarX], -15 + cfFramesDB[V.TargetCastbarY])
	elseif cbRaw.point then
		TargetFrameSpellBar:SetPoint(cbRaw.point, cbRaw.relativeTo, cbRaw.relativePoint, cbRaw.x, cbRaw.y)
	elseif Target_Spellbar_AdjustPosition then
		Target_Spellbar_AdjustPosition(TargetFrameSpellBar)
	end
end
