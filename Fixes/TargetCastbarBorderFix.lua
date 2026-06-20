local _, addon = ...

-- The target cast bar fill spills a couple of pixels past the left edge of its border art. The
-- border (and the non-interruptible BorderShield) is anchored to the bar by TOPLEFT/TOPRIGHT, so
-- pushing its TOPLEFT further left stretches the art over the overhang. Set once at setup.
local WIDEN = 2

local function WidenLeft(region)
	if not region then return end
	for i = 1, region:GetNumPoints() do
		local point, relativeTo, relativePoint, x, y = region:GetPoint(i)
		if point == "TOPLEFT" then
			region:SetPoint(point, relativeTo, relativePoint, x - WIDEN, y)
		end
	end
end

function addon.SetupTargetCastbarBorderFix()
	if not cfFramesDB.TargetCastbarBorderFix then return end
	if not TargetFrameSpellBar then return end

	WidenLeft(TargetFrameSpellBar.Border)
	WidenLeft(TargetFrameSpellBar.BorderShield)
end
