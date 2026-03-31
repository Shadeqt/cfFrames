-- Widens the target name text to prevent early truncation

function cfFrames.initNameTargetFix()
	local nameText = TargetFrame.name
	if not nameText then return end

	-- Widen the text region so longer names fit before ellipsis kicks in
	local width = nameText:GetWidth()
	nameText:SetWidth(width * 1.5)
end
