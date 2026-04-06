local bar = CastingBarFrame
if not bar then return end

local M = cfFrames.M
local DEFAULTS = { x = 0, y = 0, scale = 1 }
local ICON_DEFAULTS = { x = 0, y = 0, scale = 1 }

local Apply = cfFrames.Movable(bar, "PlayerCastbar", DEFAULTS)

local previewing = false
local originalOnUpdate = nil

cfFrames.PlayerCastbar = {
	Apply = function()
		Apply()
		if cfFrames.ApplyPlayerCastbarIcon then cfFrames.ApplyPlayerCastbarIcon() end
	end,

	Reset = function()
		cfFramesDB.PlayerCastbar = CopyTable(DEFAULTS)
		cfFramesDB[M.CastbarPlayerIcon] = true
		cfFramesDB.PlayerCastbarIcon = CopyTable(ICON_DEFAULTS)
		cfFrames.PlayerCastbar.Apply()
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

		local icon = cfFrames.playerCastbarIcon
		if icon and cfFramesDB[M.CastbarPlayerIcon] then
			icon:SetTexture(136235)
			icon:Show()
			if bar.cfIconBorder then bar.cfIconBorder:Show() end
		end

		cfFrames.PlayerCastbar.Apply()
	end,
}
