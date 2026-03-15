local M = cfFrames.MODULES
local POWER = { MANA = 0, RAGE = 1, ENERGY = 3 }

local TICK_INTERVAL = 2
local FSR_DURATION = 5

local tickEndTime = 0
local fsrEndTime = 0
local lastPower = 0
local currentPowerType = 0
local spark

local function SetupOverlay()
	local overlayFrame = CreateFrame("Frame", nil, PlayerFrame)
	overlayFrame:SetAllPoints(PlayerFrameManaBar)
	overlayFrame:SetFrameLevel(PlayerFrame:GetFrameLevel() + 10)

	spark = overlayFrame:CreateTexture(nil, "OVERLAY")
	spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	spark:SetSize(16, 32)
	spark:SetBlendMode("ADD")
	spark:Hide()

	return overlayFrame
end

local function ShouldShowSpark()
	if currentPowerType == POWER.RAGE then return false end

	local fullPower = UnitPower("player") >= UnitPowerMax("player")

	if fullPower then
		if currentPowerType == POWER.MANA then
			return cfFramesDB[M.POWER_TICKER_MANA_FULL]
		elseif currentPowerType == POWER.ENERGY then
			return cfFramesDB[M.POWER_TICKER_ENERGY_FULL]
		end
		return false
	end

	if currentPowerType == POWER.MANA or currentPowerType == POWER.ENERGY then
		return true
	end

	return false
end

local function OnUpdate()
	if not ShouldShowSpark() then
		spark:Hide()
		return
	end

	local now = GetTime()
	local progress

	if currentPowerType == POWER.MANA and fsrEndTime > now then
		progress = (fsrEndTime - now) / FSR_DURATION
	else
		if tickEndTime <= now then
			local elapsed = (now - tickEndTime) % TICK_INTERVAL
			tickEndTime = now + TICK_INTERVAL - elapsed
		end
		progress = 1 - (tickEndTime - now) / TICK_INTERVAL
	end

	spark:SetPoint("CENTER", PlayerFrameManaBar, "LEFT", PlayerFrameManaBar:GetWidth() * progress, 0)
	spark:Show()
end

local handlers = {}

handlers.ADDON_LOADED = function(self, arg1)
	if arg1 ~= "cfFrames" then return end
	self:UnregisterEvent("ADDON_LOADED")
	if not cfFramesDB[M.POWER_TICKER] then return end

	local overlayFrame = SetupOverlay()
	overlayFrame:SetScript("OnUpdate", OnUpdate)

	self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
	
	currentPowerType = UnitPowerType("player")
	lastPower = UnitPower("player")
	tickEndTime = GetTime() + TICK_INTERVAL
end

handlers.UNIT_DISPLAYPOWER = function()
	currentPowerType = UnitPowerType("player")
	lastPower = UnitPower("player")
end

handlers.UNIT_POWER_UPDATE = function()
	local now = GetTime()
	local power = UnitPower("player")
	currentPowerType = UnitPowerType("player")

	if power > lastPower then
		tickEndTime = now + TICK_INTERVAL
	elseif power < lastPower and currentPowerType == POWER.MANA then
		fsrEndTime = now + FSR_DURATION
	end

	lastPower = power
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
	handlers[event](self, arg1)
end)
