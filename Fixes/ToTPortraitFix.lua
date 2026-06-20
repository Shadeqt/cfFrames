local _, addon = ...

-- Position + size the Target-of-Target portrait so it fills its border with no gap (cfFramesTest's
-- improved version: grows the portrait, then re-anchors). The default size is captured once
-- (cfToTBaseW/H) so a second run scales the original, not the already-scaled size -- no compounding.
local SIZE_SCALE = 1.05

function addon.SetupToTPortraitFix()
	if not cfFramesDB.ToTPortraitFix then return end
	local p = TargetFrameToTPortrait
	if not p then return end
	if not p.cfToTBaseW then
		p.cfToTBaseW, p.cfToTBaseH = p:GetSize()
	end
	p:SetSize(p.cfToTBaseW * SIZE_SCALE, p.cfToTBaseH * SIZE_SCALE)
	local point, relativeTo, relativePoint = p:GetPoint()
	p:SetPoint(point, relativeTo, relativePoint, 4, -4)
end
