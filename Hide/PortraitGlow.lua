local _, addon = ...

-- Player portrait glow: the pulsing combat/rested aura. PlayerStatusTexture is the
-- actual pulse in Classic Era (PlayerStatusGlow doesn't carry it); BiggerHealthbar
-- only restyles PlayerStatusTexture (never force-shows) and runs before us, so
-- hiding it here wins.
function addon.HidePortraitGlow()
	addon.HideElement(PlayerStatusGlow)
	addon.HideElement(PlayerStatusTexture)
end
