local M = cff.MODULES
local V = cff.VALUES

function cff.ApplyNameplateScale()
	SetCVar("nameplateGlobalScale", cfFramesDB[V.NameplateScale])
end


function cff.ApplyNameplateCastbar()
	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		if plate.cffCastBar then
			local bar = plate.cffCastBar
			local hp = plate.UnitFrame.healthBar
			bar:ClearAllPoints()
			bar:SetPoint("TOP", hp, "BOTTOM", cfFramesDB[V.NameplateCastbarX], -5 + cfFramesDB[V.NameplateCastbarY])
			bar:SetScale(cfFramesDB[V.NameplateCastbarScale])
		end
	end
end

function cff.ApplyNameplateCastbarIcon()
	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		if plate.cffCastBar then
			local icon = plate.cffCastBar.Icon
			icon:ClearAllPoints()
			icon:SetPoint("LEFT", plate.cffCastBar, "RIGHT", 3 + cfFramesDB[V.NameplateCastbarIconX], cfFramesDB[V.NameplateCastbarIconY])
			icon:SetScale(cfFramesDB[V.NameplateCastbarIconScale])
		end
	end
end

function cff.EnableNameplateCastbarIcon()
	if not cfFramesDB[M.NameplateCastbarIcon] then return end
	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		if plate.cffCastBar and plate.cffCastBar.Icon then
			plate.cffCastBar.Icon:Show()
		end
	end
end

function cff.DisableNameplateCastbarIcon()
	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		if plate.cffCastBar and plate.cffCastBar.Icon then
			plate.cffCastBar.Icon:Hide()
		end
	end
end
