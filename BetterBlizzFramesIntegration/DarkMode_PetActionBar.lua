local M = cfFrames.MODULES

local function ApplyPetActionBarDarkMode()
	local bbfDB = BetterBlizzFramesDB
	if not bbfDB then return end

	local enabled = bbfDB.darkModeUi and bbfDB.darkModeActionBars
	local c = enabled and (bbfDB.darkModeColor + 0.15) or 1
	local sat = enabled and true or false

	for i = 1, 10 do
		local tex = _G["PetActionButton" .. i .. "NormalTexture2"]
		if tex then
			if tex.SetDesaturated then tex:SetDesaturated(sat) end
			if tex.SetVertexColor then tex:SetVertexColor(c, c, c) end
		end
	end
end

local function Enable()
	ApplyPetActionBarDarkMode()
	if MinimapBorder then
		hooksecurefunc(MinimapBorder, "SetVertexColor", function()
			if not cfFramesDB[M.BBF_INTEGRATION] then return end
			ApplyPetActionBarDarkMode()
		end)
	end
end

local function Disable()
	for i = 1, 10 do
		local tex = _G["PetActionButton" .. i .. "NormalTexture2"]
		if tex then
			tex:SetDesaturated(false)
			tex:SetVertexColor(1, 1, 1)
		end
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
