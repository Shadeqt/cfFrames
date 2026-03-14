local M = cfFrames.MODULES

local showLevel, showXpBar
local levelText, levelBg, levelBorder
local xpBar

local function UpdateLevel()
	if not showLevel then return end
	if UnitExists("pet") and UnitLevel("pet") ~= UnitLevel("player") then
		levelText:SetText(UnitLevel("pet"))
		levelText:Show()
		levelBg:Show()
		if levelBorder then levelBorder:Show() end
	else
		levelText:Hide()
		levelBg:Hide()
		if levelBorder then levelBorder:Hide() end
	end
end

local function UpdateXP()
	if not showXpBar then return end
	if not UnitExists("pet") or UnitLevel("pet") == UnitLevel("player") then
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

local function SetupLevel()
	local levelFrame = CreateFrame("Frame", nil, PetFrame)
	levelFrame:SetFrameLevel(PetFrame:GetFrameLevel() + 10)

	levelBorder = levelFrame:CreateTexture(nil, "OVERLAY")
	levelBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	levelBorder:SetSize(38, 38)
	levelBorder:SetPoint("CENTER", PetFrame, "BOTTOMLEFT", 15, 8)
	cfFrames.petLevelBorder = levelBorder

	levelBg = levelFrame:CreateTexture(nil, "ARTWORK")
	levelBg:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")
	levelBg:SetVertexColor(0, 0, 0, 0.3)
	levelBg:SetSize(16, 16)
	levelBg:SetPoint("CENTER", levelBorder, "CENTER", -7.5, 8)

	levelText = levelFrame:CreateFontString(nil, "OVERLAY", "GameNormalNumberFont")
	local font = levelText:GetFont()
	levelText:SetFont(font, 8)
	levelText:SetPoint("CENTER", levelBorder, "CENTER", -7.5, 8)
end

local function SetupXpBar()
	xpBar = CreateFrame("StatusBar", nil, PetFrame)
	xpBar:SetSize(46, 6)
	xpBar:SetPoint("TOP", PetFrame, "BOTTOM", -40, 5)
	xpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	xpBar:SetStatusBarColor(0.58, 0, 0.55)

	local bg = xpBar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(0, 0, 0, 0.3)

	-- Border (same as skill bars)
	local border = xpBar:CreateTexture(nil, "OVERLAY")
	border:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-BarBorder")
	border:SetSize(48, 12)
	border:SetPoint("CENTER", xpBar, "CENTER", 0, 0)
	cfFrames.petXpBarBorder = border
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 ~= "cfFrames" then return end
		self:UnregisterEvent("ADDON_LOADED")

		showLevel = cfFramesDB[M.PET_LEVEL]
		showXpBar = cfFramesDB[M.PET_XP_BAR]
		if not showLevel and not showXpBar then return end

		if showLevel then SetupLevel() end
		if showXpBar then SetupXpBar() end

		self:RegisterEvent("UNIT_PET")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("PLAYER_LEVEL_UP")
		self:RegisterUnitEvent("UNIT_LEVEL", "pet")
		self:RegisterEvent("UNIT_PET_EXPERIENCE")

		UpdateLevel()
		UpdateXP()
	else
		UpdateLevel()
		UpdateXP()
	end
end)
