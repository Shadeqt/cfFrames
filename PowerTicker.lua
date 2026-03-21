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
	spark:SetSize(32, 32)
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

local overlayFrame

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self, event)
	if event == "UNIT_DISPLAYPOWER" then
		currentPowerType = UnitPowerType("player")
		lastPower = UnitPower("player")
	elseif event == "UNIT_POWER_UPDATE" then
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
end)

local function Enable()
	if not overlayFrame then
		overlayFrame = SetupOverlay()
	end
	overlayFrame:SetScript("OnUpdate", OnUpdate)
	frame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
	frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
	currentPowerType = UnitPowerType("player")
	lastPower = UnitPower("player")
	tickEndTime = GetTime() + TICK_INTERVAL
end

local function Disable()
	frame:UnregisterAllEvents()
	if overlayFrame then overlayFrame:SetScript("OnUpdate", nil) end
	if spark then spark:Hide() end
end

cfFrames:RegisterModule(M.POWER_TICKER, Enable, Disable)
