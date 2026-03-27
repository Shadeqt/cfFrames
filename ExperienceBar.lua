local M = cfFrames.MODULES
local STATUS_TEXT_CVAR = "statusText"

local function UpdateLockShow(bar, value)
	bar.lockShow = value == "0" and 0 or 1
	TextStatusBar_UpdateTextString(bar)
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function()
	local bar = MainMenuExpBar
	if not bar then return end
	local cvarStatusText = GetCVar(STATUS_TEXT_CVAR)
	UpdateLockShow(bar, cvarStatusText)
end)

local hookedSetCVar = false

local function Enable()
	local bar = MainMenuExpBar
	if not bar then return end

	local cvarStatusText = GetCVar(STATUS_TEXT_CVAR)
	UpdateLockShow(bar, cvarStatusText)

	frame:RegisterEvent("PLAYER_ENTERING_WORLD")

	if not hookedSetCVar then
		hooksecurefunc("SetCVar", function(cvar, value)
			if not cfFramesDB[M.EXPERIENCE_BAR] then return end
			if cvar == STATUS_TEXT_CVAR then
				UpdateLockShow(bar, value)
			end
		end)
		hookedSetCVar = true
	end
end

local function Disable()
	frame:UnregisterAllEvents()
	local bar = MainMenuExpBar
	if not bar then return end
	bar.lockShow = 0
	TextStatusBar_UpdateTextString(bar)
end

cfFrames:RegisterModule(M.EXPERIENCE_BAR, Enable, Disable)
