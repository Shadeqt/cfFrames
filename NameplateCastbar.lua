local M = cff.MODULES
local V = cff.VALUES
local hooked = false

local function CreateCastbar(unitFrame, unit)
	local hp = unitFrame.healthBar
	local bar = cff.CreateCastbar(unitFrame, unit, hp:GetWidth(), hp:GetHeight())
	bar:SetPoint("TOP", hp, "BOTTOM", cfFramesDB[V.NameplateCastbarX], -5 + cfFramesDB[V.NameplateCastbarY])
	bar:SetScale(cfFramesDB[V.NameplateCastbarScale])

	bar.Icon:ClearAllPoints()
	bar.Icon:SetPoint("LEFT", bar, "RIGHT", 3 + cfFramesDB[V.NameplateCastbarIconX], cfFramesDB[V.NameplateCastbarIconY])
	bar.Icon:SetScale(cfFramesDB[V.NameplateCastbarIconScale])
	if not cfFramesDB[M.NameplateCastbarIcon] then bar.Icon:Hide() end
	print("Icon w:", bar.Icon:GetWidth(), "h:", bar.Icon:GetHeight(), "scale:", bar.Icon:GetScale(), "shown:", bar.Icon:IsShown(), "layer:", bar.Icon:GetDrawLayer())

	if cfFramesDB[M.DarkModeNameplates] then
		cff.SaveAndDarken(bar.Border)
	end

	cff.StyleNameplateCastbarIcon(bar)
	hooksecurefunc(bar, "Show", function(self)
		cff.StyleNameplateCastbarIcon(self)
		if not cfFramesDB[M.NameplateCastbarIcon] then self.Icon:Hide() end
	end)

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

-- TEST: show nameplate castbars permanently at full (remove later)
local testFrame = CreateFrame("Frame")
testFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
testFrame:SetScript("OnEvent", function(_, _, unit)
	local plate = C_NamePlate.GetNamePlateForUnit(unit)
	if not plate or not plate.UnitFrame then return end
	local testBar = GetCastbar(plate, unit)
	testBar:SetScript("OnUpdate", nil)
	testBar:SetMinMaxValues(0, 1)
	testBar:SetValue(1)
	testBar:SetStatusBarColor(1, 0.7, 0)
	testBar.Icon:SetTexture("Interface\\Icons\\Spell_Nature_Lightning")
	testBar.Icon:Show()
	testBar:Show()
end)
