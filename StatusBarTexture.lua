local M = cfFrames.MODULES
local TEXTURE = "Interface\\AddOns\\cfFrames\\Media\\BlizzardRetailBarCrop2"
local DEFAULT_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"

local UNIT_BARS = {
	PlayerFrameHealthBar, PlayerFrameManaBar,
	TargetFrameHealthBar, TargetFrameManaBar,
	TargetFrameToTHealthBar, TargetFrameToTManaBar,
	PetFrameHealthBar, PetFrameManaBar,
}

local function SetBarTexture(bar, texture)
	local tex = bar:GetStatusBarTexture()
	local layer, sublevel = nil, nil
	if tex then layer, sublevel = tex:GetDrawLayer() end
	bar:SetStatusBarTexture(texture)
	if layer then bar:GetStatusBarTexture():SetDrawLayer(layer, sublevel or 0) end
end

local function SetAllTextures(texture)
	for _, bar in ipairs(UNIT_BARS) do
		if bar then SetBarTexture(bar, texture) end
	end
	for i = 1, 4 do
		local party = _G["PartyMemberFrame" .. i]
		if party then
			if party.healthbar then SetBarTexture(party.healthbar, texture) end
			if party.ManaBar then SetBarTexture(party.ManaBar, texture) end
		end
	end
	if TargetFrameNameBackground then
		TargetFrameNameBackground:SetTexture(texture)
	end
	if MainMenuExpBar then SetBarTexture(MainMenuExpBar, texture) end
	if ExhaustionLevelFillBar then ExhaustionLevelFillBar:SetTexture(texture) end
	if cfFrames.questOverlay then SetBarTexture(cfFrames.questOverlay, texture) end
	if ReputationWatchBar and ReputationWatchBar.StatusBar then
		SetBarTexture(ReputationWatchBar.StatusBar, texture)
	end
	if CastingBarFrame then SetBarTexture(CastingBarFrame, texture) end
	if TargetFrameSpellBar then SetBarTexture(TargetFrameSpellBar, texture) end
	if PetSpellBar then SetBarTexture(PetSpellBar, texture) end
end

local npFrame = CreateFrame("Frame")
npFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
npFrame:SetScript("OnEvent", function(_, _, unit)
	if not cfFramesDB[M.STATUS_BAR_TEXTURE] then return end
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	if not nameplate or not nameplate.UnitFrame then return end
	local healthBar = nameplate.UnitFrame.healthBar
	if healthBar then SetBarTexture(healthBar, TEXTURE) end
end)

hooksecurefunc("DefaultCompactUnitFrameSetup", function(frame)
	if not cfFramesDB[M.STATUS_BAR_TEXTURE] then return end
	if frame.healthBar then SetBarTexture(frame.healthBar, TEXTURE) end
	if frame.powerBar then SetBarTexture(frame.powerBar, TEXTURE) end
end)

hooksecurefunc("UnitFrameHealthBar_Update", function(bar)
	if not cfFramesDB[M.STATUS_BAR_TEXTURE] then return end
	SetBarTexture(bar, TEXTURE)
end)

hooksecurefunc("UnitFrameManaBar_UpdateType", function(bar)
	if not cfFramesDB[M.STATUS_BAR_TEXTURE] then return end
	SetBarTexture(bar, TEXTURE)
end)

cfFrames:RegisterModule(M.STATUS_BAR_TEXTURE, function()
	SetAllTextures(TEXTURE)
end, function()
	SetAllTextures(DEFAULT_TEXTURE)
end)
