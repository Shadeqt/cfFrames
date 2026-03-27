local M = cfFrames.MODULES

local COLORS = {
	SHAMAN       = { 0, 0.44, 0.87 },          -- blue (modern shaman, replaces pink)
	FRIENDLY     = { 0, 1, 0 },                 -- green (friendly NPCs/pets)
	TAPPED       = { 0.5, 0.5, 0.5 },           -- grey (Blizzard TargetFrame_CheckFaction)
	NAME_BG      = { 0, 0, 0, 0.5 },            -- dark semi-transparent name background
}

local function ColorsMatch(r, g, b, color)
	return r == color[1] and g == color[2] and b == color[3]
end

local function ColorPlayer(unit)
	local _, class = UnitClass(unit)
	if not class then return end
	local color = RAID_CLASS_COLORS[class]
	if not color then return end
	if class == "SHAMAN" then return unpack(COLORS.SHAMAN) end
	return color.r, color.g, color.b
end

local function GetUnitColor(unit)
	if UnitIsPlayer(unit) then
		return ColorPlayer(unit)
	elseif not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
		return unpack(COLORS.TAPPED)
	elseif UnitPlayerControlled(unit) then
		return unpack(COLORS.FRIENDLY)
	else
		return UnitSelectionColor(unit)
	end
end

local function ColorHealthbar(statusbar, unit)
	if not statusbar or not unit then return end
	if not cfFramesDB[M.HEALTHBAR_COLOR] then return end
	if statusbar:IsForbidden() then return end

	local r, g, b = GetUnitColor(unit)
	if r then statusbar:SetStatusBarColor(r, g, b) end
end

-- Standard unit frames
if UnitFrameHealthBar_Update then
	hooksecurefunc("UnitFrameHealthBar_Update", ColorHealthbar)
end
if HealthBar_OnValueChanged then
	hooksecurefunc("HealthBar_OnValueChanged", function(self)
		if self.unit then
			ColorHealthbar(self, self.unit)
		end
	end)
end

-- Raid frames
if CompactUnitFrame_UpdateHealthColor then
	hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
		if not frame or not frame.unit then return end
		ColorHealthbar(frame.healthBar, frame.unit)
	end)
end

-- ToT bar updates via poll timer, bypassing HealthBar_OnValueChanged
if TargetFrameToTHealthBar then
	hooksecurefunc(TargetFrameToTHealthBar, "SetValue", function()
		if UnitExists("targettarget") then
			ColorHealthbar(TargetFrameToTHealthBar, "targettarget")
		end
	end)
end

-- Recolor on events that don't trigger UnitFrameHealthBar_Update
local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function()
	if not cfFramesDB[M.HEALTHBAR_COLOR] then return end
	if UnitExists("target") then
		ColorHealthbar(TargetFrameHealthBar, "target")
	end
end)

-- Hide name background when healthbar already shows reaction color
local function HideNameBackground()
	if not TargetFrameNameBackground then return end
	TargetFrameNameBackground:SetVertexColor(unpack(COLORS.NAME_BG))
end

if TargetFrameNameBackground then
	hooksecurefunc(TargetFrameNameBackground, "SetVertexColor", function(self, r, g, b, a)
		if self.cfChanging then return end
		if not cfFramesDB[M.HEALTHBAR_COLOR] then return end
		if ColorsMatch(r, g, b, COLORS.NAME_BG) and a == COLORS.NAME_BG[4] then return end
		self.cfChanging = true
		self:SetVertexColor(unpack(COLORS.NAME_BG))
		self.cfChanging = false
	end)
end

local function Enable()
	if PlayerFrameHealthBar and UnitExists("player") then
		ColorHealthbar(PlayerFrameHealthBar, "player")
	end
	if PetFrameHealthBar and UnitExists("pet") then
		ColorHealthbar(PetFrameHealthBar, "pet")
	end
	if UnitExists("target") then
		ColorHealthbar(TargetFrameHealthBar, "target")
	end
	if TargetFrameToTHealthBar and UnitExists("targettarget") then
		ColorHealthbar(TargetFrameToTHealthBar, "targettarget")
	end
	HideNameBackground()
	eventFrame:RegisterEvent("UNIT_FACTION")
	eventFrame:RegisterEvent("UNIT_FLAGS")
end

local function Disable()
	eventFrame:UnregisterAllEvents()
	if PlayerFrameHealthBar then
		PlayerFrameHealthBar:SetStatusBarColor(unpack(COLORS.FRIENDLY))
	end
	if PetFrameHealthBar then
		PetFrameHealthBar:SetStatusBarColor(unpack(COLORS.FRIENDLY))
	end
	if UnitExists("target") then
		UnitFrameHealthBar_Update(TargetFrameHealthBar, "target")
		if TargetFrame_CheckFaction then
			TargetFrame_CheckFaction(TargetFrame)
		end
	end
end

cfFrames:RegisterModule(M.HEALTHBAR_COLOR, Enable, Disable)
