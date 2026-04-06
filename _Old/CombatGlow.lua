local function HookHide(frame)
	if not frame then return end
	frame:Hide()
	hooksecurefunc(frame, "Show", function(self) self:Hide() end)
end

function cfFrames.initCombatGlow()
	HookHide(PlayerStatusGlow)
	HookHide(PlayerStatusTexture)
	HookHide(PetFrameFlash)
	HookHide(PetAttackModeTexture)
end
