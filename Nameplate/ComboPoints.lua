local MAX_PIPS = 5

local function SetupPlate(frame)
    if frame.cfComboContainer then return end
    local parent = frame.healthBar
    local container = CreateFrame("Frame", nil, parent)
    container:SetPoint("BOTTOM", frame.name, "TOP", 0, 0)
    container:SetSize(80, 16)
    frame.cfComboContainer = container
    frame.cfComboPips = {}

    for i = 1, MAX_PIPS do
        local pip = container:CreateTexture(nil, "OVERLAY")
        pip:SetSize(14, 14)
        pip:SetPoint("LEFT", (i - 1) * 16, 0)
        pip:SetAtlas("ClassOverlay-ComboPoint-Off")
        frame.cfComboPips[i] = pip
    end
end

local function UpdatePips(frame, unit)
    if not frame.cfComboPips then return end
    local count = GetComboPoints("player", unit) or 0
    for i = 1, MAX_PIPS do
        frame.cfComboPips[i]:SetAtlas(i <= count and "ClassOverlay-ComboPoint" or "ClassOverlay-ComboPoint-Off")
    end
    if count > 0 then
        frame.cfComboContainer:Show()
    else
        frame.cfComboContainer:Hide()
    end
end

local lastPlate = nil

local f = CreateFrame("Frame")
f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
f:RegisterEvent("UNIT_POWER_UPDATE")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:SetScript("OnEvent", function(_, event, unit)
    if event == "NAME_PLATE_UNIT_ADDED" then
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if not plate or UnitIsPlayer(unit) then return end
        SetupPlate(plate.UnitFrame)
        UpdatePips(plate.UnitFrame, unit)
    elseif event == "UNIT_POWER_UPDATE" then
        if unit == "player" then
            local plate = C_NamePlate.GetNamePlateForUnit("target")
            if plate and plate.UnitFrame then
                UpdatePips(plate.UnitFrame, "target")
                lastPlate = plate
            end
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        if lastPlate and lastPlate.UnitFrame and lastPlate.UnitFrame.cfComboContainer then
            lastPlate.UnitFrame.cfComboContainer:Hide()
        end
        lastPlate = C_NamePlate.GetNamePlateForUnit("target")
    end
end)
