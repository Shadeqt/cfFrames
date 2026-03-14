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

local function SetupBar(bar)
	local parent = TargetFrameTextureFrame
	local anchors = BarAnchors[bar]

	bar.TextString = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	bar.TextString:SetPoint("CENTER", parent, "CENTER", anchors.center, anchors.y)

	bar.LeftText = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	bar.LeftText:SetPoint("LEFT", parent, "LEFT", anchors.left, anchors.y)

	bar.RightText = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	bar.RightText:SetPoint("RIGHT", parent, "RIGHT", anchors.right, anchors.y)
end

local function OnStatusBarTextUpdate(bar)
	if bar ~= TargetFrameHealthBar then return end
	if not bar.showPercentage then return end
	if not IsHealthKnown("target") then return end
	bar.showPercentage = false
	TextStatusBar_UpdateTextString(bar)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, addonName)
	if addonName ~= "cfFrames" then return end
	self:UnregisterEvent("ADDON_LOADED")
	if not cfFramesDB[M.TARGET_FRAME_STATUS_TEXT] then return end

	for bar in pairs(BarAnchors) do
		SetupBar(bar)
	end

	hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", OnStatusBarTextUpdate)
end)
