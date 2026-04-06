local M = cff.MODULES
local V = cff.VALUES

-- TargetFrame: store raw Blizzard args and inject offset
local tfRaw = {}
tfRaw.point, tfRaw.relativeTo, tfRaw.relativePoint, tfRaw.x, tfRaw.y = TargetFrame:GetPoint()
tfRaw.x = tfRaw.x or 0
tfRaw.y = tfRaw.y or 0

local origTFSetPoint = TargetFrame.SetPoint
TargetFrame.SetPoint = function(self, point, relativeTo, relativePoint, x, y, ...)
	tfRaw.point, tfRaw.relativeTo, tfRaw.relativePoint, tfRaw.x, tfRaw.y = point, relativeTo, relativePoint, x or 0, y or 0
	origTFSetPoint(self, point, relativeTo, relativePoint, tfRaw.x + cfFramesDB[V.TargetFrameX], tfRaw.y + cfFramesDB[V.TargetFrameY], ...)
end

function cff.ApplyTargetFrame()
	TargetFrame:SetScale(cfFramesDB[V.TargetFrameScale])
	if tfRaw.point then
		TargetFrame:SetPoint(tfRaw.point, tfRaw.relativeTo, tfRaw.relativePoint, tfRaw.x, tfRaw.y)
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

