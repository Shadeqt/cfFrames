local M = cfFrames.MODULES

local function GetBarAnchors()
	return {
		[TargetFrameHealthBar] = true,
		[TargetFrameManaBar]   = true,
	}
end

local function IsHealthKnown(unit)
	local unitGuid = UnitGUID(unit)
	local guidType = unitGuid and unitGuid:match("^(.-)%-")
	if guidType ~= "Player" and guidType ~= "Pet" then return true end
	if UnitIsUnit(unit, "player") or UnitIsUnit(unit, "pet") then return true end
	if UnitPlayerOrPetInRaid(unit) or UnitPlayerOrPetInParty(unit) then return true end
	return false
end

local setupDone = false

local function SetupBar(bar)
	local parent = TargetFrameTextureFrame

	if not bar.TextString then
		bar.TextString = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	end
	bar.TextString:ClearAllPoints()
	bar.TextString:SetPoint("CENTER", bar, "CENTER", 0, 0)

	if not bar.LeftText then
		bar.LeftText = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	end
	bar.LeftText:ClearAllPoints()
	bar.LeftText:SetPoint("LEFT", bar, "LEFT", 2, 0)

	if not bar.RightText then
		bar.RightText = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	end
	bar.RightText:ClearAllPoints()
	bar.RightText:SetPoint("RIGHT", bar, "RIGHT", -2, 0)
end

local function OnStatusBarTextUpdate(bar)
	if not cfFramesDB[M.TARGET_FRAME_STATUS_TEXT] then return end
	if bar ~= TargetFrameHealthBar then return end
	if not bar.showPercentage then return end
	if not IsHealthKnown("target") then return end
	bar.showPercentage = false
	TextStatusBar_UpdateTextString(bar)
end

local function Enable()
	local bars = GetBarAnchors()
	for bar in pairs(bars) do
		SetupBar(bar)
		bar.TextString:Show()
		bar.LeftText:Show()
		bar.RightText:Show()
	end
	if not setupDone then
		hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", OnStatusBarTextUpdate)
		setupDone = true
	end
	if UnitExists("target") and IsHealthKnown("target") then
		TargetFrameHealthBar.showPercentage = false
	end
	for bar in pairs(bars) do
		TextStatusBar_UpdateTextString(bar)
	end
end

local function Disable()
	for bar in pairs(GetBarAnchors()) do

		if bar.TextString then bar.TextString:SetText("") end
		if bar.LeftText then bar.LeftText:SetText("") end
		if bar.RightText then bar.RightText:SetText("") end
	end
end

cfFrames:RegisterModule(M.TARGET_FRAME_STATUS_TEXT, Enable, Disable)
