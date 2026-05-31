local _, addon = ...

-- Blizzard's default fill texture. The GUI's "Blizzard Default" dropdown entry stores this path,
-- which is how the feature is turned off: selecting it repaints bars with Blizzard's own texture
-- and skips the dynamic hooks.
local BLIZZARD_DEFAULT = "Interface\\TargetingFrame\\UI-StatusBar"
local hooked = false

local function GetTexture()
	return cfFramesDB.StatusBarTexture
end

local function IsEnabled()
	return cfFramesDB.StatusBarTexture ~= BLIZZARD_DEFAULT
end

-- SetStatusBarTexture resets the fill's draw layer and clears its color. Capture the layer before
-- the swap and re-apply it after, so consumers that pin overlays to the fill's layer (cfQuestXP)
-- or mirror the bar (cfDruidBar, cfPet) stay correct across a retexture.
local function SetBarTexture(bar)
	if not bar then return end
	local texture = GetTexture()
	local old = bar:GetStatusBarTexture()
	local layer, sublevel
	if old then layer, sublevel = old:GetDrawLayer() end
	bar:SetStatusBarTexture(texture)
	if layer then bar:GetStatusBarTexture():SetDrawLayer(layer, sublevel or 0) end
end

local function SetStaticBars()
	SetBarTexture(PlayerFrameHealthBar)
	SetBarTexture(PlayerFrameManaBar)
	SetBarTexture(TargetFrameHealthBar)
	SetBarTexture(TargetFrameManaBar)
	SetBarTexture(PetFrameHealthBar)
	SetBarTexture(PetFrameManaBar)
	SetBarTexture(CastingBarFrame)
	SetBarTexture(TargetFrameSpellBar)
	SetBarTexture(PetSpellBar)
	SetBarTexture(MainMenuExpBar)
	local texture = GetTexture()
	if TargetFrameNameBackground then TargetFrameNameBackground:SetTexture(texture) end
	if ExhaustionLevelFillBar then ExhaustionLevelFillBar:SetTexture(texture) end
	if ReputationWatchBar then SetBarTexture(ReputationWatchBar.StatusBar) end
	for i = 1, MAX_PARTY_MEMBERS do
		local name = "PartyMemberFrame" .. i
		if _G[name] then
			-- Use the global bar refs; the .healthBar/.manaBar fields are nil-cased in Era.
			SetBarTexture(_G[name .. "HealthBar"])
			SetBarTexture(_G[name .. "ManaBar"])
		end
	end
	for i = 1, MEMBERS_PER_RAID_GROUP do
		local frame = _G["CompactRaidFrame" .. i]
		if frame then
			SetBarTexture(frame.healthBar)
			SetBarTexture(frame.powerBar)
		end
	end
	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		if plate.UnitFrame then SetBarTexture(plate.UnitFrame.healthBar) end
	end
end

-- Re-skin bars Blizzard repaints on its own updates. Installed once, only when enabled; each hook
-- re-checks IsEnabled() so a live switch to "Blizzard Default" makes them no-op without uninstalling.
local function HookDynamicBars()
	hooksecurefunc("UnitFrameHealthBar_Update", function(bar)
		if IsEnabled() then SetBarTexture(bar) end
	end)
	hooksecurefunc("UnitFrameManaBar_UpdateType", function(bar)
		if IsEnabled() then SetBarTexture(bar) end
	end)
	if CompactUnitFrame_UpdateHealthColor then
		hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
			if not IsEnabled() or not frame then return end
			SetBarTexture(frame.healthBar)
			SetBarTexture(frame.powerBar)
		end)
	end
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	frame:SetScript("OnEvent", function(_, _, unit)
		if not IsEnabled() then return end
		local plate = C_NamePlate.GetNamePlateForUnit(unit)
		if plate and plate.UnitFrame then SetBarTexture(plate.UnitFrame.healthBar) end
	end)
end

-- Idempotent: the GUI texture dropdown re-calls this live. SetStaticBars repaints every surface
-- each call; the hooked guard prevents duplicate hook installs.
function addon.SetupStatusBar()
	SetStaticBars()
	if hooked then return end
	if not IsEnabled() then return end
	hooked = true
	HookDynamicBars()
end
