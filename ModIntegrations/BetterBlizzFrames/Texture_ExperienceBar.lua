-- Texture_ExperienceBar.lua — Sync XP bar textures with BetterBlizzFrames castbar texture setting
local M = cfFrames.MODULES
local DEFAULT_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"

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
	if not cfFramesDB[M.BBF_INTEGRATION] then return end
	local texture = GetTexture()
	if not texture then return end

	if MainMenuExpBar then
		MainMenuExpBar:SetStatusBarTexture(texture)
		MainMenuExpBar:SetFrameLevel(1)
	end

	if ExhaustionLevelFillBar then
		ExhaustionLevelFillBar:SetTexture(texture)
	end

	if cfFrames.questOverlay then
		cfFrames.questOverlay:SetStatusBarTexture(texture)
	end
end

local function RevertTexture()
	if MainMenuExpBar then
		MainMenuExpBar:SetStatusBarTexture(DEFAULT_TEXTURE)
		MainMenuExpBar:SetFrameLevel(2)
	end

	if ExhaustionLevelFillBar then
		ExhaustionLevelFillBar:SetTexture(DEFAULT_TEXTURE)
	end

	if cfFrames.questOverlay then
		cfFrames.questOverlay:SetStatusBarTexture(DEFAULT_TEXTURE)
	end
end

local function Enable()
	ApplyTexture()
	if BBF and BBF.UpdateCustomTextures then
		hooksecurefunc(BBF, "UpdateCustomTextures", ApplyTexture)
	end
end

local function Disable()
	RevertTexture()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
	if arg1 ~= "cfFrames" and arg1 ~= "BetterBlizzFrames" then return end
	if not cfFrames or not BetterBlizzFramesDB then return end

	self:UnregisterEvent("ADDON_LOADED")
	cfFrames:RegisterModule(M.BBF_INTEGRATION, Enable, Disable)
	if cfFramesDB and cfFramesDB[M.BBF_INTEGRATION] then
		Enable()
	end
end)
