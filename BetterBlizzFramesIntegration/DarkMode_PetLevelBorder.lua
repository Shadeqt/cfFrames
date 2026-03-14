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

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
	if arg1 ~= "cfFrames" and arg1 ~= "BetterBlizzFrames" then return end

	if not cfFramesDB or not cfFramesDB[M.BBF_INTEGRATION] then return end
	if not cfFramesDB[M.PET_LEVEL] then return end
	if not BetterBlizzFramesDB then return end

	self:UnregisterEvent("ADDON_LOADED")
	ApplyPetLevelDarkMode()

	-- Re-apply whenever BBF changes MinimapBorder colors (dark mode toggle)
	if MinimapBorder then
		hooksecurefunc(MinimapBorder, "SetVertexColor", function()
			ApplyPetLevelDarkMode()
		end)
	end
end)
