local M = cff.MODULES
local hooked = false

local function SetStatusBarTexture(bar)
	if not bar then return end
	local newTex = cff.GetStatusBarTexture()
	if not newTex then return end
	local tex = bar:GetStatusBarTexture()
	local layer, sublevel
	if tex then layer, sublevel = tex:GetDrawLayer() end
	bar:SetStatusBarTexture(newTex)
	if layer then bar:GetStatusBarTexture():SetDrawLayer(layer, sublevel or 0) end
end

local function SetStaticBars()
	SetStatusBarTexture(PlayerFrameHealthBar)
	SetStatusBarTexture(PlayerFrameManaBar)
	SetStatusBarTexture(TargetFrameHealthBar)
	SetStatusBarTexture(TargetFrameManaBar)
	SetStatusBarTexture(PetFrameHealthBar)
	SetStatusBarTexture(PetFrameManaBar)
	SetStatusBarTexture(CastingBarFrame)
	SetStatusBarTexture(TargetFrameSpellBar)
	SetStatusBarTexture(PetSpellBar)
	SetStatusBarTexture(MainMenuExpBar)
	local tex = cff.GetStatusBarTexture()
	if tex then
		if TargetFrameNameBackground then TargetFrameNameBackground:SetTexture(tex) end
		if ExhaustionLevelFillBar then ExhaustionLevelFillBar:SetTexture(tex) end
	end
	if ReputationWatchBar then SetStatusBarTexture(ReputationWatchBar.StatusBar) end
	for i = 1, 5 do
		local frame = _G["CompactRaidFrame" .. i]
		if frame then
			SetStatusBarTexture(frame.healthBar)
			SetStatusBarTexture(frame.powerBar)
		end
	end
	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		if plate.UnitFrame then SetStatusBarTexture(plate.UnitFrame.healthBar) end
	end
end

local function HookDynamicBars()
	hooksecurefunc("UnitFrameHealthBar_Update", function(bar)
		SetStatusBarTexture(bar)
	end)
	hooksecurefunc("UnitFrameManaBar_UpdateType", function(bar)
		SetStatusBarTexture(bar)
	end)

	if CompactUnitFrame_UpdateHealthColor then
		hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
			if not frame then return end
			SetStatusBarTexture(frame.healthBar)
			SetStatusBarTexture(frame.powerBar)
		end)
	end
end

local function RegisterEventBars()
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	frame:SetScript("OnEvent", function(_, _, unit)
		local plate = C_NamePlate.GetNamePlateForUnit(unit)
		if plate and plate.UnitFrame then SetStatusBarTexture(plate.UnitFrame.healthBar) end
	end)
end

function cff.EnableStatusBar()
	SetStaticBars()

	if hooked then return end
	if not cff.GetStatusBarTexture() then return end
	hooked = true

	HookDynamicBars()
	RegisterEventBars()
end
