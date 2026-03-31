local function GetUnitColor(unit)
    if UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        if not class then return end
        return GetClassColor(class)
    end
    local controlled = UnitPlayerControlled(unit)
    if not controlled and UnitIsTapDenied(unit) then
        return 0.5, 0.5, 0.5
    elseif controlled then
        return FRIENDLY_STATUS_COLOR:GetRGB()
    else
        return UnitSelectionColor(unit)
    end
end

local function ColorBar(bar, unit)
    if not bar or bar:IsForbidden() or not unit then return end
    local r, g, b = GetUnitColor(unit)
    if r then bar:SetStatusBarColor(r, g, b) end
end

function cfFrames.initHealthbarColor()
    hooksecurefunc("UnitFrameHealthBar_Update", ColorBar)
    hooksecurefunc("HealthBar_OnValueChanged", function(self)
        if self.unit then ColorBar(self, self.unit) end
    end)
    if CompactUnitFrame_UpdateHealthColor then
        hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(f)
            if f and f.unit then ColorBar(f.healthBar, f.unit) end
        end)
    end
    if TargetFrameToTHealthBar then
        hooksecurefunc(TargetFrameToTHealthBar, "SetValue", function()
            if UnitExists("targettarget") then
                ColorBar(TargetFrameToTHealthBar, "targettarget")
            end
        end)
    end
end
