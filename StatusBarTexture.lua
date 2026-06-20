local _, addon = ...

-- StatusBarTexture (cfFramesTest's newest implementation): replace the fill texture of every unit-frame
-- bar with the chosen texture. SetStatusBarTexture only swaps the fill art; Blizzard's color is
-- preserved, so health stays green/class-colored and mana stays blue. (Bar COLOR lives in
-- ClassColors/Healthbars.lua.)
--
-- Most bars are named globals skinned once; the few Blizzard re-skins at runtime get a targeted hook:
-- power bars (UnitFrameManaBar_UpdateType), castbars (reset on cast start), target/ToT (reset on target
-- change), and the compact raid frames (DefaultCompactUnitFrameSetup).

-- Blizzard's default fill texture. The GUI's "Blizzard Default" dropdown entry stores this path, so
-- selecting it repaints every bar with Blizzard's own texture (the feature's "off"). Exposed so
-- Settings.lua's dropdown stores the exact same path.
local BLIZZARD_DEFAULT = "Interface\\TargetingFrame\\UI-StatusBar"
addon.BLIZZARD_DEFAULT = BLIZZARD_DEFAULT

-- The chosen texture, refreshed from cfFramesDB in SetupStatusBar; SkinBar reads it as an upvalue.
local SMOOTH
local hooked = false

-- Apply the chosen fill to a StatusBar, guarding nil bars. Preserve the original fill texture's draw
-- layer + sublevel across the swap: SetStatusBarTexture can land the new texture on a higher layer than
-- the bar's border (notably the castbars), painting over it. Restoring the captured layer keeps the
-- border above the fill exactly as before.
local function SkinBar(bar)
	if not (bar and bar.SetStatusBarTexture) then return end
	local oldFill = bar:GetStatusBarTexture()
	local layer, sublevel
	if oldFill then layer, sublevel = oldFill:GetDrawLayer() end
	bar:SetStatusBarTexture(SMOOTH)
	local newFill = bar:GetStatusBarTexture()
	if newFill and layer then newFill:SetDrawLayer(layer, sublevel) end
end

-- Bars that exist at login and Blizzard does not re-skin afterward.
local function SkinStaticBars()
	SkinBar(PlayerFrameHealthBar)
	SkinBar(PlayerFrameManaBar)

	SkinBar(PetFrameHealthBar)
	SkinBar(PetFrameManaBar)

	-- Party 1-4: health, mana, and the optional pet health bar (party pets are health-only).
	for i = 1, MAX_PARTY_MEMBERS or 4 do
		SkinBar(_G["PartyMemberFrame" .. i .. "HealthBar"])
		SkinBar(_G["PartyMemberFrame" .. i .. "ManaBar"])
		SkinBar(_G["PartyMemberFrame" .. i .. "PetFrameHealthBar"])
	end

	-- XP bar and reputation watch bar (a member of ReputationWatchBar in Era).
	SkinBar(MainMenuExpBar)
	if ReputationWatchBar then SkinBar(ReputationWatchBar.StatusBar) end
end

-- Target-of-target bars. SkinBar nil-guards in case the ToT frame isn't built yet.
local function SkinToTBars()
	SkinBar(TargetFrameToTHealthBar)
	SkinBar(TargetFrameToTManaBar)
end

-- Target + Target-of-Target. Re-applied on every target change: Blizzard rebuilds/repaints these in
-- TargetFrame_CheckClassification, which can drop our fill texture.
local function SkinTargetBars()
	SkinBar(TargetFrameHealthBar)
	SkinBar(TargetFrameManaBar)
	SkinToTBars()
end

-- Castbars reset their fill texture when a cast starts, so re-assert ours on every spellbar event.
local function HookCastbar(bar)
	if not bar then return end
	SkinBar(bar)
	bar:HookScript("OnEvent", function(self) SkinBar(self) end)
end

local function SkinCastbars()
	HookCastbar(CastingBarFrame)     -- player
	HookCastbar(TargetFrameSpellBar) -- target
end

-- Skin a single compact frame's health and (optional) power bar.
local function SkinCompactFrame(frame)
	if not frame then return end
	SkinBar(frame.healthBar)
	SkinBar(frame.powerBar)
end

-- Compact raid frames are generated/reused dynamically; skin each as DefaultCompactUnitFrameSetup runs.
local function SkinCompactRaidFrames()
	if type(DefaultCompactUnitFrameSetup) ~= "function" then return end
	hooksecurefunc("DefaultCompactUnitFrameSetup", SkinCompactFrame)
end

-- Skin every nameplate health bar currently up.
local function SkinCurrentNameplates()
	if not C_NamePlate then return end
	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		if plate.UnitFrame then SkinBar(plate.UnitFrame.healthBar) end
	end
end

local function SkinNameplates()
	SkinCurrentNameplates()
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	frame:SetScript("OnEvent", function(_, _, unit)
		local plate = C_NamePlate.GetNamePlateForUnit(unit)
		if plate and plate.UnitFrame then SkinBar(plate.UnitFrame.healthBar) end
	end)
end

-- Blizzard repaints every mana/power bar's fill in UnitFrameManaBar_UpdateType (at login and on each
-- power-type change), reverting our texture. One hook covers player/pet/party/target/ToT power bars.
local function SkinPowerBars()
	if type(UnitFrameManaBar_UpdateType) ~= "function" then return end
	hooksecurefunc("UnitFrameManaBar_UpdateType", function(manaBar) SkinBar(manaBar) end)
end

-- Repaint every bar currently present with the live SMOOTH. No hook installs, so it's safe to re-call --
-- the settings dropdown binds to SetupStatusBar for an immediate texture change without a reload.
-- "Blizzard Default" is just the UI-StatusBar path, so selecting it repaints bars vanilla.
local function ApplyToCurrentBars()
	SkinStaticBars()
	SkinTargetBars()
	SkinBar(CastingBarFrame)
	SkinBar(TargetFrameSpellBar)
	for i = 1, MAX_RAID_MEMBERS or 40 do
		SkinCompactFrame(_G["CompactRaidFrame" .. i])
	end
	SkinCurrentNameplates()
end

-- Idempotent: Init calls this once at PLAYER_ENTERING_WORLD; the GUI texture dropdown re-calls it live
-- (its OnValueChanged). Refreshes SMOOTH from the DB, installs the runtime re-skin hooks once, repaints.
function addon.SetupStatusBar()
	SMOOTH = cfFramesDB.StatusBarTexture
	if not hooked then
		hooked = true
		SkinPowerBars()
		SkinCastbars()
		SkinCompactRaidFrames()
		SkinNameplates()
		hooksecurefunc("TargetFrame_CheckClassification", SkinTargetBars)
		-- The ToT can appear/change without a main-target change, and its frame may not exist until
		-- first shown -- so also re-skin it on every ToT update.
		if type(TargetofTarget_Update) == "function" then
			hooksecurefunc("TargetofTarget_Update", SkinToTBars)
		end
	end
	ApplyToCurrentBars()
end
