local addon = cfFrames

-- State
local tickFrame
local spark
local previousMana = 0
local nextManaTickTime = 0      -- When next mana tick will happen (tick tracking mode)
local fiveSecondRuleEnd = 0     -- When 5-second rule ends (5SR countdown mode)

local TICK_INTERVAL = 2
local FIVE_SEC_RULE = 5

-- Create the tick indicator overlay
local function SetupTickBar()
    tickFrame = CreateFrame("StatusBar", nil, PlayerFrameManaBar)
    tickFrame:SetPoint("TOPLEFT", PlayerFrameManaBar, "TOPLEFT", 2, 0)
    tickFrame:SetPoint("BOTTOMRIGHT", PlayerFrameManaBar, "BOTTOMRIGHT", 2, 0)
    tickFrame:SetMinMaxValues(0, TICK_INTERVAL)
    tickFrame:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    tickFrame:SetStatusBarColor(0, 0, 0, 0)

    spark = tickFrame:CreateTexture(nil, "OVERLAY")
    spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    spark:SetWidth(16)
    spark:SetBlendMode("ADD")
    spark:SetVertexColor(1, 1, 1)

    tickFrame:Hide()
end

-- Update spark position
local function UpdateSparkPosition(self, elapsed)
    local now = GetTime()
    local currentMana = UnitPower("player", 0)
    local maxMana = UnitPowerMax("player", 0)

    -- Hide if at full mana
    if currentMana >= maxMana then
        tickFrame:Hide()
        tickFrame:SetScript("OnUpdate", nil)
        return
    end

    local remaining, progress, sparkPos

    -- Check which mode we're in based on which timer is active
    if fiveSecondRuleEnd > 0 then
        -- 5SR countdown mode (reverse)

        -- Check if 5SR ended, transition to tick tracking
        if now >= fiveSecondRuleEnd then
            fiveSecondRuleEnd = 0
            nextManaTickTime = now + TICK_INTERVAL
        else
            -- Show reverse countdown
            remaining = fiveSecondRuleEnd - now
            progress = remaining / FIVE_SEC_RULE  -- Reverse: 1.0 to 0.0
            sparkPos = PlayerFrameManaBar:GetWidth() * progress
        end
    end

    if nextManaTickTime > 0 then
        -- Tick tracking mode (forward)

        -- Auto-reset timer if it expired
        if now >= nextManaTickTime then
            nextManaTickTime = now + TICK_INTERVAL
        end

        remaining = nextManaTickTime - now
        progress = 1 - (remaining / TICK_INTERVAL)
        sparkPos = PlayerFrameManaBar:GetWidth() * progress
    end

    if not sparkPos then return end

    spark:ClearAllPoints()
    spark:SetPoint("CENTER", tickFrame, "LEFT", sparkPos, 0)
    spark:SetHeight(PlayerFrameManaBar:GetHeight() * 3)
end

-- Handle mana changes
local function OnPowerUpdate(self, event, unit, powerType)
    if unit ~= "player" then return end
    if powerType ~= "MANA" then return end

    local now = GetTime()
    local currentMana = UnitPower("player", 0)

    -- Mana decreased = spell cast, start 5SR
    if currentMana < previousMana then
        nextManaTickTime = 0  -- Clear tick tracking
        fiveSecondRuleEnd = now + FIVE_SEC_RULE  -- Start 5SR countdown
        tickFrame:Show()
        tickFrame:SetScript("OnUpdate", UpdateSparkPosition)
    end

    -- Mana increased while in tick tracking mode = tick detected
    -- Only reset timer if this seems like a real tick (not a small gain from other sources)
    if nextManaTickTime > 0 and currentMana > previousMana then
        local gainAmount = currentMana - previousMana
        -- Only reset for significant gains (>10 mana, likely a real tick)
        if gainAmount >= 10 then
            nextManaTickTime = now + TICK_INTERVAL
        end
    end

    previousMana = currentMana
end

-- Module initialization
addon:RegisterModuleInit(function()
    if not cfFramesDB[addon.MODULES.RESOURCE_TICKER] then return end

    SetupTickBar()

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("UNIT_POWER_UPDATE")
    frame:SetScript("OnEvent", OnPowerUpdate)

    previousMana = UnitPower("player", 0)
end)
