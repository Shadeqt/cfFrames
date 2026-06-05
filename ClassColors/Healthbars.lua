local _, addon = ...

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

-- Color whatever bars are already present at setup. The player always exists, and party
-- members persist across /reload, so those get colored now; target/tot are cleared on
-- reload, so those checks are guarded no-ops until one is acquired (handled by hooks).
local function ColorExistingBars()
	if UnitExists("player") then ColorBar(PlayerFrameHealthBar, "player") end
	if UnitExists("target") then ColorBar(TargetFrameHealthBar, "target") end
	if UnitExists("targettarget") then ColorBar(TargetFrameToTHealthBar, "targettarget") end
	for i = 1, MAX_PARTY_MEMBERS do
		local unit = "party" .. i
		if UnitExists(unit) then ColorBar(_G["PartyMemberFrame" .. i .. "HealthBar"], unit) end
	end
end

function addon.SetupHealthbars()
	-- SetStatusBarTexture (the StatusBar feature) clears the bar color, but these hooks re-apply
	-- on the next health update / value change, so the class tint self-heals after a retexture.
	hooksecurefunc("UnitFrameHealthBar_Update", function(bar, unit)
		if bar == TargetFrameToTHealthBar then return end
		ColorBar(bar, unit)
	end)

	hooksecurefunc("HealthBar_OnValueChanged", function(self)
		if self.unit then ColorBar(self, self.unit) end
	end)

	if TargetFrameToTHealthBar then
		hooksecurefunc(TargetFrameToTHealthBar, "SetValue", function()
			if UnitExists("targettarget") then ColorBar(TargetFrameToTHealthBar, "targettarget") end
		end)
		local f = CreateFrame("Frame")
		f:RegisterUnitEvent("UNIT_TARGET", "target")
		f:SetScript("OnEvent", function()
			if UnitExists("targettarget") then ColorBar(TargetFrameToTHealthBar, "targettarget") end
		end)
	end

	ColorExistingBars()
end
