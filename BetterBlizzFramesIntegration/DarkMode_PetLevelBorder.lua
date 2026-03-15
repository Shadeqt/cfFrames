local M = cfFrames.MODULES

local function ApplyPetLevelDarkMode()
	local border = cfFrames.petLevelBorder
	if not border then return end

	local bbfDB = BetterBlizzFramesDB
	if not bbfDB or not bbfDB.darkModeUi or not bbfDB.darkModeMinimap then
		border:SetDesaturated(false)
		border:SetVertexColor(1, 1, 1)
		return
	end

	local c = bbfDB.darkModeColor or 1
	border:SetDesaturated(true)
	border:SetVertexColor(c, c, c)
end

local function Enable()
	ApplyPetLevelDarkMode()
	if MinimapBorder then
		hooksecurefunc(MinimapBorder, "SetVertexColor", function()
			if not cfFramesDB[M.BBF_INTEGRATION] then return end
			ApplyPetLevelDarkMode()
		end)
	end
end

local function Disable()
	local border = cfFrames.petLevelBorder
	if border then
		border:SetDesaturated(false)
		border:SetVertexColor(1, 1, 1)
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
	if arg1 ~= "cfFrames" and arg1 ~= "BetterBlizzFrames" then return end
	if not cfFramesDB or not BetterBlizzFramesDB then return end

	self:UnregisterEvent("ADDON_LOADED")
	cfFrames:RegisterModule(M.BBF_INTEGRATION, Enable, Disable)
	if cfFramesDB[M.BBF_INTEGRATION] then
		Enable()
	end
end)
