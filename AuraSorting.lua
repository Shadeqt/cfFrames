-- Sorts player buff bar: permanent auras first, then by time remaining (most time first)

local sorted = {}

local function compare(a, b)
	if a._sortKey ~= b._sortKey then return a._sortKey > b._sortKey end
	return a:GetID() < b:GetID()
end

local function sortBuffs()
	for i = 1, BUFF_ACTUAL_DISPLAY do
		local button = _G["BuffButton" .. i]
		sorted[i] = button
		button._sortKey = button.timeLeft or math.huge
	end
	for i = BUFF_ACTUAL_DISPLAY + 1, #sorted do sorted[i] = nil end

	table.sort(sorted, compare)

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

function cfFrames.initAuraSorting()
	hooksecurefunc("BuffFrame_Update", sortBuffs)
end
