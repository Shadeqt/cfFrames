-- Texture_ExperienceBar.lua — Sync XP bar textures with BetterBlizzFrames castbar texture setting
local M = cfFrames.MODULES

local function GetTexture()
	local bbfDB = BetterBlizzFramesDB
	if bbfDB and bbfDB.changeUnitFrameCastbarTexture and bbfDB.unitFrameCastbarTexture then
		local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
		if LSM then
			return LSM:Fetch(LSM.MediaType.STATUSBAR, bbfDB.unitFrameCastbarTexture)
		end
	end
	return nil
end

local function ApplyTexture()
	local texture = GetTexture()
	if not texture then return end

	-- Native XP bar
	if MainMenuExpBar then
		MainMenuExpBar:SetStatusBarTexture(texture)
		MainMenuExpBar:SetFrameLevel(1)
	end

	-- Rested XP fill
	if ExhaustionLevelFillBar then
		ExhaustionLevelFillBar:SetTexture(texture)
	end

	-- Quest XP overlay
	if cfFrames.questOverlay then
		cfFrames.questOverlay:SetStatusBarTexture(texture)
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
	if arg1 ~= "cfFrames" and arg1 ~= "BetterBlizzFrames" then return end
	if not cfFrames or not BetterBlizzFramesDB then return end

	self:UnregisterEvent("ADDON_LOADED")
	ApplyTexture()

	if BBF and BBF.UpdateCustomTextures then
		hooksecurefunc(BBF, "UpdateCustomTextures", ApplyTexture)
	end
end)
