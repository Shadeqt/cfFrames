local M = cfFrames.MODULES

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
	if arg1 ~= "cfFrames" then return end
	self:UnregisterEvent("ADDON_LOADED")
	if not cfFramesDB[M.PET_NAME] then return end

	PetName:ClearAllPoints()
	PetName:SetPoint("CENTER", PetFrameHealthBar, "TOP", 0, 7)
end)
