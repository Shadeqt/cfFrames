local bar

local function CreateBar()
	bar = CreateFrame("StatusBar", nil, PetFrame)
	bar:SetSize(40, 6)
	bar:SetPoint("TOP", PetFrame, "BOTTOM", -40, 5)
	bar:SetStatusBarTexture(cfFrames.getBarTexture())
	bar:SetStatusBarColor(0.58, 0, 0.55)

	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(0, 0, 0, 0.3)

	local border = bar:CreateTexture(nil, "OVERLAY")
	border:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-BarBorder")
	border:SetSize(42, 12)
	border:SetPoint("CENTER", bar, "CENTER", 0, 0)
end

local function Update()
	if not UnitExists("pet") or UnitLevel("pet") == UnitLevel("player") then
		bar:Hide()
		return
	end
	local currXP, nextXP = GetPetExperience()
	if nextXP > 0 then
		bar:SetMinMaxValues(0, nextXP)
		bar:SetValue(currXP)
		bar:Show()
	else
		bar:Hide()
	end
end

local function SetupEvents()
	local frame = CreateFrame("Frame")
	frame:RegisterUnitEvent("UNIT_PET", "player")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("PLAYER_LEVEL_UP")
	frame:RegisterUnitEvent("UNIT_LEVEL", "pet")
	frame:RegisterEvent("UNIT_PET_EXPERIENCE")
	frame:SetScript("OnEvent", Update)
end

function cfFrames.initPetXpBar()
	CreateBar()
	SetupEvents()
	Update()
end
