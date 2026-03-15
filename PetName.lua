local M = cfFrames.MODULES

local originalPoint

local function SetPetNamePoint()
	PetName.cfAdjusting = true
	PetName:ClearAllPoints()
	PetName:SetPoint("CENTER", PetFrameHealthBar, "TOP", 0, 7)
	PetName.cfAdjusting = false
end

local function Enable()
	if not originalPoint then
		originalPoint = { PetName:GetPoint() }
		hooksecurefunc(PetName, "SetPoint", function(self)
			if self.cfAdjusting then return end
			if not cfFramesDB[M.PET_NAME] then return end
			SetPetNamePoint()
		end)
	end
	SetPetNamePoint()
end

local function Disable()
	if originalPoint then
		PetName.cfAdjusting = true
		PetName:ClearAllPoints()
		PetName:SetPoint(unpack(originalPoint))
		PetName.cfAdjusting = false
	end
end

cfFrames:RegisterModule(M.PET_NAME, Enable, Disable)
