local M = cfFrames.MODULES

local BarAnchors = {
	[TargetFrameHealthBar] = { center = -50, left = 8, right = -110, y = 3 },
	[TargetFrameManaBar]   = { center = -50, left = 8, right = -110, y = -8 },
}

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
	local anchors = BarAnchors[bar]

	if not bar.TextString then
		bar.TextString = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
		bar.TextString:SetPoint("CENTER", parent, "CENTER", anchors.center, anchors.y)
	end

	if not bar.LeftText then
		bar.LeftText = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
		bar.LeftText:SetPoint("LEFT", parent, "LEFT", anchors.left, anchors.y)
	end

	if not bar.RightText then
		bar.RightText = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
		bar.RightText:SetPoint("RIGHT", parent, "RIGHT", anchors.right, anchors.y)
	end
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
	for bar in pairs(BarAnchors) do
		SetupBar(bar)
		bar.TextString:Show()
		bar.LeftText:Show()
		bar.RightText:Show()
		TextStatusBar_UpdateTextString(bar)
	end
	if not setupDone then
		hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", OnStatusBarTextUpdate)
		setupDone = true
	end
end

local function Disable()
	for bar in pairs(BarAnchors) do
		if bar.TextString then bar.TextString:SetText("") end
		if bar.LeftText then bar.LeftText:SetText("") end
		if bar.RightText then bar.RightText:SetText("") end
	end
end

cfFrames:RegisterModule(M.TARGET_FRAME_STATUS_TEXT, Enable, Disable)
