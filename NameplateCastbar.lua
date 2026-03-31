local function CreateCastbar(unitFrame, unit)
	local healthBar = unitFrame.healthBar
	local bar = CreateFrame("StatusBar", nil, unitFrame, "SmallCastingBarFrameTemplate")
	bar:Hide()
	CastingBarFrame_OnLoad(bar, unit)
	bar:SetStatusBarTexture(cfFrames.getBarTexture())
	bar:ClearAllPoints()
	bar:SetPoint("TOP", healthBar, "BOTTOM", 18, -5)
	bar:SetSize(healthBar:GetWidth(), healthBar:GetHeight())
	return bar
end

local function StyleCastbar(bar)
	bar.Border:ClearAllPoints()
	bar.Border:SetPoint("TOPLEFT", bar, -17, 16)
	bar.Border:SetPoint("BOTTOMRIGHT", bar, 17, -16)
	bar.Flash:ClearAllPoints()
	bar.Flash:SetPoint("TOPLEFT", bar, -17, 16)
	bar.Flash:SetPoint("BOTTOMRIGHT", bar, 17, -16)
	bar.Icon:ClearAllPoints()
	bar.Icon:SetPoint("RIGHT", bar, "LEFT", -5, 0)
	bar.Icon:SetSize(14, 14)
	if bar.Text then
		bar.Text:ClearAllPoints()
		bar.Text:SetPoint("CENTER", bar, "CENTER", 0, 0)
	end
	cfFrames.styleTexture(bar.Border)
	cfFrames.styleIcon(bar.Icon)
end

local function HookCastbar(bar)
	bar:HookScript("OnEvent", function(self, event)
		if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
			CastingBarFrame_OnEvent(self, "PLAYER_ENTERING_WORLD")
		end
	end)
end

local function GetCastbar(nameplate, unit)
	if nameplate.cfCastBar then return nameplate.cfCastBar end
	local bar = CreateCastbar(nameplate.UnitFrame, unit)
	StyleCastbar(bar)
	HookCastbar(bar)
	nameplate.cfCastBar = bar
	return bar
end

local function SetupEvents()
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	frame:SetScript("OnEvent", function(_, event, unit)
		local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
		if not nameplate then return end

		if event == "NAME_PLATE_UNIT_ADDED" then
			local bar = GetCastbar(nameplate, unit)
			CastingBarFrame_SetUnit(bar, unit)
			if UnitCastingInfo(unit) or UnitChannelInfo(unit) then
				CastingBarFrame_OnEvent(bar, "PLAYER_ENTERING_WORLD")
			end
		elseif event == "NAME_PLATE_UNIT_REMOVED" then
			if nameplate.cfCastBar then
				CastingBarFrame_SetUnit(nameplate.cfCastBar, nil)
				nameplate.cfCastBar:Hide()
			end
		end
	end)
end

function cfFrames.initNameplateCastbar()
	SetupEvents()
end
