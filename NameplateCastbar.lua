local M = cfFrames.MODULES

local function GetCastBar(nameplate, unit)
	if nameplate.cfCastBar then return nameplate.cfCastBar end

	local unitFrame = nameplate.UnitFrame
	local bar = CreateFrame("StatusBar", nil, UIParent, "SmallCastingBarFrameTemplate")
	bar:Hide()

	-- Clear template points before OnLoad to avoid taint from GetPoint() on restricted regions
	bar.Border:ClearAllPoints()
	bar.Spark:ClearAllPoints()
	bar.Icon:ClearAllPoints()
	bar.Flash:ClearAllPoints()
	bar.Text:ClearAllPoints()
	if bar.BorderShield then bar.BorderShield:ClearAllPoints() end

	CastingBarFrame_OnLoad(bar, unit)

	-- Reparent to nameplate after OnLoad
	bar:SetParent(unitFrame)

	local healthBar = unitFrame.healthBar
	bar:SetPoint("TOP", healthBar, "BOTTOM", 0, -5)
	bar:SetSize(healthBar:GetWidth(), healthBar:GetHeight())

	hooksecurefunc(bar.Flash, "Show", function(self) self:Hide() end)

	bar.Border:SetPoint("TOPLEFT", -18, 16)
	bar.Border:SetPoint("BOTTOMRIGHT", 16.5, -17)

	bar.Spark:SetSize(16, 16)

	bar.Icon:SetPoint("LEFT", bar, "RIGHT", 8, 0)
	bar.Icon:SetSize(14, 14)

	bar.Text:SetPoint("CENTER")

	nameplate.cfCastBar = bar
	return bar
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(_, event, unit)
	if not cfFramesDB[M.NAMEPLATE_CASTBAR] then return end
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	if not nameplate then return end

	if event == "NAME_PLATE_UNIT_ADDED" then
		local bar = GetCastBar(nameplate, unit)
		bar.unit = unit
		CastingBarFrame_SetUnit(bar, unit)
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
