local M = cfFrames.MODULES

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
	if arg1 ~= "cfFrames" and arg1 ~= "BetterBlizzFrames" then return end

	if not cfFramesDB or not cfFramesDB[M.BBF_INTEGRATION] then return end
	if not cfFramesDB[M.PET_NAME] then return end
	if not BetterBlizzFramesDB then return end
	if not PetFrame.bbfName then return end

	self:UnregisterEvent("ADDON_LOADED")

	PetFrame.bbfName:ClearAllPoints()
	PetFrame.bbfName:SetPoint("CENTER", PetFrameHealthBar, "TOP", 0, 7)

	-- Re-apply if BBF re-anchors it
	hooksecurefunc(PetFrame.bbfName, "SetPoint", function(s)
		if s.cfAdjusting then return end
		s.cfAdjusting = true
		s:ClearAllPoints()
		s:SetPoint("CENTER", PetFrameHealthBar, "TOP", 0, 7)
		s.cfAdjusting = false
	end)
end)
