local panel = CreateFrame("Frame", "cfFramesSettingsPanel")
panel.name = "cfFrames"
panel:Hide()

local W = cfFrames.Widgets
local M = cfFrames.MODULES
local COL2 = 300
W.panel = panel

local T = W.TOOLTIPS
T[M.BBF_INTEGRATION] = "Sync dark mode, icon zoom, textures, and pet name centering with BetterBlizzFrames settings"
T[M.QUESTIE_INTEGRATION] = "Show pending quest XP as a yellow overlay on the experience bar using Questie's quest database"
T[M.EXPERIENCE_BAR] = "Display the status text format chosen in Blizzard's interface options on the experience bar"
T[M.TARGET_FRAME_STATUS_TEXT] = "Display the status text format chosen in Blizzard's interface options on the target frame"
T[M.POWER_TICKER] = "Show a spark on the mana/energy bar indicating tick timing"
T[M.POWER_TICKER_MANA_FULL] = "Keep the ticker visible when mana is full"
T[M.POWER_TICKER_ENERGY_FULL] = "Keep the ticker visible when energy is full"
T[M.PLAYER_COMBAT_GLOW] = "Hide the pulsing glow around the player portrait during combat"
T[M.PLAYER_HIT_INDICATOR] = "Hide the damage numbers that flash on the player portrait"
T[M.PET_LEVEL] = "Display pet level on the pet portrait when pet level differs from player level"
T[M.PET_XP_BAR] = "Display an experience bar below the pet frame when pet level differs from player level"
T[M.PET_DEBUFFS] = "Display debuff icons on the pet frame"
T[M.PET_NAME] = "Center the pet name above the health bar, matching player and target name alignment"
T[M.PET_COMBAT_GLOW] = "Hide the pulsing glow around the pet portrait during combat"
T[M.PET_HIT_INDICATOR] = "Hide the damage numbers that flash on the pet portrait"
T[M.STATUS_BAR_TEXTURE] = "Replace the default status bar texture on all unit frames, cast bars, nameplates, and experience bar"
T[M.NAMEPLATE_CASTBAR] = "Show cast bars on enemy nameplates"

local scrollChild = W.CreateScrollPanel(panel)

-- Mod Integrations
local title = W.CreateTitle(scrollChild, "cfFrames")
local modsHeader = W.CreateHeader(title, "Mod Integrations")
local modsSection = W.CreateSection(modsHeader)
local bbfIntegration = W.CreateCheckbox(modsSection, "BetterBlizzFrames", M.BBF_INTEGRATION)
local questieIntegration = W.CreateCheckbox(bbfIntegration, "Questie", M.QUESTIE_INTEGRATION, COL2)

-- Textures
local texturesHeader = W.CreateHeader(modsSection, "Textures")
local texturesSection = W.CreateSection(texturesHeader)
local statusBarTexture = W.CreateCheckbox(texturesSection, "Status Bar Texture", M.STATUS_BAR_TEXTURE)

-- General
local generalHeader = W.CreateHeader(texturesSection, "General")
local generalSection = W.CreateSection(generalHeader)
local experienceBar = W.CreateCheckbox(generalSection, "Show Experience Bar Text", M.EXPERIENCE_BAR)

-- Target Frame
local targetHeader = W.CreateHeader(generalSection, "Target Frame")
local targetSection = W.CreateSection(targetHeader)
local targetStatusText = W.CreateCheckbox(targetSection, "Show Status Text", M.TARGET_FRAME_STATUS_TEXT)

-- Player Frame
local playerHeader = W.CreateHeader(targetSection, "Player Frame")
local playerSection = W.CreateSection(playerHeader)
local powerTicker = W.CreateCheckbox(playerSection, "Show Power Ticker", M.POWER_TICKER)
local manaFull = W.CreateCheckbox(powerTicker, "Show at Full Mana", M.POWER_TICKER_MANA_FULL, nil, powerTicker)
local energyFull = W.CreateCheckbox(manaFull, "Show at Full Energy", M.POWER_TICKER_ENERGY_FULL, COL2, powerTicker)
local playerGlow = W.CreateCheckbox(manaFull, "Hide Combat Glow", M.PLAYER_COMBAT_GLOW)
local playerHit = W.CreateCheckbox(playerGlow, "Hide Hit Indicator", M.PLAYER_HIT_INDICATOR, COL2)

-- Pet Frame
local petHeader = W.CreateHeader(playerSection, "Pet Frame")
local petSection = W.CreateSection(petHeader)
local petLevel = W.CreateCheckbox(petSection, "Show Pet Level", M.PET_LEVEL)
local petXpBar = W.CreateCheckbox(petLevel, "Show Pet XP Bar", M.PET_XP_BAR, COL2)
local petDebuffs = W.CreateCheckbox(petLevel, "Show Pet Debuffs", M.PET_DEBUFFS)
local petName = W.CreateCheckbox(petDebuffs, "Center Pet Name", M.PET_NAME, COL2)
local petGlow = W.CreateCheckbox(petDebuffs, "Hide Combat Glow", M.PET_COMBAT_GLOW)
local petHit = W.CreateCheckbox(petGlow, "Hide Hit Indicator", M.PET_HIT_INDICATOR, COL2)

-- Nameplates
local nameplatesHeader = W.CreateHeader(petSection, "Nameplates")
local nameplatesSection = W.CreateSection(nameplatesHeader)
local nameplateCastbar = W.CreateCheckbox(nameplatesSection, "Show Enemy Cast Bars", M.NAMEPLATE_CASTBAR)

local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name, panel.name)
Settings.RegisterAddOnCategory(category)

SLASH_CFFRAMES1 = "/cff"
SlashCmdList["CFFRAMES"] = function()
	Settings.OpenToCategory(category:GetID())
end
