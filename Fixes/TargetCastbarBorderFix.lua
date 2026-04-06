function cff.InitTargetCastbarBorderFix()
	if not cfFramesDB[cff.MODULES.TargetCastbarBorderFix] then return end
	if not TargetFrameSpellBar or not TargetFrameSpellBar.Border then return end

	local border = TargetFrameSpellBar.Border
	for i = 1, border:GetNumPoints() do
		local point, relativeTo, relativePoint, x, y = border:GetPoint(i)
		if point == "TOPLEFT" then
			border:SetPoint(point, relativeTo, relativePoint, x - 2, y)
		elseif point == "TOPRIGHT" then
			border:SetPoint(point, relativeTo, relativePoint, x + 2, y)
		end
	end
end
