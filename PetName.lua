local function SetPetNamePoint()
	PetName.cfAdjusting = true
	PetName:ClearAllPoints()
	PetName:SetPoint("CENTER", PetFrameHealthBar, "TOP", 0, 7)
	PetName.cfAdjusting = false
end

local function HookSetPoint()
	hooksecurefunc(PetName, "SetPoint", function(self)
		if self.cfAdjusting then return end
		SetPetNamePoint()
	end)
end

function cfFrames.initPetName()
	HookSetPoint()
	SetPetNamePoint()
end
