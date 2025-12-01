local addon = cfFrames

local levelText
local xpBar

local function UpdateXP()
    if not UnitExists("pet") then
        xpBar:Hide()
        return
    end
    local currXP, nextXP = GetPetExperience()
    if nextXP > 0 then
        xpBar:SetMinMaxValues(0, nextXP)
        xpBar:SetValue(currXP)
        xpBar:Show()
    else
        xpBar:Hide()
    end
end

local function UpdateLevel()
    if UnitExists("pet") and UnitLevel("pet") ~= UnitLevel("player") then
        levelText:SetText(UnitLevel("pet"))
        levelText:Show()
    else
        levelText:Hide()
    end
end

local function Initialize()
    if not cfFramesDB[addon.MODULES.PET_LEVEL] then return end

    local levelFrame = CreateFrame("Frame", nil, PetFrame)
    levelFrame:SetFrameLevel(PetFrame:GetFrameLevel() + 10)

    levelText = levelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local font = levelText:GetFont()
    levelText:SetFont(font, 10)
    levelText:SetPoint("CENTER", PetFrame, "TOPLEFT", 10, -40)

    -- XP bar below pet portrait
    xpBar = CreateFrame("StatusBar", nil, PetFrame)
    xpBar:SetSize(40, 5)
    xpBar:SetPoint("TOP", PetFrame, "BOTTOM", -40, 5)
    xpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    xpBar:SetStatusBarColor(0.6, 0, 0.6)

    local bg = xpBar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.7)

    local f = CreateFrame("Frame")
    f:RegisterEvent("UNIT_PET")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("PLAYER_LEVEL_UP")
    f:RegisterUnitEvent("UNIT_LEVEL", "pet")
    f:RegisterEvent("UNIT_PET_EXPERIENCE")
    f:SetScript("OnEvent", function(self, event)
        if event == "UNIT_PET_EXPERIENCE" then
            UpdateXP()
        elseif event == "PLAYER_LEVEL_UP" or event == "UNIT_LEVEL" then
            UpdateLevel()
        else
            UpdateLevel()
            UpdateXP()
        end
    end)

    UpdateLevel()
    UpdateXP()
end

addon:RegisterModuleInit(Initialize)
