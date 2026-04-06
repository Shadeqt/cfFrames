local DEFAULTS = {
	x = 0, y = 0, scale = 1,
	castbar = true, castbarX = 0, castbarY = 0, castbarScale = 1,
	castbarIcon = true, iconX = 0, iconY = 0, iconScale = 1,
}

local previewing = false

local function EnsureDB()
	if not cfFramesDB.Nameplates then
		cfFramesDB.Nameplates = CopyTable(DEFAULTS)
	end
end

local function ApplyCastbar(nameplate)
	local bar = nameplate.cfCastBar
	if not bar then return end

	local db = cfFramesDB.Nameplates

	-- Castbar visibility
	if not db.castbar then
		bar:Hide()
		return
	end

	-- Castbar offset using known origin from NameplateCastbar.lua
	local origin = cfFrames.NameplateCastbarOrigin
	bar:SetPointsOffset(origin.x + db.castbarX, origin.y + db.castbarY)
	bar:SetScale(db.castbarScale)

	-- Icon
	if bar.Icon then
		if db.castbarIcon then
			bar.Icon:Show()
		else
			bar.Icon:Hide()
		end
		local iconOrigin = cfFrames.NameplateCastbarIconOrigin
		bar.Icon:SetPointsOffset(iconOrigin.x + db.iconX, iconOrigin.y + db.iconY)
		bar.Icon:SetSize(iconOrigin.size * db.iconScale, iconOrigin.size * db.iconScale)
	end
end

local function ApplyToNameplate(nameplate)
	EnsureDB()
	local db = cfFramesDB.Nameplates

	local uf = nameplate.UnitFrame
	if not uf then return end

	uf:SetPointsOffset(db.x, db.y)
	ApplyCastbar(nameplate)
end

local function ApplyScale()
	EnsureDB()
	local db = cfFramesDB.Nameplates
	C_CVar.SetCVar("nameplateGlobalScale", db.scale)
end

local function ApplyAll()
	ApplyScale()
	for _, nameplate in ipairs(C_NamePlate.GetNamePlates()) do
		ApplyToNameplate(nameplate)
	end
end

local function ResetAll()
	cfFramesDB.Nameplates = CopyTable(DEFAULTS)
	C_CVar.SetCVar("nameplateGlobalScale", 1)
	for _, nameplate in ipairs(C_NamePlate.GetNamePlates()) do
		local uf = nameplate.UnitFrame
		if uf then uf:ClearPointsOffset() end
		local bar = nameplate.cfCastBar
		if bar then
			bar:ClearPointsOffset()
			bar:SetScale(1)
			if bar.Icon then
				bar.Icon:ClearPointsOffset()
				local iconOrigin = cfFrames.NameplateCastbarIconOrigin
				bar.Icon:SetSize(iconOrigin.size, iconOrigin.size)
			end
		end
	end
end

local function StartPreviewBar(bar)
	bar:SetStatusBarColor(1, 0.7, 0, 1)
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)
	if bar.Text then bar.Text:SetText("Preview") end
	if bar.Icon then
		bar.Icon:SetTexture(136235)
		bar.Icon:Show()
	end
	bar:Show()
	bar:SetScript("OnUpdate", function(self, elapsed)
		local val = self:GetValue() + elapsed / 3
		if val >= 1 then val = 0 end
		self:SetValue(val)
	end)
end

local function PreviewAll()
	if previewing then
		previewing = false
		for _, nameplate in ipairs(C_NamePlate.GetNamePlates()) do
			if nameplate.cfCastBar then
				nameplate.cfCastBar:SetScript("OnUpdate", nil)
				nameplate.cfCastBar:Hide()
			end
		end
		return
	end

	previewing = true
	for _, nameplate in ipairs(C_NamePlate.GetNamePlates()) do
		if nameplate.cfCastBar then
			StartPreviewBar(nameplate.cfCastBar)
		end
	end
	ApplyAll()
end

-- Apply to new nameplates as they appear
local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:SetScript("OnEvent", function(_, _, unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	if not nameplate then return end

	ApplyToNameplate(nameplate)

	if previewing then
		C_Timer.After(0, function()
			if nameplate.cfCastBar then
				StartPreviewBar(nameplate.cfCastBar)
			end
		end)
	end
end)

cfFrames.Nameplates = {
	Apply = ApplyAll,
	Reset = ResetAll,
	Preview = PreviewAll,
}
