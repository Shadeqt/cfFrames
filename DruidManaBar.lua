local M = cfFrames.MODULES

local _, class = UnitClass("player")
if class ~= "DRUID" then return end

local POWER_INDEX = 0 -- Mana
local SHOW_FOR = { [Enum.PowerType.Rage] = true, [Enum.PowerType.Energy] = true }

local bar, border

local function UpdateVisibility()
	local show = UnitPowerMax("player", POWER_INDEX) > 0 and SHOW_FOR[UnitPowerType("player")]
	bar:SetShown(show)
end

local function UpdateValue()
	if not bar:IsShown() then return end
	bar:SetValue(UnitPower("player", POWER_INDEX))
	TextStatusBar_UpdateTextString(bar)
end

local function UpdateMaxValue()
	bar:SetMinMaxValues(0, UnitPowerMax("player", POWER_INDEX))
end

local function OnEvent(self, event)
	if event == "UNIT_DISPLAYPOWER" or event == "PLAYER_ENTERING_WORLD" then
		UpdateMaxValue()
		UpdateVisibility()
	end
	if event == "UNIT_MAXPOWER" then
		UpdateMaxValue()
	end
	if event == "UNIT_POWER_UPDATE" then
		UpdateValue()
	end
end

local function CreateBar()
	if bar then return end

	bar = CreateFrame("StatusBar", nil, PlayerFrame)
	bar:SetStatusBarTexture(PlayerFrameHealthBar:GetStatusBarTexture():GetTexture())
	bar:SetStatusBarColor(0, 0, 1)
	bar:SetSize(PlayerFrameManaBar:GetWidth(), PlayerFrameManaBar:GetHeight())
	bar:SetPoint("TOP", PlayerFrameManaBar, "BOTTOM", 0, -3)

	bar.bg = bar:CreateTexture(nil, "BACKGROUND")
	bar.bg:SetAllPoints()
	bar.bg:SetColorTexture(0, 0, 0, 0.5)

	border = CreateFrame("Frame", nil, bar, "BackdropTemplate")
	border:SetPoint("TOPLEFT", -3, 3)
	border:SetPoint("BOTTOMRIGHT", 3, -3)
	border:SetBackdrop({ edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border", edgeSize = 8 })
	border:SetBackdropBorderColor(0.6, 0.6, 0.6)

	bar.TextString = bar:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	bar.TextString:SetPoint("CENTER", bar, "CENTER", 0, 0)
	bar.LeftText = bar:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	bar.LeftText:SetPoint("LEFT", bar, "LEFT", 2, 0)
	bar.RightText = bar:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	bar.RightText:SetPoint("RIGHT", bar, "RIGHT", -2, 0)

	bar.unit = "player"
	bar.textLockable = 1
	bar.cvar = "statusText"
	bar.cvarLabel = "STATUS_TEXT_PLAYER"
	bar.capNumericDisplay = true
	TextStatusBar_Initialize(bar)

	bar:SetScript("OnEvent", OnEvent)
	bar:SetScript("OnUpdate", UpdateValue)
	bar:RegisterEvent("PLAYER_ENTERING_WORLD")
	bar:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
	bar:RegisterUnitEvent("UNIT_MAXPOWER", "player")
	bar:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")

	bar:Hide()
end

local function UpdateTextVisibility()
	if not bar then return end
	local cvarValue = GetCVar("statusText")
	bar.lockShow = cvarValue == "0" and 0 or 1
	TextStatusBar_UpdateTextString(bar)
end

local hookedSetCVar = false

local function Enable()
	CreateBar()
	UpdateMaxValue()
	UpdateValue()
	UpdateTextVisibility()
	UpdateVisibility()

	if not hookedSetCVar then
		hooksecurefunc("SetCVar", function(cvar)
			if not cfFramesDB[M.DRUID_MANA_BAR] then return end
			if cvar == "statusText" then
				UpdateTextVisibility()
			end
		end)
		hookedSetCVar = true
	end
end

local function Disable()
	if bar then
		bar:UnregisterAllEvents()
		bar:Hide()
	end
end

cfFrames:RegisterModule(M.DRUID_MANA_BAR, Enable, Disable)
