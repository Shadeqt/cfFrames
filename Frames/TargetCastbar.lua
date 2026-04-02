local bar = TargetFrameSpellBar
if not bar then return end

local M = cfFrames.M
local DEFAULTS = { x = 0, y = 0, scale = 1 }
local ICON_DEFAULTS = { x = 0, y = 0, scale = 1 }

local Apply = cfFrames.Movable(bar, "TargetCastbar", DEFAULTS)

local previewing = false
local originalOnUpdate = nil

cfFrames.TargetCastbar = {
	Apply = function()
		Apply()
		if cfFrames.ApplyTargetCastbarIcon then cfFrames.ApplyTargetCastbarIcon() end
	end,

	Reset = function()
		cfFramesDB.TargetCastbar = CopyTable(DEFAULTS)
		cfFramesDB[M.CastbarTargetIcon] = true
		cfFramesDB.TargetCastbarIcon = CopyTable(ICON_DEFAULTS)
		cfFrames.TargetCastbar.Apply()
	end,

	Preview = function()
		if previewing then
			previewing = false
			if originalOnUpdate then bar:SetScript("OnUpdate", originalOnUpdate) end
			bar:Hide()
			return
		end

		originalOnUpdate = originalOnUpdate or bar:GetScript("OnUpdate")
		bar:SetScript("OnUpdate", nil)
		bar:SetAlpha(1)
		bar:Show()
		if not bar:IsVisible() then
			if originalOnUpdate then bar:SetScript("OnUpdate", originalOnUpdate) end
			return
		end

		previewing = true
		bar:SetStatusBarColor(1, 0.7, 0, 1)
		bar:SetMinMaxValues(0, 1)
		bar:SetValue(0)
		if bar.Text then bar.Text:SetText("Preview") end
		bar:SetScript("OnUpdate", function(self, elapsed)
			local val = self:GetValue() + elapsed / 3
			if val >= 1 then val = 0 end
			self:SetValue(val)
		end)
		if bar.Icon then
			bar.Icon:SetTexture(136235)
			bar.Icon:Show()
		end

		cfFrames.TargetCastbar.Apply()
	end,
}
