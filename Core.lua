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

function cff.GetStatusBarTexture()
	if cfFramesDB[cff.MODULES.StatusBar] then return cfFramesDB[cff.VALUES.StatusBarTexture] end
	return "Interface\\TargetingFrame\\UI-StatusBar"
end

