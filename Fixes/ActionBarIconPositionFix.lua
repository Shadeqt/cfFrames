function cff.InitActionBarIconPositionFix()
	if not cfFramesDB[cff.MODULES.ActionBarIconPositionFix] then return end

	local bars = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton", "MultiBarLeftButton" }
	for _, bar in ipairs(bars) do
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			local btn = _G[bar .. i]
			if not btn then break end
			local icon = btn.icon or btn.Icon or _G[btn:GetName() .. "Icon"]
			if icon then
				icon:ClearAllPoints()
				icon:SetPoint("CENTER", btn, "CENTER", -0.5, -0.5)
				icon:SetSize(btn:GetWidth(), btn:GetHeight() + 0.5)
			end
		end
	end
end
