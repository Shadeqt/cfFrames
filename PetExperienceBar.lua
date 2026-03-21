local M = cfFrames.MODULES

local xpBar

local function Update()
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

local function Setup()
	xpBar = CreateFrame("StatusBar", nil, PetFrame)
	xpBar:SetSize(46, 6)
	xpBar:SetPoint("TOP", PetFrame, "BOTTOM", -40, 5)
	local expTex = MainMenuExpBar and MainMenuExpBar:GetStatusBarTexture()
	xpBar:SetStatusBarTexture(expTex and expTex:GetTexture() or "Interface\\TargetingFrame\\UI-StatusBar")
	xpBar:SetStatusBarColor(0.58, 0, 0.55)

	local bg = xpBar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(0, 0, 0, 0.3)

	local border = xpBar:CreateTexture(nil, "OVERLAY")
	border:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-BarBorder")
	border:SetSize(48, 12)
	border:SetPoint("CENTER", xpBar, "CENTER", 0, 0)
	cfFrames.petXpBarBorder = border
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function()
	Update()
end)

local function Enable()
	if not xpBar then Setup() end
	frame:RegisterEvent("UNIT_PET")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("PLAYER_LEVEL_UP")
	frame:RegisterUnitEvent("UNIT_LEVEL", "pet")
	frame:RegisterEvent("UNIT_PET_EXPERIENCE")
	Update()
end

local function Disable()
	frame:UnregisterAllEvents()
	if xpBar then xpBar:Hide() end
end

cfFrames:RegisterModule(M.PET_XP_BAR, Enable, Disable)
