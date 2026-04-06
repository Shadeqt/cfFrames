local M = cff.MODULES
local hooked = false

local function CreateCastbar(unitFrame, unit)
	local hp = unitFrame.healthBar
	local bar = CreateFrame("StatusBar", nil, unitFrame, "SmallCastingBarFrameTemplate")
	bar:Hide()
	CastingBarFrame_OnLoad(bar, unit)
	if cfFramesDB[M.StatusBar] then bar:SetStatusBarTexture(cff.GetStatusBarTexture()) end
	bar:ClearAllPoints()
	bar:SetPoint("TOP", hp, "BOTTOM", 0, -5)
	bar:SetSize(hp:GetWidth(), hp:GetHeight())

	bar.Border:ClearAllPoints()
	bar.Border:SetPoint("TOPLEFT", bar, -17.5, 16)
	bar.Border:SetPoint("BOTTOMRIGHT", bar, 17.5, -15.5)
	bar.Flash:ClearAllPoints()
	bar.Flash:SetPoint("TOPLEFT", bar, -17.5, 16)
	bar.Flash:SetPoint("BOTTOMRIGHT", bar, 17.5, -15.5)
	bar.Icon:ClearAllPoints()
	bar.Icon:SetPoint("LEFT", bar, "RIGHT", 3, 0)
	bar.Icon:SetSize(15.5, 15.5)
	if bar.Text then bar.Text:ClearAllPoints(); bar.Text:SetPoint("CENTER") end

	bar:HookScript("OnEvent", function(self, event)
		if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
			CastingBarFrame_OnEvent(self, "PLAYER_ENTERING_WORLD")
		end
	end)

	if cfFramesDB[M.DarkModeNameplates] then
		cff.SaveAndDarken(bar.Border)
	end

	return bar
end

local function GetCastbar(plate, unit)
	if plate.cffCastBar then return plate.cffCastBar end
	plate.cffCastBar = CreateCastbar(plate.UnitFrame, unit)
	return plate.cffCastBar
end

cff.RegisterCallback(M.DarkMode, function()
	if not cfFramesDB[M.NameplateCastbar] then return end
	if not cfFramesDB[M.DarkModeNameplates] then return end
	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		if plate.cffCastBar then
			cff.SaveAndDarken(plate.cffCastBar.Border)
		end
	end
end)

cff.RegisterCallback(M.StatusBar, function()
	if not cfFramesDB[M.NameplateCastbar] then return end
	if not cfFramesDB[M.StatusBar] then return end
	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		if plate.cffCastBar then
			plate.cffCastBar:SetStatusBarTexture(cff.GetStatusBarTexture())
		end
	end
end)

function cff.EnableNameplateCastbar()
	if not cfFramesDB[M.NameplateCastbar] then return end
	if hooked then return end
	hooked = true

	local frame = CreateFrame("Frame")
	frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	frame:SetScript("OnEvent", function(_, event, unit)
		local plate = C_NamePlate.GetNamePlateForUnit(unit)
		if not plate then return end
		if event == "NAME_PLATE_UNIT_ADDED" then
			if not cfFramesDB[M.NameplateCastbar] then return end
			local bar = GetCastbar(plate, unit)
			CastingBarFrame_SetUnit(bar, unit)
			if UnitCastingInfo(unit) or UnitChannelInfo(unit) then
				CastingBarFrame_OnEvent(bar, "PLAYER_ENTERING_WORLD")
			end
		else
			if plate.cffCastBar then
				CastingBarFrame_SetUnit(plate.cffCastBar, nil)
				plate.cffCastBar:Hide()
			end
		end
	end)
end

function cff.DisableNameplateCastbar()
	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		if plate.cffCastBar then
			CastingBarFrame_SetUnit(plate.cffCastBar, nil)
			plate.cffCastBar:Hide()
		end
	end
end
