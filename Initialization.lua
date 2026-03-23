cfFrames = {}
cfFrames.modules = {}

function cfFrames:RegisterModule(key, enableFunc, disableFunc)
	local existing = self.modules[key]
	if not existing then
		self.modules[key] = { Enable = enableFunc, Disable = disableFunc }
	else
		local prevEnable = existing.Enable
		local prevDisable = existing.Disable
		existing.Enable = function() prevEnable(); enableFunc() end
		existing.Disable = function() prevDisable(); disableFunc() end
	end
end

cfFrames.MODULES = {
TARGET_FRAME_STATUS_TEXT = "TargetFrameStatusText",
	EXPERIENCE_BAR = "ExperienceBar",
	BBF_INTEGRATION = "BetterBlizzFramesIntegration",
	QUESTIE_INTEGRATION = "QuestieIntegration",
	PET_LEVEL = "PetLevel",
	PET_XP_BAR = "PetXpBar",
	PET_NAME = "PetName",
	PET_DEBUFFS = "PetDebuffs",
	PLAYER_COMBAT_GLOW = "PlayerCombatGlow",
	PLAYER_HIT_INDICATOR = "PlayerHitIndicator",
	PET_COMBAT_GLOW = "PetCombatGlow",
	PET_HIT_INDICATOR = "PetHitIndicator",
	STATUS_BAR_TEXTURE = "StatusBarTexture",
	NAMEPLATE_CASTBAR = "NameplateCastbar",
	BIGGER_HEALTHBAR = "BiggerHealthbar",
	DARK_MODE = "DarkMode",
	HEALTHBAR_COLOR = "HealthbarColor",
	ICON_ZOOM = "IconZoom",
	BUFF_SIZE = "BuffSize",
}

local M = cfFrames.MODULES

local DEFAULTS = {
[M.TARGET_FRAME_STATUS_TEXT] = true,
	[M.EXPERIENCE_BAR] = true,
	[M.BBF_INTEGRATION] = true,
	[M.QUESTIE_INTEGRATION] = true,
	[M.PET_LEVEL] = true,
	[M.PET_XP_BAR] = true,
	[M.PET_NAME] = true,
	[M.PET_DEBUFFS] = true,
	[M.PLAYER_COMBAT_GLOW] = true,
	[M.PLAYER_HIT_INDICATOR] = true,
	[M.PET_COMBAT_GLOW] = true,
	[M.PET_HIT_INDICATOR] = true,
	[M.STATUS_BAR_TEXTURE] = true,
	[M.NAMEPLATE_CASTBAR] = true,
	[M.BIGGER_HEALTHBAR] = true,
	[M.DARK_MODE] = true,
	[M.HEALTHBAR_COLOR] = true,
	[M.ICON_ZOOM] = true,
	[M.BUFF_SIZE] = true,
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
	if arg1 ~= "cfFrames" then return end
	self:UnregisterEvent("ADDON_LOADED")

	cfFramesDB = cfFramesDB or {}

	-- add missing keys
	for key, value in pairs(DEFAULTS) do
		if cfFramesDB[key] == nil then
			cfFramesDB[key] = value
		end
	end

	-- remove stale keys
	for key in pairs(cfFramesDB) do
		if DEFAULTS[key] == nil then
			cfFramesDB[key] = nil
		end
	end

	-- enable active modules
	for key, module in pairs(cfFrames.modules) do
		if cfFramesDB[key] then
			module.Enable()
		end
	end
end)
