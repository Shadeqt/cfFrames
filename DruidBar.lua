-- cfDruidBar (folded into cfFrames): secondary mana bar for druids, shown under the player mana bar
-- while in a shapeshift form (when the displayed power isn't mana), so the hidden mana pool stays
-- visible. Reload-gated on cfFramesDB.DruidBar; run from addon.SetupDruidBar in Init's
-- PLAYER_ENTERING_WORLD pass. The text trio + status-text gating are shared with the target bars
-- (addon.CreateBarText / addon.ApplyBarStatusText in Init.lua): the bar is flagged cfManaged and gates on
-- statusTextDisplay like every other cf bar -- hidden on NONE unless moused over, numeric otherwise, with
-- the "Mana" prefix shown on mouseover only (matching the player mana bar).

local _, addon = ...

local MANA = Enum.PowerType.Mana

local bar, border

local function CreateBar()
    bar = CreateFrame("StatusBar", nil, PlayerFrame)
    bar:SetPoint("TOPLEFT", PlayerFrameManaBar, "BOTTOMLEFT", 1, -2)
    bar:SetPoint("TOPRIGHT", PlayerFrameManaBar, "BOTTOMRIGHT", 1, -2)  -- width follows the mana bar
    bar:SetHeight(PlayerFrameManaBar:GetHeight())
    bar:SetFrameLevel(PlayerFrame:GetFrameLevel() - 1)  -- behind the frame, so its border tucks over our top edge

    local background = bar:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0, 0, 0, 0.5)  -- our bar's own dark backing (nothing on the mana bar to read)
end

local function CreateBorder()
    border = CreateFrame("Frame", nil, bar, "BackdropTemplate")
    border:SetPoint("TOPLEFT", bar, -3, 2)       -- frame the bar just outside its edges
    border:SetPoint("BOTTOMRIGHT", bar, 3, -2)
    border:SetBackdrop({ edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border", edgeSize = 8 })
end

-- Text trio is built in SetupDruidBar via the shared addon.CreateBarText: parented to border (a frame
-- level above bar) so the text draws OVER the border edge instead of under it, but anchored to bar.

-- Mirror the player MANA bar's texture, then re-apply mana color (SetStatusBarTexture clears it).
local function SyncTexture()
    bar:SetStatusBarTexture(PlayerFrameManaBar:GetStatusBarTexture():GetTexture())
    local manaColor = PowerBarColor[MANA]
    bar:SetStatusBarColor(manaColor.r, manaColor.g, manaColor.b)
end

-- Follow cfDarkMode's chrome darkness on our own border via the public API, not by observing
-- PlayerFrameTexture. No producer -> leave the default border (vanilla look).
local function SyncBorderColor()
    if cfDarkMode then cfDarkMode.Darken(border) end
end

-- Render the text for the current hover state: show the "Mana" prefix on mouseover only (the native mana
-- bar suppresses it off-hover via a textLockable cvar this custom bar lacks), then let the shared
-- cfManaged gate (Init.lua) hide it on NONE-no-hover.
local function Refresh(self)
    if not self:IsShown() then return end  -- TextStatusBar_UpdateTextString would Show() a hidden bar
    self.prefix = self:IsMouseOver() and _G["MANA"] or nil
    TextStatusBar_UpdateTextString(self)
end

local function OnEvent(self, event, arg1, arg2)
    if event == "UNIT_POWER_UPDATE" then
        if arg2 ~= "MANA" or not self:IsShown() then return end
        self:SetValue(UnitPower("player", MANA))
    elseif event == "CVAR_UPDATE" then
        -- Custom bar: Blizzard won't re-render us on a statusTextDisplay change like it does its own
        -- bars, so we re-render ourselves below. Ignore every other CVar.
        if arg1 ~= "statusTextDisplay" then return end
    else
        self:SetMinMaxValues(0, UnitPowerMax("player", MANA))
        self:SetValue(UnitPower("player", MANA))
        self:SetShown(UnitPowerMax("player", MANA) > 0 and UnitPowerType("player") ~= MANA)
    end
    Refresh(self)
end

function addon.SetupDruidBar()
    if not cfFramesDB.DruidBar then return end
    local _, class = UnitClass("player")
    if class ~= "DRUID" then return end   -- classFilename token (locale-safe); no class enum exists

    CreateBar()
    CreateBorder()
    -- Anchored to bar (positioning) but parented to border (draws over the border edge).
    addon.CreateBarText(bar, border, {
        left   = { bar, 3, 0 },
        center = { bar, 0, 0 },
        right  = { bar, -2, 0 },
    })

    -- Force text on in all modes (parity with the target bars) and route through the shared
    -- statusTextDisplay gate (Init.lua's cfManaged hook): hidden on NONE unless moused over, numeric
    -- otherwise. The "Mana" prefix is toggled per-hover by Refresh.
    bar.lockShow = 1
    bar.cfManaged = true

    SyncTexture()
    SyncBorderColor()
    hooksecurefunc(PlayerFrameManaBar, "SetStatusBarTexture", SyncTexture)

    bar:Hide()
    bar:SetScript("OnEvent", OnEvent)
    -- The bar sits behind PlayerFrame (frame level -1) and never receives the mouse itself, so it can't
    -- get OnEnter. Lay an invisible mouse region over it -- parented to bar (so it shows/hides WITH the
    -- bar), raised above PlayerFrame (so the mouse reaches it) -- and reveal the text from OnEnter/OnLeave.
    local hover = CreateFrame("Frame", nil, bar)
    hover:SetAllPoints(bar)
    hover:SetFrameLevel(PlayerFrame:GetFrameLevel() + 10)
    hover:EnableMouse(true)
    hover:SetScript("OnEnter", function() Refresh(bar) end)
    hover:SetScript("OnLeave", function() Refresh(bar) end)
    bar:RegisterEvent("PLAYER_ENTERING_WORLD")
    bar:RegisterEvent("CVAR_UPDATE")                              -- re-render on a live statusTextDisplay change
    bar:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    bar:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    bar:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
    OnEvent(bar, "PLAYER_ENTERING_WORLD")
end
