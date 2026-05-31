local _, addon = ...

function addon.SetupTargetNameWidthFix()
	if not cfFramesDB.TargetNameWidthFix then return end
	local nameText = TargetFrame and TargetFrame.name
	if not nameText then return end

	-- Load-once: scales the current width; re-running would compound, but Setup runs once.
	nameText:SetWidth(nameText:GetWidth() * 1.15)
end
