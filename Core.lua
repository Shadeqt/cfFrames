local callbacks = {}

function cff.RegisterCallback(key, fn)
	if not callbacks[key] then callbacks[key] = {} end
	table.insert(callbacks[key], fn)
end

function cff.RunCallbacks(key)
	if not callbacks[key] then return end
	for _, fn in ipairs(callbacks[key]) do
		fn()
	end
end

function cff.GetStatusBarTexture()
	if cfFramesDB[cff.MODULES.StatusBar] then return cfFramesDB[cff.VALUES.StatusBarTexture] end
	return "Interface\\TargetingFrame\\UI-StatusBar"
end

function cff.CreateCastbar(parent, unit, width, height)
	local bar = CreateFrame("StatusBar", nil, parent, "SmallCastingBarFrameTemplate")
	bar:Hide()
	CastingBarFrame_OnLoad(bar, unit)
	if cfFramesDB[cff.MODULES.StatusBar] then bar:SetStatusBarTexture(cff.GetStatusBarTexture()) end

	bar:SetSize(width, height)

	local padX = width * 0.17
	local padY = height * 1.7
	bar.Border:SetDrawLayer("OVERLAY")
	bar.Border:ClearAllPoints()
	bar.Border:SetPoint("TOPLEFT", bar, -padX, padY)
	bar.Border:SetPoint("BOTTOMRIGHT", bar, padX, -padY)
	bar.Flash:ClearAllPoints()
	bar.Flash:SetPoint("TOPLEFT", bar, -padX, padY)
	bar.Flash:SetPoint("BOTTOMRIGHT", bar, padX, -padY)

	bar.Icon:ClearAllPoints()
	bar.Icon:SetPoint("RIGHT", bar, "LEFT", -5, 0)
	bar.Icon:SetSize(height * 1.5, height * 1.5)

	bar.Text:ClearAllPoints()
	bar.Text:SetPoint("CENTER")

	bar:HookScript("OnEvent", function(self, event)
		if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
			CastingBarFrame_OnEvent(self, "PLAYER_ENTERING_WORLD")
		end
	end)

	return bar
end