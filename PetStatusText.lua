local function ShrinkText(fontString)
	if not fontString then return end
	local font, size, flags = fontString:GetFont()
	if font and size then
		fontString:SetFont(font, size - 2, flags)
	end
end

local function ShrinkBarText(bar)
	if not bar then return end
	ShrinkText(bar.TextString)
	ShrinkText(bar.LeftText)
	ShrinkText(bar.RightText)
end

function cfFrames.initPetStatusText()
	ShrinkBarText(PetFrameHealthBar)
	ShrinkBarText(PetFrameManaBar)
end
