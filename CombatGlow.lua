local M = cfFrames.MODULES

local function HookHide(frame, dbKey)
	if not frame then return end
	frame:Hide()
	hooksecurefunc(frame, "Show", function(self)
		if not cfFramesDB[dbKey] then return end
		self:Hide()
	end)
end

cfFrames:RegisterModule(M.PLAYER_COMBAT_GLOW, function()
	HookHide(PlayerStatusGlow, M.PLAYER_COMBAT_GLOW)
	HookHide(PlayerStatusTexture, M.PLAYER_COMBAT_GLOW)
end, function()
	if PlayerStatusGlow then PlayerStatusGlow:Show() end
	if PlayerStatusTexture then PlayerStatusTexture:Show() end
end)

cfFrames:RegisterModule(M.PET_COMBAT_GLOW, function()
	HookHide(PetFrameFlash, M.PET_COMBAT_GLOW)
	HookHide(PetAttackModeTexture, M.PET_COMBAT_GLOW)
end, function()
	if PetFrameFlash then PetFrameFlash:Show() end
	if PetAttackModeTexture then PetAttackModeTexture:Show() end
end)

cfFrames:RegisterModule(M.PLAYER_HIT_INDICATOR, function()
	HookHide(PlayerHitIndicator, M.PLAYER_HIT_INDICATOR)
end, function()
	if PlayerHitIndicator then PlayerHitIndicator:Show() end
end)

cfFrames:RegisterModule(M.PET_HIT_INDICATOR, function()
	HookHide(PetHitIndicator, M.PET_HIT_INDICATOR)
end, function()
	if PetHitIndicator then PetHitIndicator:Show() end
end)
