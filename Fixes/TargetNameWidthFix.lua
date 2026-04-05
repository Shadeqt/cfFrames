function cff.InitTargetNameWidthFix()
	if not cfFramesDB.TargetNameWidthFix then return end
	local nameText = TargetFrame and TargetFrame.name
	if not nameText then return end

	local width = nameText:GetWidth()
	nameText:SetWidth(width * 1.15)
end
