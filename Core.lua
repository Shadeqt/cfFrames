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

local BLIZZARD_STATUSBAR = "Interface\\TargetingFrame\\UI-StatusBar"

function cff.GetStatusBarTexture()
	local tex = cfFramesDB[cff.MODULES.StatusBar]
	if not tex or tex == true or tex == BLIZZARD_STATUSBAR then return nil end
	return tex
end
