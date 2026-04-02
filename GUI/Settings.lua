local F = cfFrames.Factory
local M = cfFrames.M
local COL2 = 250

local panel = CreateFrame("Frame", "cfFramesSettingsPanel")
panel.name = "cfFrames"
panel:Hide()

local sc = F.CreateScrollPanel(panel)
local title = F.CreateTitle(sc, "cfFrames")

-- Fixes
local hFixes            = F.CreateHeader(title, "Fixes")
local nameplateLevelFix = F.CreateCheckbox(hFixes, "Nameplate Level Fix", M.NameplateLevelFix, nil, "Adjust nameplate level text position")
local castbarTargetFix  = F.CreateCheckbox(nameplateLevelFix, "Target Castbar Fix", M.CastbarTargetFix, COL2, "Widen target castbar border")
local portraitToTFix    = F.CreateCheckbox(nameplateLevelFix, "ToT Portrait Fix", M.ToTPortraitFix, nil, "Fix Target of Target portrait alignment")
local nameTargetFix     = F.CreateCheckbox(portraitToTFix, "Target Name Fix", M.NameTargetFix, COL2, "Widen target name to reduce truncation")

-- General
local h1           = F.CreateHeader(portraitToTFix, "General")
local darkMode     = F.CreateCheckbox(h1, "Dark Mode", M.DarkMode, nil, "Darken all UI frame textures")
local blueShamans  = F.CreateCheckbox(darkMode, "Blue Shamans", M.BlueShamans, COL2, "Modern blue shaman class color")
local expBarQuests = F.CreateCheckbox(darkMode, "XP Bar Quest Overlay", M.ExperienceBarQuests, nil, "Show pending quest XP on experience bar")
local druidBar = F.CreateDropdown(expBarQuests, "Druid Bar", M.DruidBar, {
	{ label = "Blizzard", value = "blizzard" },
	{ label = "Toast", value = "Interface\\FriendsFrame\\UI-Toast-Border" },
	{ label = "Dialog", value = "Interface\\DialogFrame\\UI-DialogBox-Border" },
}, "Choose druid mana bar border")

-- Unit Frames
local h2              = F.CreateHeader(druidBar, "Unit Frames")
local statusBarChoice = F.CreateDropdown(h2, "Status Bar Texture", M.StatusBarTexture, {
	{ label = "Blizzard", value = "blizzard" },
	{ label = "Retail Bar", value = "Interface\\AddOns\\cfFrames\\Media\\StatusBar\\BlizzardRetailBarCrop2" },
	{ label = "Dragonflight", value = "Interface\\AddOns\\cfFrames\\Media\\StatusBar\\DragonflightTexture" },
}, "Choose status bar texture")
local biggerHealthbar = F.CreateCheckbox(statusBarChoice, "Bigger Healthbars", M.BiggerHealthbar, nil, "Enlarge player and target health bars")
local statusText      = F.CreateCheckbox(biggerHealthbar, "Status Text", M.StatusText, COL2, "Show health/mana text on bars")
local healthbarColor  = F.CreateCheckbox(biggerHealthbar, "Healthbar Color", M.HealthbarColor, nil, "Class-colored health bars")
local hitIndicator    = F.CreateCheckbox(healthbarColor, "Hide Hit Indicator", M.HitIndicator, COL2, "Hide hit text on player and pet")
local combatGlow      = F.CreateCheckbox(healthbarColor, "Hide Combat Glow", M.CombatGlow, nil, "Hide combat glow on player and pet")
local nameBackground  = F.CreateCheckbox(combatGlow, "Hide Name Background", M.NameBackground, COL2, "Hide the target name background")
local groupIndicator  = F.CreateCheckbox(combatGlow, "Hide Group Indicator", M.GroupIndicator, nil, "Hide group number on player frame")

-- Nameplates
local h3               = F.CreateHeader(groupIndicator, "Nameplates")
local nameplateCastbar = F.CreateCheckbox(h3, "Nameplate Castbar", M.NameplateCastbar, nil, "Show cast bars on nameplates")
local nameplateClass   = F.CreateCheckbox(nameplateCastbar, "Classification Icons", M.NameplateClassification, COL2, "Show elite/rare icons on nameplates")

-- Icons
local h4              = F.CreateHeader(nameplateClass, "Icons")
local iconBorderChoice = F.CreateDropdown(h4, "Icon Border", M.IconBorder, {
	{ label = "Blizzard", value = "blizzard" },
	{ label = "Tooltip", value = "Interface\\Tooltips\\UI-Tooltip-Border" },
	{ label = "Dialog", value = "Interface\\DialogFrame\\UI-DialogBox-Border" },
}, "Choose icon border style")
local iconZoom    = F.CreateCheckbox(iconBorderChoice, "Icon Zoom", M.IconZoom, nil, "Crop icon edges on action bars and auras")
local castbarIcon = F.CreateCheckbox(iconZoom, "Player Castbar Icon", M.CastbarPlayerIcon, COL2, "Show spell icon on player cast bar")

-- Pet
local h5            = F.CreateHeader(castbarIcon, "Pet")
local petLevel      = F.CreateCheckbox(h5, "Pet Level", M.PetLevel, nil, "Show pet level when different from player")
local petXpBar      = F.CreateCheckbox(petLevel, "Pet XP Bar", M.PetXpBar, COL2, "Show pet experience bar")
local petName       = F.CreateCheckbox(petLevel, "Pet Name", M.PetName, nil, "Reposition pet name above health bar")
local petDebuffs    = F.CreateCheckbox(petName, "Pet Debuffs", M.PetDebuffs, COL2, "Show debuff icons on pet frame")
local petStatusText = F.CreateCheckbox(petName, "Pet Status Text", M.PetStatusText, nil, "Smaller text on pet health/mana bars")

-- Register
local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name, panel.name)
cfFrames.category = category
Settings.RegisterAddOnCategory(category)

SLASH_CFFRAMES1 = "/cff"
SlashCmdList["CFFRAMES"] = function()
	Settings.OpenToCategory(category:GetID())
end

-- Make the Options window draggable
if SettingsPanel then
	SettingsPanel:SetMovable(true)
	SettingsPanel:EnableMouse(true)
	SettingsPanel:RegisterForDrag("LeftButton")
	SettingsPanel:SetScript("OnDragStart", SettingsPanel.StartMoving)
	SettingsPanel:SetScript("OnDragStop", SettingsPanel.StopMovingOrSizing)
end
