local hooked = false

local function GetColor(unit)
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		if class then return GetClassColor(class) end
	elseif UnitIsTapDenied(unit) then
		return 0.5, 0.5, 0.5
	elseif UnitPlayerControlled(unit) then
		return FRIENDLY_STATUS_COLOR:GetRGB()
	else
		return UnitSelectionColor(unit)
	end
end

local function ColorBar(bar, unit)
	if not bar or bar:IsForbidden() or not unit then return end
	local r, g, b = GetColor(unit)
	if r then bar:SetStatusBarColor(r, g, b) end
end

local function RefreshAll()
	if UnitExists("player") then
		UnitFrameHealthBar_Update(PlayerFrameHealthBar, "player")
		if cfFramesDB.HealthbarColor then ColorBar(PlayerFrameHealthBar, "player") end
	end
	if UnitExists("target") then
		UnitFrameHealthBar_Update(TargetFrameHealthBar, "target")
		if cfFramesDB.HealthbarColor then ColorBar(TargetFrameHealthBar, "target") end
	end
	if UnitExists("pet") then
		UnitFrameHealthBar_Update(PetFrameHealthBar, "pet")
		if cfFramesDB.HealthbarColor then ColorBar(PetFrameHealthBar, "pet") end
	end
	if UnitExists("targettarget") then
		UnitFrameHealthBar_Update(TargetFrameToTHealthBar, "targettarget")
		if cfFramesDB.HealthbarColor then ColorBar(TargetFrameToTHealthBar, "targettarget") end
	end
	for i = 1, 4 do
		local unit = "party" .. i
		if UnitExists(unit) then
			local bar = _G["PartyMemberFrame" .. i .. "HealthBar"]
			if bar then
				UnitFrameHealthBar_Update(bar, unit)
				if cfFramesDB.HealthbarColor then ColorBar(bar, unit) end
			end
		end
	end
	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		if plate.UnitFrame then ColorBar(plate.UnitFrame.healthBar, plate.UnitFrame.unit) end
	end
end

local function HookUnitFrames()
	hooksecurefunc("UnitFrameHealthBar_Update", function(bar, unit)
		if not cfFramesDB.HealthbarColor then return end
		if bar == TargetFrameToTHealthBar then return end
		ColorBar(bar, unit)
	end)

	hooksecurefunc("HealthBar_OnValueChanged", function(self)
		if not cfFramesDB.HealthbarColor then return end
		if self.unit then ColorBar(self, self.unit) end
	end)

	if CompactUnitFrame_UpdateHealthColor then
		hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(f)
			if not cfFramesDB.HealthbarColor then return end
			if f and f.unit then ColorBar(f.healthBar, f.unit) end
		end)
	end
end

local function HookTargetOfTarget()
	if not TargetFrameToTHealthBar then return end
	hooksecurefunc(TargetFrameToTHealthBar, "SetValue", function()
		if not cfFramesDB.HealthbarColor then return end
		if UnitExists("targettarget") then ColorBar(TargetFrameToTHealthBar, "targettarget") end
	end)
	local f = CreateFrame("Frame")
	f:RegisterUnitEvent("UNIT_TARGET", "target")
	f:SetScript("OnEvent", function()
		if not cfFramesDB.HealthbarColor then return end
		if UnitExists("targettarget") then ColorBar(TargetFrameToTHealthBar, "targettarget") end
	end)
end

local function RegisterNameplates()
	local f = CreateFrame("Frame")
	f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	f:SetScript("OnEvent", function(_, _, unit)
		if not cfFramesDB.HealthbarColor then return end
		local plate = C_NamePlate.GetNamePlateForUnit(unit)
		if plate and plate.UnitFrame then ColorBar(plate.UnitFrame.healthBar, unit) end
	end)
end

function cff.EnableHealthbarColor()
	if not cfFramesDB.HealthbarColor then return end

	RefreshAll()

	if hooked then return end
	hooked = true

	HookUnitFrames()
	HookTargetOfTarget()
	RegisterNameplates()
end

function cff.DisableHealthbarColor()
	RefreshAll()
end
