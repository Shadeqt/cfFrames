local _, addon = ...

-- Pet portrait: the combat flash + attack-mode texture.
function addon.HidePetCombatFlash()
	addon.HideElement(PetFrameFlash)
	addon.HideElement(PetAttackModeTexture)
end
