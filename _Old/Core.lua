local barTexture = nil

function cfFrames.registerBarTexture(texture)
	barTexture = texture
end

function cfFrames.getBarTexture()
	return barTexture or "Interface\\TargetingFrame\\UI-StatusBar"
end
