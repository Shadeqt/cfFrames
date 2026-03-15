local M = cfFrames.MODULES

local levelText, levelBg, levelBorder

local function Update()
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

local function Setup()
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

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function()
	Update()
end)

local function Enable()
	if not levelText then Setup() end
	frame:RegisterEvent("UNIT_PET")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("PLAYER_LEVEL_UP")
	frame:RegisterUnitEvent("UNIT_LEVEL", "pet")
	Update()
end

local function Disable()
	frame:UnregisterAllEvents()
	if levelText then levelText:Hide() end
	if levelBg then levelBg:Hide() end
	if levelBorder then levelBorder:Hide() end
end

cfFrames:RegisterModule(M.PET_LEVEL, Enable, Disable)
