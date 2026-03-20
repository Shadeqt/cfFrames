local M = cfFrames.MODULES

local originalPoint

local function SetBbfNamePoint()
	local bbfName = PetFrame.bbfName
	bbfName.cfAdjusting = true
	bbfName:ClearAllPoints()
	bbfName:SetPoint("CENTER", PetFrameHealthBar, "TOP", 0, 7)
	bbfName.cfAdjusting = false
end

local function Enable()
	if not cfFramesDB[M.BBF_INTEGRATION] then return end
	if not cfFramesDB[M.PET_NAME] then return end
	local bbfName = PetFrame.bbfName
	if not bbfName then return end

	if not originalPoint then
		originalPoint = { bbfName:GetPoint() }
		hooksecurefunc(bbfName, "SetPoint", function(self)
			if self.cfAdjusting then return end
			if not cfFramesDB[M.BBF_INTEGRATION] then return end
			if not cfFramesDB[M.PET_NAME] then return end
			SetBbfNamePoint()
		end)
	end
	SetBbfNamePoint()
end

local function Disable()
	local bbfName = PetFrame.bbfName
	if not bbfName or not originalPoint then return end
	bbfName.cfAdjusting = true
	bbfName:ClearAllPoints()
	bbfName:SetPoint(unpack(originalPoint))
	bbfName.cfAdjusting = false
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
	if arg1 ~= "cfFrames" and arg1 ~= "BetterBlizzFrames" then return end
	if not cfFramesDB or not BetterBlizzFramesDB then return end
	if not PetFrame.bbfName then return end

	self:UnregisterEvent("ADDON_LOADED")
	cfFrames:RegisterModule(M.BBF_INTEGRATION, Enable, Disable)
	cfFrames:RegisterModule(M.PET_NAME, Enable, Disable)
	if cfFramesDB[M.BBF_INTEGRATION] and cfFramesDB[M.PET_NAME] then
		Enable()
	end
end)
