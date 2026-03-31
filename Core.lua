-- Style registries — features register their styling functions during init,
-- other features call these without knowing who registered them.

local textureStyles = {}
local iconStyles = {}
local regionStyles = {}
local barTextSetups = {}
local barTexture = nil

function cfFrames.registerTextureStyle(fn)
	table.insert(textureStyles, fn)
end

function cfFrames.registerIconStyle(fn)
	table.insert(iconStyles, fn)
end

function cfFrames.registerRegionStyle(fn)
	table.insert(regionStyles, fn)
end

function cfFrames.registerBarTextSetup(fn)
	table.insert(barTextSetups, fn)
end

function cfFrames.styleTexture(texture)
	for _, fn in ipairs(textureStyles) do fn(texture) end
end

function cfFrames.styleIcon(icon)
	for _, fn in ipairs(iconStyles) do fn(icon) end
end

function cfFrames.styleRegions(frame)
	for _, fn in ipairs(regionStyles) do fn(frame) end
end

function cfFrames.setupBarText(bar, parent)
	for _, fn in ipairs(barTextSetups) do fn(bar, parent) end
end

function cfFrames.registerBarTexture(texture)
	barTexture = texture
end

function cfFrames.getBarTexture()
	return barTexture or "Interface\\TargetingFrame\\UI-StatusBar"
end
