local M = cff.MODULES
local hooked = false

local RARE_ELITE_ICON = "Interface\\Tooltips\\RareEliteNameplateIcon"
local ELITE_ICON      = "Interface\\Tooltips\\EliteNameplateIcon"

local function UpdateClassification(nameplate, unit)
	if not nameplate.cfClassIcon then
		local holder = CreateFrame("Frame", nil, nameplate.UnitFrame.healthBar)
		local icon = holder:CreateTexture(nil, "OVERLAY", nil, 7)
		icon:SetSize(64, 32)
		icon:SetPoint("LEFT", nameplate.UnitFrame.healthBar, "RIGHT", -6, -3)
		nameplate.cfClassIcon = icon
	end

	local c = UnitClassification(unit)
	local isElite = c == "worldboss" or c == "elite" or c == "rareelite"
	local isRare = c == "rare" or c == "rareelite"

	if isElite or isRare then
		nameplate.cfClassIcon:SetTexture(isRare and RARE_ELITE_ICON or ELITE_ICON)
		nameplate.cfClassIcon:Show()
	else
		nameplate.cfClassIcon:Hide()
	end
end

local function HideClassification(nameplate)
	if nameplate.cfClassIcon then
		nameplate.cfClassIcon:Hide()
	end
end

function cff.EnableNameplateClassification()
	if not cfFramesDB[M.NameplateClassification] then return end

	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		local unit = plate.namePlateUnitToken
		if unit then UpdateClassification(plate, unit) end
	end

	if hooked then return end
	hooked = true

	local frame = CreateFrame("Frame")
	frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	frame:SetScript("OnEvent", function(_, event, unit)
		if not cfFramesDB[M.NameplateClassification] then return end
		local plate = C_NamePlate.GetNamePlateForUnit(unit)
		if not plate then return end
		if event == "NAME_PLATE_UNIT_ADDED" then
			UpdateClassification(plate, unit)
		else
			HideClassification(plate)
		end
	end)
end

function cff.DisableNameplateClassification()
	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		HideClassification(plate)
	end
end
