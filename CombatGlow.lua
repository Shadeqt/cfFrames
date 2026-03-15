local M = cfFrames.MODULES

local function HideOnShow(frame)
	if not frame then return end
	frame:Hide()
	hooksecurefunc(frame, "Show", function(self)
		self:Hide()
	end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
	if arg1 ~= "cfFrames" then return end
	self:UnregisterEvent("ADDON_LOADED")
	if cfFramesDB[M.PLAYER_COMBAT_GLOW] then
		HideOnShow(PlayerStatusGlow)
		HideOnShow(PlayerStatusTexture)
	end

	if cfFramesDB[M.PET_COMBAT_GLOW] then
		HideOnShow(PetFrameFlash)
		HideOnShow(PetAttackModeTexture)
	end

	if cfFramesDB[M.PLAYER_HIT_INDICATOR] then
		HideOnShow(PlayerHitIndicator)
	end

	if cfFramesDB[M.PET_HIT_INDICATOR] then
		HideOnShow(PetHitIndicator)
	end
end)
