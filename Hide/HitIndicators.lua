local _, addon = ...

-- Player & pet portraits: the floating combat-feedback numbers (damage/healing) that pop over the
-- portrait on every hit -- PlayerHitIndicator / PetHitIndicator, a.k.a. each frame's feedbackText.
-- Reparented to the hidden frame like the other elements: Blizzard's CombatFeedback still drives the
-- FontString (text/alpha) each hit, but a hidden parent keeps it invisible with no per-Show hook.
-- (Globals first to match the sibling modules; the feedbackText field is a robust fallback in case a
-- client build names the FontString differently.)
function addon.HideHitIndicators()
	addon.HideElement(PlayerHitIndicator or (PlayerFrame and PlayerFrame.feedbackText))
	addon.HideElement(PetHitIndicator or (PetFrame and PetFrame.feedbackText))
end
