function cff.InitPetActionBarCheckedFix()
	if not cfFramesDB[cff.MODULES.PetActionBarCheckedFix] then return end

	for i = 1, NUM_PET_ACTION_SLOTS do
		local btn = _G["PetActionButton" .. i]
		if not btn then break end
		local checked = btn:GetCheckedTexture()
		local icon = btn.icon
		if checked and icon then
			checked:ClearAllPoints()
			checked:SetPoint("CENTER", btn, "CENTER", -0.5, -0.5)
			checked:SetSize(icon:GetSize())
		end
	end
end
