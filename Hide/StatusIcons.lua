local _, addon = ...

-- Hide the player rest and combat icons (PlayerRestIcon / PlayerAttackIcon). They overlap
-- PlayerLevelText, so hiding them keeps the level number readable in every state. Reparented under the
-- Hide group's permanently-hidden frame (addon.HideElement) rather than :Hide()'d, because Blizzard
-- re-Show()s them on combat/rested changes (PlayerFrame_UpdateStatus); a hidden parent makes those
-- Show() calls no-ops without a per-Show hook. Anchors are parent-independent, so nothing else on the
-- frame moves. No GUI yet -- applied unconditionally from SetupHideNative.
function addon.HidePlayerStatusIcons()
	addon.HideElement(PlayerRestIcon)
	addon.HideElement(PlayerAttackIcon)
end
