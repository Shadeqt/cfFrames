function cff.InitTargetCastbarIconFix()
	if not cfFramesDB[cff.MODULES.TargetCastbarIconFix] then return end
	local icon = TargetFrameSpellBar and TargetFrameSpellBar.Icon
	if not icon then return end

	hooksecurefunc(icon, "SetPoint", function(self, a, b, c, x, y, flag)
		if flag == cff.SENTINEL then return end
		self:SetPoint(a, b, c, x, y - 1, cff.SENTINEL)
	end)
end
