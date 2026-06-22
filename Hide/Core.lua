local _, addon = ...

-- Catch-all for hiding native Blizzard UI elements, one file per element, each with
-- its own checkbox under the "Hide" settings header. This Core holds the shared
-- machinery; each sibling file installs its own hide unguarded (the per-element
-- enable check lives in SetupHideNative below).
--
-- Off is reload-gated like the other modules: Blizzard's defaults return on /reload,
-- so there's no restore path. Each element is reparented to a permanently-hidden
-- frame rather than :Hide()'d, because Blizzard re-Show()s them on state changes
-- (combat/rested, group updates). A hidden parent makes those Show() calls no-ops
-- without needing a per-Show hook -- effective visibility is own-shown AND
-- parent-shown. Anchors are independent of parent, so position is unaffected.
local hidden = CreateFrame("Frame")
hidden:Hide()

-- Reparent a region/frame under the hidden parent. Shared by every element file.
function addon.HideElement(region)
	if region then region:SetParent(hidden) end
end

-- One entry for all hidden elements; each gated by its own checkbox.
function addon.SetupHideNative()
	if cfFramesDB.HidePortraitGlow then addon.HidePortraitGlow() end
	if cfFramesDB.HidePlayerAttackGlow then addon.HidePlayerAttackGlow() end
	if cfFramesDB.HidePetCombatFlash then addon.HidePetCombatFlash() end
	if cfFramesDB.HideGroupIndicator then addon.HideGroupIndicator() end
	if cfFramesDB.HideHitIndicators then addon.HideHitIndicators() end
	-- Hide the rest/combat icons (they overlap PlayerLevelText); no GUI gate yet.
	addon.HidePlayerStatusIcons()
end
