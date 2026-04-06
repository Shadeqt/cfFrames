local M = cff.MODULES
local V = cff.VALUES
local borders = {}

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
	borders[#borders + 1] = border
	return border
end

local function ColorBorder(border)
	if not border then return end
	local c = cfFramesDB[V.DarkModeColor]
	border:SetBackdropBorderColor(c, c, c, 1)
	--border:SetBackdropBorderColor(1, 0, 0, 1)
	border:Show()
end

local function StyleIcon(button)
	local icon = GetIcon(button)
	if not icon then return end
	if not button.cffZoom then
		button.cffZoom = true
		icon:SetTexCoord(unpack(ZOOM))
	end
	local border = AddBorder(icon, button)
	ColorBorder(border)
end

-- Buffs

local function StylePlayerBuffs()
	for i = 1, BUFF_MAX_DISPLAY do
		local btn = _G["BuffButton" .. i]
		if not btn then break end
		if btn:IsShown() then StyleIcon(btn) end
	end

	if AuraButton_Update then
		hooksecurefunc("AuraButton_Update", function(buttonName, index)
			if not cfFramesDB[M.DarkMode] or not cfFramesDB[M.DarkModeIconBuffs] then return end
			if buttonName == "DebuffButton" then return end
			local btn = _G[buttonName .. index]
			if not btn then return end
			StyleIcon(btn)
		end)
	end
end

local function StyleTargetBuffs()
	for i = 1, MAX_TARGET_BUFFS do
		local btn = _G["TargetFrameBuff" .. i]
		if not btn then break end
		if btn:IsShown() then StyleIcon(btn) end
	end

	if TargetFrame_UpdateAuras then
		hooksecurefunc("TargetFrame_UpdateAuras", function()
			if not cfFramesDB[M.DarkMode] or not cfFramesDB[M.DarkModeIconBuffs] then return end
			for i = 1, MAX_TARGET_BUFFS do
				local btn = _G["TargetFrameBuff" .. i]
				if btn and btn:IsShown() then StyleIcon(btn) end
			end
		end)
	end
end

local function StylePetBuffs()
	for i = 1, 16 do
		local btn = _G["PetFrameBuff" .. i]
		if not btn then break end
		if btn:IsShown() then StyleIcon(btn) end
	end

	local f = CreateFrame("Frame")
	f:RegisterUnitEvent("UNIT_AURA", "pet")
	f:SetScript("OnEvent", function()
		if not cfFramesDB[M.DarkMode] or not cfFramesDB[M.DarkModeIconBuffs] then return end
		for i = 1, 16 do
			local btn = _G["PetFrameBuff" .. i]
			if not btn then break end
			if btn:IsShown() then StyleIcon(btn) end
		end
	end)
end

local function StyleCompactBuffs()
	EventUtil.ContinueOnAddOnLoaded("Blizzard_UnitFrame", function()
		if CompactUnitFrame_UtilSetBuff then
			hooksecurefunc("CompactUnitFrame_UtilSetBuff", function(buffFrame)
				if not cfFramesDB[M.DarkMode] or not cfFramesDB[M.DarkModeIconBuffs] then return end
				StyleIcon(buffFrame)
			end)
		end
	end)
end

-- Action Bars

local function StyleActionBars()
	local bars = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton", "MultiBarLeftButton" }
	for _, bar in ipairs(bars) do
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

-- Castbar Icons

local function StyleCastbarIcon(bar)
	if not bar or not bar.Icon then return end
	local icon = bar.Icon
	if not bar.cffZoom then
		bar.cffZoom = true
		icon:SetTexCoord(unpack(ZOOM))
	end
	local border = AddBorder(icon, bar)
	ColorBorder(border)
end

local function StyleCastbarIcons()
	StyleCastbarIcon(CastingBarFrame)
	StyleCastbarIcon(TargetFrameSpellBar)

	if CastingBarFrame and not CastingBarFrame.cffIconBorderHooked then
		CastingBarFrame.cffIconBorderHooked = true
		hooksecurefunc(CastingBarFrame, "Show", function(self)
			if cfFramesDB[M.DarkMode] and cfFramesDB[M.DarkModeIconCastbars] then
				StyleCastbarIcon(self)
			end
		end)
	end

	if TargetFrameSpellBar and not TargetFrameSpellBar.cffIconBorderHooked then
		TargetFrameSpellBar.cffIconBorderHooked = true
		hooksecurefunc(TargetFrameSpellBar, "Show", function(self)
			if cfFramesDB[M.DarkMode] and cfFramesDB[M.DarkModeIconCastbars] then
				StyleCastbarIcon(self)
			end
		end)
	end
end

function cff.StylePetCastbarIcon(bar)
	if not cfFramesDB[M.DarkMode] or not cfFramesDB[M.DarkModeIconCastbars] then return end
	StyleCastbarIcon(bar)
end

function cff.StyleNameplateCastbarIcon(bar)
	if not cfFramesDB[M.DarkMode] or not cfFramesDB[M.DarkModeIconCastbars] then return end
	StyleCastbarIcon(bar)
end

-- Enable / Disable

function cff.EnableDarkModeIcons()
	if not cfFramesDB[M.DarkMode] then return end
	if cfFramesDB[M.DarkModeIconBuffs] then
		StylePlayerBuffs()
		StyleTargetBuffs()
		StylePetBuffs()
		StyleCompactBuffs()
	end
	if cfFramesDB[M.DarkModeIconActionBars] then
		StyleActionBars()
	end
	if cfFramesDB[M.DarkModeIconCastbars] then
		StyleCastbarIcons()
	end
end

function cff.DisableDarkModeIcons()
	for _, border in ipairs(borders) do
		border:Hide()
		local icon = GetIcon(border:GetParent())
		if icon then icon:SetTexCoord(0, 1, 0, 1) end
		border:GetParent().cffZoom = nil
	end
end
