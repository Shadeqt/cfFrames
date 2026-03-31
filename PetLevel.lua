local text, bg, border

local function CreateLevelDisplay()
	local levelFrame = CreateFrame("Frame", nil, PetFrame)
	levelFrame:SetFrameLevel(PetFrame:GetFrameLevel() + 10)

	border = levelFrame:CreateTexture(nil, "OVERLAY")
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	border:SetSize(38, 38)
	border:SetPoint("CENTER", PetFrame, "BOTTOMLEFT", 15, 8)
	cfFrames.styleTexture(border)

	bg = levelFrame:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")
	bg:SetVertexColor(0, 0, 0, 0.3)
	bg:SetSize(16, 16)
	bg:SetPoint("CENTER", border, "CENTER", -7.5, 8)

	text = levelFrame:CreateFontString(nil, "OVERLAY", "GameNormalNumberFont")
	local font = text:GetFont()
	local _, _, flags = text:GetFont()
	text:SetFont(font, 8, flags)
	text:SetPoint("CENTER", border, "CENTER", -7.5, 8)
end

local function Update()
	if UnitExists("pet") and UnitLevel("pet") ~= UnitLevel("player") then
		text:SetText(UnitLevel("pet"))
		text:Show()
		bg:Show()
		border:Show()
	else
		text:Hide()
		bg:Hide()
		border:Hide()
	end
end

local function SetupEvents()
	local frame = CreateFrame("Frame")
	frame:RegisterUnitEvent("UNIT_PET", "player")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("PLAYER_LEVEL_UP")
	frame:RegisterUnitEvent("UNIT_LEVEL", "pet")
	frame:SetScript("OnEvent", Update)
end

function cfFrames.initPetLevel()
	CreateLevelDisplay()
	SetupEvents()
	Update()
end
