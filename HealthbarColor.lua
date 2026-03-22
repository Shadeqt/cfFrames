local M = cfFrames.MODULES

local COLORS = {
	SHAMAN       = { 0, 0.44, 0.87 },          -- blue (modern shaman, replaces pink)
	FRIENDLY     = { 0, 1, 0 },                 -- green (friendly NPCs/pets)
	TAPPED       = { 0.5, 0.5, 0.5 },           -- grey (Blizzard TargetFrame_CheckFaction)
	PLAYER_CONTROLLED = { 0, 0, 1 },            -- blue (UnitSelectionColor for players/pets)
	NAME_BG      = { 0, 0, 0, 0.5 },            -- dark semi-transparent name background
}

local function ColorsMatch(r, g, b, color)
	return r == color[1] and g == color[2] and b == color[3]
end

local function ColorHealthbar(statusbar, unit)
	if not statusbar or not unit then return end
	if not cfFramesDB[M.HEALTHBAR_COLOR] then return end
	if statusbar:IsForbidden() then return end

	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		if not class then return end
		local color = RAID_CLASS_COLORS[class]
		if not color then return end
		local r, g, b = color.r, color.g, color.b
		if class == "SHAMAN" then r, g, b = unpack(COLORS.SHAMAN) end
		statusbar:SetStatusBarColor(r, g, b)
	else
		local r, g, b = UnitSelectionColor(unit)
		if not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
			r, g, b = unpack(COLORS.TAPPED)
		elseif ColorsMatch(r, g, b, COLORS.PLAYER_CONTROLLED) then
			r, g, b = unpack(COLORS.FRIENDLY)
		end
		statusbar:SetStatusBarColor(r, g, b)
	end
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

local UNIT_BARS = {
	{bar = PlayerFrameHealthBar, unit = "player"},
	{bar = PetFrameHealthBar, unit = "pet"},
}

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
	for _, entry in ipairs(UNIT_BARS) do
		if entry.bar and UnitExists(entry.unit) then
			ColorHealthbar(entry.bar, entry.unit)
		end
	end
	if UnitExists("target") then
		ColorHealthbar(TargetFrameHealthBar, "target")
	end
	HideNameBackground()
end

local function Disable()
	for _, entry in ipairs(UNIT_BARS) do
		if entry.bar then
			entry.bar:SetStatusBarColor(unpack(COLORS.FRIENDLY))
		end
	end
	if UnitExists("target") then
		UnitFrameHealthBar_Update(TargetFrameHealthBar, "target")
	end
end

cfFrames:RegisterModule(M.HEALTHBAR_COLOR, Enable, Disable)
