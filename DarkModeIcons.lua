local _, addon = ...

-- DarkModeIcons (cfFramesTest's newest implementation): add dark borders + a slight zoom to action-bar
-- and buff icons, completing the dark look from DarkMode.lua. Reload-gated on cfFramesDB.DarkMode; run
-- once from Init's PLAYER_ENTERING_WORLD pass via SetupDarkModeIcons (so the aura hooks don't stack).
-- Castbar icons are NOT handled here -- cfCastbars owns its own (player/target/pet/party/nameplate) icon
-- borders via surface observation.

local PRIMARY = 0.25  -- icon border darkness
local ACTION_BAR_NAMES = addon.DarkMode.ACTION_BAR_NAMES  -- shared bar list (DarkMode.lua loads first)
local PET_BUFF_MAX = 16  -- PetFrameBuff slots (no Blizzard *_MAX constant for these)

-- zoom: left, right, top, bottom
local ZOOM = { 0.02, 0.98, 0.02, 0.98 }
-- offset: left, top, right, bottom
local OFFSET = { -1.2, 1.2, 1.2, -1.2 }

local function GetIcon(button)
	if not button then return end
	local icon = button.icon or button.Icon
	if not icon then
		local name = button:GetName()
		if name then icon = _G[name .. "Icon"] end
	end
	return icon
end

local function AddBorder(icon, button)
	if button.cffBorder then return button.cffBorder end
	local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
	border:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8.5 })
	border:SetPoint("TOPLEFT", icon, OFFSET[1], OFFSET[2])
	border:SetPoint("BOTTOMRIGHT", icon, OFFSET[3], OFFSET[4])
	button.cffBorder = border
	return border
end

local function ColorBorder(border)
	if not border then return end
	border:SetBackdropBorderColor(PRIMARY, PRIMARY, PRIMARY, 1)
	border:Show()
end

-- Idempotent: zoom once, border once. The cffStyled flag short-circuits repeat calls so the frequently-
-- fired aura hooks stop re-running SetBackdropBorderColor/Show on already-styled buttons every aura tick.
-- The flag is only set after a successful style, so a button whose icon isn't ready yet is retried.
local function StyleIcon(button)
	if button.cffStyled then return end
	local icon = GetIcon(button)
	if not icon then return end
	icon:SetTexCoord(unpack(ZOOM))
	ColorBorder(AddBorder(icon, button))
	button.cffStyled = true
end

-- Style each shown button in a contiguous _G[prefix..i] block (buff buttons are created contiguously).
local function StyleShownButtons(prefix, count)
	for i = 1, count do
		local btn = _G[prefix .. i]
		if not btn then break end
		if btn:IsShown() then StyleIcon(btn) end
	end
end

-- Buffs

local function StylePlayerBuffs()
	StyleShownButtons("BuffButton", BUFF_MAX_DISPLAY)

	if AuraButton_Update then
		hooksecurefunc("AuraButton_Update", function(buttonName, index)
			if buttonName == "DebuffButton" then return end
			local btn = _G[buttonName .. index]
			if not btn then return end
			StyleIcon(btn)
		end)
	end
end

local function StyleTargetBuffs()
	StyleShownButtons("TargetFrameBuff", MAX_TARGET_BUFFS)

	if TargetFrame_UpdateAuras then
		hooksecurefunc("TargetFrame_UpdateAuras", function()
			StyleShownButtons("TargetFrameBuff", MAX_TARGET_BUFFS)
		end)
	end
end

local function StylePetBuffs()
	StyleShownButtons("PetFrameBuff", PET_BUFF_MAX)

	local f = CreateFrame("Frame")
	f:RegisterUnitEvent("UNIT_AURA", "pet")
	f:SetScript("OnEvent", function()
		StyleShownButtons("PetFrameBuff", PET_BUFF_MAX)
	end)
end

local function StyleCompactBuffs()
	EventUtil.ContinueOnAddOnLoaded("Blizzard_UnitFrame", function()
		if CompactUnitFrame_UtilSetBuff then
			hooksecurefunc("CompactUnitFrame_UtilSetBuff", function(buffFrame)
				StyleIcon(buffFrame)
			end)
		end
	end)
end

-- Action Bars

local function StyleActionBars()
	for _, bar in ipairs(ACTION_BAR_NAMES) do
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			local btn = _G[bar .. i]
			if btn then StyleIcon(btn) end
		end
	end
	for i = 1, NUM_PET_ACTION_SLOTS do
		local btn = _G["PetActionButton" .. i]
		if btn then StyleIcon(btn) end
	end
	for i = 1, NUM_STANCE_SLOTS do
		local btn = _G["StanceButton" .. i]
		if btn then StyleIcon(btn) end
	end
	for i = 0, 3 do
		local btn = _G["CharacterBag" .. i .. "Slot"]
		if btn then StyleIcon(btn) end
	end
	if MainMenuBarBackpackButton then StyleIcon(MainMenuBarBackpackButton) end
end

-- Reload-gated; called once from Init's PLAYER_ENTERING_WORLD pass so the hooksecurefunc installs above
-- happen exactly once and don't stack.
function addon.SetupDarkModeIcons()
	if not cfFramesDB.DarkMode then return end
	StylePlayerBuffs()
	StyleTargetBuffs()
	StylePetBuffs()
	StyleCompactBuffs()
	StyleActionBars()
end
