local M = cff.MODULES
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

-- Sync CVar-based toggles (raid = instant, nameplates = needs reload)
function cff.SyncHealthbarCVars()
	SetCVar("raidFramesDisplayClassColor", cfFramesDB[M.HealthbarColorRaid] and "1" or "0")
	SetCVar("ShowClassColorInNameplate", cfFramesDB[M.HealthbarColorNameplateEnemy] and "1" or "0")
	SetCVar("ShowClassColorInFriendlyNameplate", cfFramesDB[M.HealthbarColorNameplateFriendly] and "1" or "0")
end

local function RefreshUnitFrames()
	if UnitExists("player") then
		UnitFrameHealthBar_Update(PlayerFrameHealthBar, "player")
		if cfFramesDB[M.HealthbarColor] then ColorBar(PlayerFrameHealthBar, "player") end
	end
	if UnitExists("target") then
		UnitFrameHealthBar_Update(TargetFrameHealthBar, "target")
		if cfFramesDB[M.HealthbarColor] then ColorBar(TargetFrameHealthBar, "target") end
	end
	if UnitExists("targettarget") then
		UnitFrameHealthBar_Update(TargetFrameToTHealthBar, "targettarget")
		if cfFramesDB[M.HealthbarColor] then ColorBar(TargetFrameToTHealthBar, "targettarget") end
	end
	for i = 1, MAX_PARTY_MEMBERS do
		local unit = "party" .. i
		if UnitExists(unit) then
			local bar = _G["PartyMemberFrame" .. i .. "HealthBar"]
			if bar then
				UnitFrameHealthBar_Update(bar, unit)
				if cfFramesDB[M.HealthbarColor] then ColorBar(bar, unit) end
			end
		end
	end
end

local function HookUnitFrames()
	hooksecurefunc("UnitFrameHealthBar_Update", function(bar, unit)
		if not cfFramesDB[M.HealthbarColor] then return end
		if bar == TargetFrameToTHealthBar then return end
		ColorBar(bar, unit)
	end)

	hooksecurefunc("HealthBar_OnValueChanged", function(self)
		if not cfFramesDB[M.HealthbarColor] then return end
		if self.unit then ColorBar(self, self.unit) end
	end)
end

local function HookTargetOfTarget()
	if not TargetFrameToTHealthBar then return end
	hooksecurefunc(TargetFrameToTHealthBar, "SetValue", function()
		if not cfFramesDB[M.HealthbarColor] then return end
		if UnitExists("targettarget") then ColorBar(TargetFrameToTHealthBar, "targettarget") end
	end)
	local f = CreateFrame("Frame")
	f:RegisterUnitEvent("UNIT_TARGET", "target")
	f:SetScript("OnEvent", function()
		if not cfFramesDB[M.HealthbarColor] then return end
		if UnitExists("targettarget") then ColorBar(TargetFrameToTHealthBar, "targettarget") end
	end)
end

function cff.EnableHealthbarColor()
	if not cfFramesDB[M.HealthbarColor] then return end

	RefreshUnitFrames()

	if hooked then return end
	hooked = true

	HookUnitFrames()
	HookTargetOfTarget()
end

function cff.DisableHealthbarColor()
	RefreshUnitFrames()
end

