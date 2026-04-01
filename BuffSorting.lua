-- Sorts player buffs (longest first) and target buffs (player large first, then ASC)

local sorted = {}
local targetSorted = {}

local function compareAsc(a, b)
	if a._sortKey ~= b._sortKey then return a._sortKey < b._sortKey end
	return a:GetID() < b:GetID()
end

local function compareDesc(a, b)
	if a._sortKey ~= b._sortKey then return a._sortKey > b._sortKey end
	return a:GetID() < b:GetID()
end

-- Player buffs: longest first
local function sortPlayerBuffs()
	for i = 1, BUFF_ACTUAL_DISPLAY do
		local button = _G["BuffButton" .. i]
		sorted[i] = button
		button._sortKey = button.timeLeft or math.huge
	end
	for i = BUFF_ACTUAL_DISPLAY + 1, #sorted do sorted[i] = nil end

	table.sort(sorted, compareDesc)

	for i, button in ipairs(sorted) do
		button:ClearAllPoints()
		if i == 1 then
			if BuffFrame.numEnchants > 0 then
				button:SetPoint("TOPRIGHT", TemporaryEnchantFrame, "TOPLEFT", BUFF_HORIZ_SPACING, 0)
			else
				button:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
			end
		elseif i % BUFFS_PER_ROW == 1 then
			button:SetPoint("TOPRIGHT", sorted[i - BUFFS_PER_ROW], "BOTTOMRIGHT", 0, -BUFF_ROW_SPACING)
		else
			button:SetPoint("RIGHT", sorted[i - 1], "LEFT", BUFF_HORIZ_SPACING, 0)
		end
	end
end

-- Target buffs: large (player-cast) first, then small, each group ASC
-- Blizzard constants
local LARGE = 21
local SMALL = 17
local AURA_START_X = 5
local AURA_START_Y = 32
local AURA_OFFSET_X = 2
local AURA_OFFSET_Y = 2
local AURA_ROW_WIDTH = 122
local TOT_AURA_ROW_WIDTH = 101
local NUM_TOT_AURA_ROWS = 2

local function isPlayerAura(source)
	return source and UnitIsUnit(source, "player")
end

local function getRowWidth(row)
	local totShown = TargetFrameToT and TargetFrameToT:IsShown()
	if totShown and row <= NUM_TOT_AURA_ROWS then
		return TOT_AURA_ROW_WIDTH
	end
	return AURA_ROW_WIDTH
end

local function layoutFrames(list, offsetY, sizeFunc)
	local rowX, rowHeight, row = 0, 0, 1
	for _, btn in ipairs(list) do
		local size = sizeFunc(btn)
		btn:SetSize(size, size)
		btn:ClearAllPoints()
		if rowX + size > getRowWidth(row) then
			offsetY = offsetY - rowHeight - AURA_OFFSET_Y
			rowX, rowHeight = 0, 0
			row = row + 1
		end
		btn:SetPoint("TOPLEFT", TargetFrame, "BOTTOMLEFT", AURA_START_X + rowX, offsetY)
		rowX = rowX + size + 2
		if size > rowHeight then rowHeight = size end
	end
	if rowX > 0 then offsetY = offsetY - rowHeight - AURA_OFFSET_Y end
	return offsetY
end

local TARGET_ASC = true

local function sortTargetBuffs()
	local dynamicSize = GetCVarBool("showDynamicBuffSize")
	local asc = TARGET_ASC
	local count = 0

	for i = 1, MAX_TARGET_BUFFS do
		local btn = _G["TargetFrameBuff" .. i]
		if not btn then break end
		if btn:IsShown() then
			local _, _, _, _, duration, expirationTime, source = UnitBuff("target", btn:GetID())
			local timeLeft = (duration and duration > 0) and (expirationTime - GetTime()) or math.huge
			local isLarge = not dynamicSize or isPlayerAura(source)
			btn._sortKey = (isLarge == asc and 0 or 100000) + timeLeft
			count = count + 1
			targetSorted[count] = btn
		end
	end
	for i = count + 1, #targetSorted do targetSorted[i] = nil end

	table.sort(targetSorted, asc and compareAsc or compareDesc)

	local buffSize = function(btn) return btn._sortKey < 100000 and LARGE or SMALL end
	local debuffSize = function(btn) return btn:GetHeight() end

	-- Layout sorted buffs, then debuffs below
	local offsetY = layoutFrames(targetSorted, AURA_START_Y, buffSize)

	local debuffs = {}
	for i = 1, MAX_TARGET_DEBUFFS do
		local btn = _G["TargetFrameDebuff" .. i]
		if not btn then break end
		if btn:IsShown() then debuffs[#debuffs + 1] = btn end
	end
	layoutFrames(debuffs, offsetY, debuffSize)
end

function cfFrames.initBuffSorting()
	hooksecurefunc("BuffFrame_Update", sortPlayerBuffs)
	hooksecurefunc("TargetFrame_UpdateAuras", sortTargetBuffs)
end
