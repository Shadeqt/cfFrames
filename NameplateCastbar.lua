local M = cfFrames.MODULES

local function GetCastBar(nameplate, unit)
	if nameplate.cfCastBar then return nameplate.cfCastBar end

	local bar = CreateFrame("StatusBar", nil, nameplate, "SmallCastingBarFrameTemplate")
	local healthBar = nameplate.UnitFrame.healthBar
	bar:SetPoint("TOP", healthBar, "BOTTOM", 0, -5)
	bar:SetSize(healthBar:GetWidth(), healthBar:GetHeight())

	bar.Flash:ClearAllPoints()
	bar.Flash:SetPoint("TOPLEFT", -18, 16)
	bar.Flash:SetPoint("BOTTOMRIGHT", 16.5, -17)

	bar.Border:ClearAllPoints()
	bar.Border:SetPoint("TOPLEFT", -18, 16)
	bar.Border:SetPoint("BOTTOMRIGHT", 16.5, -17)

	bar.Icon:ClearAllPoints()
	bar.Icon:SetPoint("LEFT", bar, "RIGHT", 8, 0)
	bar.Icon:SetSize(14, 14)

	CastingBarFrame_OnLoad(bar, unit)
	CastingBarFrame_SetUnit(bar, unit)

	nameplate.cfCastBar = bar
	return bar
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
frame:SetScript("OnEvent", function(_, event, unit)
	if not cfFramesDB[M.NAMEPLATE_CASTBAR] then return end
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	if not nameplate then return end

	if event == "NAME_PLATE_UNIT_ADDED" then
		GetCastBar(nameplate, unit)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		if nameplate.cfCastBar then
			CastingBarFrame_SetUnit(nameplate.cfCastBar, nil)
			nameplate.cfCastBar:Hide()
		end
	end
end)

local function Enable()
	frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
end

local function Disable()
	frame:UnregisterAllEvents()
end

cfFrames:RegisterModule(M.NAMEPLATE_CASTBAR, Enable, Disable)
