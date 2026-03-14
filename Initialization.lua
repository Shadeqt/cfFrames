cfFrames = {}

cfFrames.MODULES = {
	POWER_TICKER = "PowerTicker",
	POWER_TICKER_MANA_LOW = "PowerTicker_ManaLow",
	POWER_TICKER_MANA_FULL = "PowerTicker_ManaFull",
	POWER_TICKER_ENERGY_LOW = "PowerTicker_EnergyLow",
	POWER_TICKER_ENERGY_FULL = "PowerTicker_EnergyFull",
	TARGET_FRAME_STATUS_TEXT = "TargetFrameStatusText",
	EXPERIENCE_BAR = "ExperienceBar",
	BBF_INTEGRATION = "BetterBlizzFramesIntegration",
	PET_LEVEL = "PetLevel",
	PET_XP_BAR = "PetXpBar",
	PET_NAME = "PetName",
	PET_DEBUFFS = "PetDebuffs",
	COMBAT_GLOW = "CombatGlow",
	HIT_INDICATOR = "HitIndicator",
}

local M = cfFrames.MODULES

local DEFAULTS = {
	[M.POWER_TICKER] = true,
	[M.POWER_TICKER_MANA_LOW] = true,
	[M.POWER_TICKER_MANA_FULL] = true,
	[M.POWER_TICKER_ENERGY_LOW] = true,
	[M.POWER_TICKER_ENERGY_FULL] = true,
	[M.TARGET_FRAME_STATUS_TEXT] = true,
	[M.EXPERIENCE_BAR] = true,
	[M.BBF_INTEGRATION] = true,
	[M.PET_LEVEL] = true,
	[M.PET_XP_BAR] = true,
	[M.PET_NAME] = true,
	[M.PET_DEBUFFS] = true,
	[M.COMBAT_GLOW] = true,
	[M.HIT_INDICATOR] = true,
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
end)
