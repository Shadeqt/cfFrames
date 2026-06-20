local _, addon = ...
local HBL = addon.BiggerUnitFrames

-- Target: enlarge the target health bar and swap in the UnitFramesImproved classification border art,
-- raising the name and "Dead" overlay onto the bigger bar. Re-applied inside TargetFrame_CheckClassification
-- (Blizzard fires it per target change and resets the texture there), so ApplyOffset (self-correcting,
-- re-applied each change) is used rather than the persistent KeepOffset hook.
local DIR           = "Interface\\AddOns\\cfFrames\\Media\\UnitFramesImproved\\"
local NORMAL_BORDER = DIR .. "UI-TargetingFrame"

-- Border art per unit classification; anything not listed falls back to NORMAL_BORDER.
local BORDER_TEXTURE_BY_CLASSIFICATION = {
	worldboss = DIR .. "UI-TargetingFrame-Elite",
	elite     = DIR .. "UI-TargetingFrame-Elite",
	rareelite = DIR .. "UI-TargetingFrame-Rare-Elite",
	rare      = DIR .. "UI-TargetingFrame-Rare",
}

local function ApplyTargetArt()
	if TargetFrameTextureFrameTexture then
		local classification = UnitClassification("target")
		TargetFrameTextureFrameTexture:SetTexture(
			BORDER_TEXTURE_BY_CLASSIFICATION[classification] or NORMAL_BORDER)
	end
	addon.ApplyOffset(TargetFrameTextureFrameName, HBL.VERTICAL_OFFSET)
	if TargetFrameHealthBar then
		TargetFrameHealthBar:SetHeight(HBL.HEALTH_BAR_HEIGHT)
		addon.ApplyOffset(TargetFrameHealthBar, HBL.VERTICAL_OFFSET)
	end
	addon.ApplyOffset(TargetFrameTextureFrameDeadText, HBL.HEALTH_BAR_TEXT_OFFSET)

	-- Target dark backing: TargetFrameNameBackground is the target's only backing region. Trim its
	-- default 19px to 18px so its bottom edge clears the raised bar, and set the translucent black that
	-- HealthbarColor also writes (they agree, and HealthbarColor's SetVertexColor hook guards against a
	-- write loop). The trim is owned here (it only matters once this feature raised the bar).
	if TargetFrameNameBackground then
		TargetFrameNameBackground:SetHeight(18)
		TargetFrameNameBackground:SetVertexColor(0, 0, 0, 0.5)
	end
end

function HBL.SetupTarget()
	hooksecurefunc("TargetFrame_CheckClassification", ApplyTargetArt)
	if UnitExists("target") then ApplyTargetArt() end  -- catch a target already present (e.g. after /reload)
end
