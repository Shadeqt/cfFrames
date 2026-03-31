local _, class = UnitClass("player")
if class ~= "DRUID" then return end

local MANA = Enum.PowerType.Mana
local SHOW_FOR = { [Enum.PowerType.Rage] = true, [Enum.PowerType.Energy] = true }

local function CreateBar()
	local w, h = PlayerFrameManaBar:GetSize()
	local bar = CreateFrame("StatusBar", nil, PlayerFrame)
	bar:SetSize(w, h)
	bar:SetPoint("TOPLEFT", PlayerFrameManaBar, "BOTTOMLEFT", 1, 0)
	bar:SetFrameLevel(PlayerFrame:GetFrameLevel() - 1)
	bar:SetStatusBarTexture(cfFrames.getBarTexture())
	local c = PowerBarColor[MANA]
	bar:SetStatusBarColor(c.r, c.g, c.b)

	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(0, 0, 0, 0.5)
	return bar
end

local function CreateBorder(bar)
	local border = CreateFrame("Frame", nil, bar, "BackdropTemplate")
	border:SetPoint("TOPLEFT", bar, -2, 2)
	border:SetPoint("BOTTOMRIGHT", bar, 3, -2)
	border:SetBackdrop({ edgeFile = cfFramesDB.DruidBar, edgeSize = 8 })
	cfFrames.styleRegions(border)

	return border
end

local function SetupText(bar, border)
	local textFrame = CreateFrame("Frame", nil, bar)
	textFrame:SetAllPoints(bar)
	textFrame:SetFrameLevel(10)
	cfFrames.setupBarText(bar, textFrame)
	if bar.LeftText then
		bar.LeftText:SetPoint("LEFT", bar, "LEFT", 3, 0)
	end
	if bar.RightText then
		bar.RightText:SetPoint("RIGHT", bar, "RIGHT", -2, 0)
	end
end

local function OnEvent(self, event, _, powerType)
	if event == "UNIT_POWER_UPDATE" then
		if powerType ~= "MANA" then return end
		if not self:IsShown() then return end
		self:SetValue(UnitPower("player", MANA))
		if self.lockShow then TextStatusBar_UpdateTextString(self) end
	else
		self.lockShow = C_CVar.GetCVarBool("statusText")
		self:SetMinMaxValues(0, UnitPowerMax("player", MANA))
		self:SetValue(UnitPower("player", MANA))
		if self.lockShow then TextStatusBar_UpdateTextString(self) end
		local show = UnitPowerMax("player", MANA) > 0 and SHOW_FOR[UnitPowerType("player")]
		self:SetShown(show)
	end
end

local function SetupEvents(bar)
	bar:SetScript("OnEvent", OnEvent)
	bar:RegisterEvent("PLAYER_ENTERING_WORLD")
	bar:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
	bar:RegisterUnitEvent("UNIT_MAXPOWER", "player")
	bar:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
end

function cfFrames.initDruidBar()
	local bar = CreateBar()
	local border = CreateBorder(bar)
	SetupText(bar, border)
	SetupEvents(bar)
end
