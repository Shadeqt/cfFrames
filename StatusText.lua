local bars = {}

local function UpdateLockShow(bar)
	bar.lockShow = C_CVar.GetCVarBool("statusText") and 1 or 0
	TextStatusBar_UpdateTextString(bar)
end

local function SetupExpBar()
	if not MainMenuExpBar then return end
	table.insert(bars, MainMenuExpBar)
	UpdateLockShow(MainMenuExpBar)
end

local function CreateBarText(bar, parent)
	parent = parent or bar
	bar.TextString = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	bar.TextString:SetPoint("CENTER", bar)
	bar.LeftText = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	bar.LeftText:SetPoint("LEFT", bar)
	bar.RightText = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	bar.RightText:SetPoint("RIGHT", bar)
	table.insert(bars, bar)
	UpdateLockShow(bar)
end

local function IsHealthKnown(unit)
	local guid = UnitGUID(unit)
	local guidType = guid and guid:match("^(.-)%-")
	if guidType ~= "Player" and guidType ~= "Pet" then return true end
	if UnitIsUnit(unit, "player") or UnitIsUnit(unit, "pet") then return true end
	if UnitInAnyGroup(unit) then return true end
	return false
end

local function SetupTargetBars()
	if not TargetFrameHealthBar then return end
	CreateBarText(TargetFrameHealthBar, TargetFrameTextureFrame)
	CreateBarText(TargetFrameManaBar, TargetFrameTextureFrame)
	TargetFrameHealthBar.RightText:SetPoint("RIGHT", TargetFrameHealthBar, "RIGHT", -4, 0)
	TargetFrameManaBar.RightText:SetPoint("RIGHT", TargetFrameManaBar, "RIGHT", -4, 0)
end

local function HookHealthKnown()
	hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", function(bar)
		if bar ~= TargetFrameHealthBar then return end
		if not bar.showPercentage then return end
		if not IsHealthKnown("target") then return end
		bar.showPercentage = false
		TextStatusBar_UpdateTextString(bar)
	end)
end

local function HookCVarUpdate()
	Settings.SetOnValueChangedCallback("PROXY_STATUS_TEXT", function()
		for _, bar in ipairs(bars) do
			UpdateLockShow(bar)
		end
	end)
end

function cfFrames.initStatusText()
	SetupExpBar()
	SetupTargetBars()
	HookHealthKnown()
	HookCVarUpdate()

	-- Register so other features can add bar text without importing StatusText
	cfFrames.registerBarTextSetup(CreateBarText)
end
