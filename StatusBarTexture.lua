local M = cff.MODULES
local hooked = false

local function SetStatusBarTexture(bar)
	if not bar then return end
	local tex = cff.GetStatusBarTexture()
	local old = bar:GetStatusBarTexture()
	local layer, sublevel
	if old then layer, sublevel = old:GetDrawLayer() end
	bar:SetStatusBarTexture(tex)
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
	if TargetFrameNameBackground then TargetFrameNameBackground:SetTexture(tex) end
	if ExhaustionLevelFillBar then ExhaustionLevelFillBar:SetTexture(tex) end
	if ReputationWatchBar then SetStatusBarTexture(ReputationWatchBar.StatusBar) end
	for i = 1, MAX_PARTY_MEMBERS do
		local party = _G["PartyMemberFrame" .. i]
		if party then
			SetStatusBarTexture(party.healthBar)
			SetStatusBarTexture(party.manaBar)
		end
	end
	for i = 1, MEMBERS_PER_RAID_GROUP do
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
		if not cfFramesDB[M.StatusBar] then return end
		SetStatusBarTexture(bar)
	end)
	hooksecurefunc("UnitFrameManaBar_UpdateType", function(bar)
		if not cfFramesDB[M.StatusBar] then return end
		SetStatusBarTexture(bar)
	end)

	if CompactUnitFrame_UpdateHealthColor then
		hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
			if not cfFramesDB[M.StatusBar] then return end
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
		if not cfFramesDB[M.StatusBar] then return end
		local plate = C_NamePlate.GetNamePlateForUnit(unit)
		if plate and plate.UnitFrame then SetStatusBarTexture(plate.UnitFrame.healthBar) end
	end)
end

function cff.EnableStatusBar()
	SetStaticBars()

	if hooked then return end
	if not cfFramesDB[M.StatusBar] then return end
	hooked = true

	HookDynamicBars()
	RegisterEventBars()
end
