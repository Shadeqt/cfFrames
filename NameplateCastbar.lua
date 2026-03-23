local M = cfFrames.MODULES

local function GetCastBar(nameplate, unit)
	if nameplate.cfCastBar then return nameplate.cfCastBar end

	local unitFrame = nameplate.UnitFrame
	local bar = CreateFrame("StatusBar", nil, unitFrame, "SmallCastingBarFrameTemplate")
	bar:Hide()
	CastingBarFrame_OnLoad(bar, unit)

	local healthBar = unitFrame.healthBar
	local hpTex = healthBar:GetStatusBarTexture()
	if hpTex then
		local layer, sublevel = bar:GetStatusBarTexture():GetDrawLayer()
		bar:SetStatusBarTexture(hpTex:GetTexture())
		bar:GetStatusBarTexture():SetDrawLayer(layer, sublevel or 0)
	end
	bar:ClearAllPoints()
	bar:SetPoint("TOP", healthBar, "BOTTOM", -0.5, -5)
	bar:SetSize(healthBar:GetWidth(), healthBar:GetHeight()-2)

	bar.Border:ClearAllPoints()
	local bw = healthBar:GetWidth() * 1.16
	local bh = healthBar:GetHeight() * 1.3
	bar.Border:SetPoint("TOPLEFT", bw, bh)
	bar.Border:SetPoint("BOTTOMRIGHT", -bw, -bh)

	bar.Flash:ClearAllPoints()
	bar.Flash:SetPoint("TOPLEFT", bw, bh)
	bar.Flash:SetPoint("BOTTOMRIGHT", -bw, -bh)

	bar.Spark:ClearAllPoints()
	bar.Spark:SetSize(16, 16)

	bar.Icon:ClearAllPoints()
	bar.Icon:SetPoint("LEFT", bar, "RIGHT", 3, 0)
	bar.Icon:SetSize(14, 14)

	bar.Text:ClearAllPoints()
	bar.Text:SetPoint("CENTER")

	if cfFramesDB[M.DARK_MODE] then
		local c = cfFrames.DARK_COLOR
		bar.Border:SetVertexColor(c, c, c)
		cfFrames.CreateDarkIconBorder(bar, bar.Icon)
	end

	-- Fix inaccurate cast progress values in Classic Era
	bar:HookScript("OnEvent", function(self, event)
		if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
			CastingBarFrame_OnEvent(self, "PLAYER_ENTERING_WORLD")
		end
	end)

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
		CastingBarFrame_SetUnit(bar, unit)
		-- Pick up in-progress cast
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

local function Enable()
	frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
end

local function Disable()
	frame:UnregisterAllEvents()
end

cfFrames:RegisterModule(M.NAMEPLATE_CASTBAR, Enable, Disable)

local testMode = false
local testFrame = CreateFrame("Frame")
testFrame:SetScript("OnEvent", function(_, _, unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	if not nameplate then return end
	local bar = GetCastBar(nameplate, unit)
	bar:SetMinMaxValues(0, 3)
	bar:SetStatusBarColor(1, 0.7, 0)
	bar.Icon:SetTexture(133014)
	bar.Text:SetText("Test Cast")
	bar:Show()
	local start = GetTime()
	bar:SetScript("OnUpdate", function(self)
		local progress = (GetTime() - start) % 3
		self:SetValue(progress)
		self.Spark:ClearAllPoints()
		self.Spark:SetPoint("CENTER", self, "LEFT", (progress / 3) * self:GetWidth(), 0)
		self.Spark:Show()
	end)
end)

SLASH_CFCTEST1 = "/cfctest"
SlashCmdList["CFCTEST"] = function()
	testMode = not testMode
	if testMode then
		testFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
		for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
			local unit = nameplate.namePlateUnitToken
			if unit then
				testFrame:GetScript("OnEvent")(testFrame, "NAME_PLATE_UNIT_ADDED", unit)
			end
		end
		print("cfFrames: castbar test ON")
	else
		testFrame:UnregisterAllEvents()
		for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
			if nameplate.cfCastBar then
				nameplate.cfCastBar:SetScript("OnUpdate", nil)
				nameplate.cfCastBar:Hide()
			end
		end
		print("cfFrames: castbar test OFF")
	end
end
