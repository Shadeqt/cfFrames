local RARE_ELITE_ICON = "Interface\\Tooltips\\RareEliteNameplateIcon"
local ELITE_ICON      = "Interface\\Tooltips\\EliteNameplateIcon"

local function UpdateClassification(nameplate, unit)
	if not nameplate.cfClassIcon then
		local icon = nameplate.UnitFrame:CreateTexture(nil, "OVERLAY")
		icon:SetSize(64, 32)
		icon:SetPoint("LEFT", nameplate.UnitFrame.healthBar, "RIGHT", -5, -2.5)
		nameplate.cfClassIcon = icon
	end

	local classification = UnitClassification(unit)
	local isElite = classification == "worldboss" or classification == "elite" or classification == "rareelite"
	local isRare = classification == "rare" or classification == "rareelite"

	if isElite then
		nameplate.cfClassIcon:SetTexture(isRare and RARE_ELITE_ICON or ELITE_ICON)
		nameplate.cfClassIcon:Show()
	else
		nameplate.cfClassIcon:Hide()
	end

	local border = nameplate.UnitFrame.healthBar.border
	if border then
		for _, region in next, { border:GetRegions() } do
			if region.SetDesaturated then
				region:SetDesaturated(isRare)
			end
		end
	end
end

local function SetupEvents()
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	frame:SetScript("OnEvent", function(_, event, unit)
		local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
		if not nameplate then return end

		if event == "NAME_PLATE_UNIT_ADDED" then
			UpdateClassification(nameplate, unit)
		elseif event == "NAME_PLATE_UNIT_REMOVED" then
			if nameplate.cfClassIcon then
				nameplate.cfClassIcon:Hide()
			end
		end
	end)
end

function cfFrames.initNameplateClassification()
	SetupEvents()
end
