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
T[M.BIGGER_HEALTHBAR] = "Enlarge the health bar on player and target frames using custom border textures"
T[M.DARK_MODE] = "Darken unit frame borders, action bars, minimap, and buff icons"
T[M.HEALTHBAR_COLOR] = "Color health bars by class for players and by reaction for NPCs"
T[M.ICON_ZOOM] = "Crop icon edges on action bars and buff icons"
T[M.BUFF_SIZE] = "Resize player buff and debuff icons to match action bar size"

local scrollChild = W.CreateScrollPanel(panel)

-- Mod Integrations
local title = W.CreateTitle(scrollChild, "cfFrames")
local modsHeader = W.CreateHeader(title, "Mod Integrations")
local modsSection = W.CreateSection(modsHeader)
local bbfIntegration = W.CreateCheckbox(modsSection, "BetterBlizzFrames", M.BBF_INTEGRATION)
local questieIntegration = W.CreateCheckbox(bbfIntegration, "Questie", M.QUESTIE_INTEGRATION, COL2)

bbfIntegration:HookScript("OnShow", function(self)
	if not C_AddOns.IsAddOnLoaded("BetterBlizzFrames") then
		self:Disable()
		self.Text:SetTextColor(0.5, 0.5, 0.5)
		T[M.BBF_INTEGRATION] = "BetterBlizzFrames addon not found"
	end
end)
questieIntegration:HookScript("OnShow", function(self)
	if not C_AddOns.IsAddOnLoaded("Questie") then
		self:Disable()
		self.Text:SetTextColor(0.5, 0.5, 0.5)
		T[M.QUESTIE_INTEGRATION] = "Questie addon not found"
	end
end)

-- General
local generalHeader = W.CreateHeader(modsSection, "General")
local generalSection = W.CreateSection(generalHeader)
local darkMode = W.CreateCheckbox(generalSection, "Dark Mode", M.DARK_MODE)
local biggerHealthbar = W.CreateCheckbox(darkMode, "Bigger Healthbars", M.BIGGER_HEALTHBAR)
local healthbarColor = W.CreateCheckbox(biggerHealthbar, "Healthbar Colors", M.HEALTHBAR_COLOR, COL2)
local statusBarTexture = W.CreateCheckbox(biggerHealthbar, "Status Bar Texture", M.STATUS_BAR_TEXTURE)
local targetStatusText = W.CreateCheckbox(statusBarTexture, "Show Target Status Text", M.TARGET_FRAME_STATUS_TEXT)
local experienceBar = W.CreateCheckbox(targetStatusText, "Show Experience Bar Text", M.EXPERIENCE_BAR, COL2)
local nameplateCastbar = W.CreateCheckbox(targetStatusText, "Show Enemy Cast Bars", M.NAMEPLATE_CASTBAR)
local iconZoom = W.CreateCheckbox(nameplateCastbar, "Icon Zoom", M.ICON_ZOOM)
local buffSize = W.CreateCheckbox(iconZoom, "Buff Size", M.BUFF_SIZE, COL2)

-- Player Frame
local playerHeader = W.CreateHeader(generalSection, "Player Frame")
local playerSection = W.CreateSection(playerHeader)
local playerGlow = W.CreateCheckbox(playerSection, "Hide Combat Glow", M.PLAYER_COMBAT_GLOW)
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

local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name, panel.name)
Settings.RegisterAddOnCategory(category)

SLASH_CFFRAMES1 = "/cff"
SlashCmdList["CFFRAMES"] = function()
	Settings.OpenToCategory(category:GetID())
end
