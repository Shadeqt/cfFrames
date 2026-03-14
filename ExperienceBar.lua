local M = cfFrames.MODULES
local STATUS_TEXT_CVAR = "statusText"

local function UpdateLockShow(bar, value)
	bar.lockShow = value == "0" and 0 or 1
	TextStatusBar_UpdateTextString(bar)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
	if arg1 ~= "cfFrames" then return end
	self:UnregisterEvent("ADDON_LOADED")
	if not cfFramesDB[M.EXPERIENCE_BAR] then return end

	local bar = MainMenuExpBar
	if not bar then return end

	local cvarStatusText = GetCVar(STATUS_TEXT_CVAR)
	UpdateLockShow(bar, cvarStatusText)

	hooksecurefunc("SetCVar", function(cvar, value)
		if cvar == STATUS_TEXT_CVAR then
			UpdateLockShow(bar, value)
		end
	end)
end)
