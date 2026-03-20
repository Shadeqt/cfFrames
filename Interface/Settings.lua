local panel = CreateFrame("Frame", "cfFramesSettingsPanel")
panel.name = "cfFrames"
panel:Hide()

local W = cfFrames.Widgets
local M = cfFrames.MODULES
local COL1 = 0
local COL2 = 300

local SAME_ROW = 0
local NEW_ROW = -10

-- Mod Integrations
local title = W.CreateTitle(panel, "cfFrames", COL1, SAME_ROW)
local modsHeader = W.CreateHeader(title, "Mod Integrations", COL1, NEW_ROW)
local modsSection = W.CreateSection(modsHeader, COL1, NEW_ROW)
local bbfIntegration = W.CreateCheckbox(modsSection, "BetterBlizzFrames", M.BBF_INTEGRATION, COL1, NEW_ROW,
	"Sync dark mode, icon zoom, textures, and pet name centering with BetterBlizzFrames settings")
local questieIntegration = W.CreateCheckbox(bbfIntegration, "Questie", M.QUESTIE_INTEGRATION, COL2, SAME_ROW,
	"Show pending quest XP as a yellow overlay on the experience bar using Questie's quest database")

-- General
local generalHeader = W.CreateHeader(modsSection, "General", COL1, NEW_ROW)
local generalSection = W.CreateSection(generalHeader, COL1, NEW_ROW)
local experienceBar = W.CreateCheckbox(generalSection, "Show Experience Bar Text", M.EXPERIENCE_BAR, COL1, NEW_ROW,
	"Display the status text format chosen in Blizzard's interface options on the experience bar")

-- Target Frame
local targetHeader = W.CreateHeader(generalSection, "Target Frame", COL1, NEW_ROW)
local targetSection = W.CreateSection(targetHeader, COL1, NEW_ROW)
local targetStatusText = W.CreateCheckbox(targetSection, "Show Status Text", M.TARGET_FRAME_STATUS_TEXT, COL1, NEW_ROW,
	"Display the status text format chosen in Blizzard's interface options on the target frame")

-- Player Frame
local playerHeader = W.CreateHeader(targetSection, "Player Frame", COL1, NEW_ROW)
local playerSection = W.CreateSection(playerHeader, COL1, NEW_ROW)
local powerTicker = W.CreateCheckbox(playerSection, "Show Power Ticker", M.POWER_TICKER, COL1, NEW_ROW,
	"Show a spark on the mana/energy bar indicating tick timing")
local manaFull = W.CreateCheckbox(powerTicker, "Show at Full Mana", M.POWER_TICKER_MANA_FULL, COL1, NEW_ROW,
	"Keep the ticker visible when mana is full")
local energyFull = W.CreateCheckbox(manaFull, "Show at Full Energy", M.POWER_TICKER_ENERGY_FULL, COL2, SAME_ROW,
	"Keep the ticker visible when energy is full")
local playerGlow = W.CreateCheckbox(manaFull, "Hide Combat Glow", M.PLAYER_COMBAT_GLOW, COL1, NEW_ROW,
	"Hide the pulsing glow around the player portrait during combat")
local playerHit = W.CreateCheckbox(playerGlow, "Hide Hit Indicator", M.PLAYER_HIT_INDICATOR, COL2, SAME_ROW,
	"Hide the damage numbers that flash on the player portrait")

-- Pet Frame
local petHeader = W.CreateHeader(playerSection, "Pet Frame", COL1, NEW_ROW)
local petSection = W.CreateSection(petHeader, COL1, NEW_ROW)
local petLevel = W.CreateCheckbox(petSection, "Show Pet Level", M.PET_LEVEL, COL1, NEW_ROW,
	"Display pet level on the pet portrait when pet level differs from player level")
local petXpBar = W.CreateCheckbox(petLevel, "Show Pet XP Bar", M.PET_XP_BAR, COL2, SAME_ROW,
	"Display an experience bar below the pet frame when pet level differs from player level")
local petDebuffs = W.CreateCheckbox(petLevel, "Show Pet Debuffs", M.PET_DEBUFFS, COL1, NEW_ROW,
	"Display debuff icons on the pet frame")
local petName = W.CreateCheckbox(petDebuffs, "Center Pet Name", M.PET_NAME, COL2, SAME_ROW,
	"Center the pet name above the health bar, matching player and target name alignment")
local petGlow = W.CreateCheckbox(petDebuffs, "Hide Combat Glow", M.PET_COMBAT_GLOW, COL1, NEW_ROW,
	"Hide the pulsing glow around the pet portrait during combat")
local petHit = W.CreateCheckbox(petGlow, "Hide Hit Indicator", M.PET_HIT_INDICATOR, COL2, SAME_ROW,
	"Hide the damage numbers that flash on the pet portrait")

panel:HookScript("OnShow", function()
	W.FitToContent(modsSection)
	W.FitToContent(generalSection)
	W.FitToContent(targetSection)
	W.FitToContent(playerSection)
	W.FitToContent(petSection)
end)

local function UpdatePowerTickerDependents()
	local active = cfFramesDB[M.POWER_TICKER]
	manaFull:SetActive(active)
	energyFull:SetActive(active)
end

powerTicker:HookScript("OnClick", UpdatePowerTickerDependents)
powerTicker:HookScript("OnShow", UpdatePowerTickerDependents)

local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name, panel.name)
Settings.RegisterAddOnCategory(category)

SLASH_CFFRAMES1 = "/cff"
SlashCmdList["CFFRAMES"] = function()
	Settings.OpenToCategory(category:GetID())
end
