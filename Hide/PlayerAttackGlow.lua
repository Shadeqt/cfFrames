local _, addon = ...

-- Player portrait: the red attack/combat glow (PlayerAttackBackground) that flashes behind the
-- player frame while you're in combat. Hidden the same way as the pet's combat flash.
function addon.HidePlayerAttackGlow()
	addon.HideElement(PlayerAttackBackground)
end
