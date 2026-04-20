local d = cff.DEFAULTS

function cff.Checkbox(cat, key, name, tooltip, callback)
	local s = Settings.RegisterAddOnSetting(cat, key, key, cfFramesDB, Settings.VarType.Boolean, name, d[key])
	local cb = Settings.CreateCheckbox(cat, s, tooltip)
	if callback then Settings.SetOnValueChangedCallback(key, callback) end
	return cb
end

function cff.Slider(cat, key, name, tooltip, min, max, step, callback)
	local s = Settings.RegisterAddOnSetting(cat, key, key, cfFramesDB, Settings.VarType.Number, name, d[key])
	local opts = Settings.CreateSliderOptions(min, max, step)
	opts:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return format("%.2f", value) end)
	local slider = Settings.CreateSlider(cat, s, opts, tooltip)
	if callback then Settings.SetOnValueChangedCallback(key, callback) end
	return slider
end

function cff.Dropdown(cat, key, name, tooltip, options, callback)
	local s = Settings.RegisterAddOnSetting(cat, key, key, cfFramesDB, Settings.VarType.String, name, d[key])
	local dd = Settings.CreateDropdown(cat, s, options, tooltip)
	if callback then Settings.SetOnValueChangedCallback(key, callback) end
	return dd
end

function cff.InfoText(cat, getText)
	local layout = SettingsPanel:GetLayout(cat)
	local init = CreateFromMixins(ScrollBoxFactoryInitializerMixin)
	init:Init("SettingsListSectionHeaderTemplate")
	function init:InitFrame(frame)
		frame.Title:SetText(getText())
		frame.Title:SetFontObject("GameFontNormalSmall")
		frame.Title:SetTextColor(0.7, 0.7, 0.7)
	end
	function init:ShouldShow() return true end
	function init:GetExtent() return 20 end
	function init:IsSearchIgnoredInLayout() return true end
	layout:AddInitializer(init)
end

function cff.Header(cat, text, shownPredicate)
	local layout = SettingsPanel:GetLayout(cat)
	local init = CreateFromMixins(ScrollBoxFactoryInitializerMixin)
	init:Init("SettingsListSectionHeaderTemplate")
	function init:InitFrame(frame)
		frame.Title:SetText(text)
		frame.Title:SetFontObject("GameFontHighlightLarge")
		frame.Title:SetTextColor(1, 1, 1)
	end
	function init:ShouldShow() return not shownPredicate or shownPredicate() end
	function init:GetExtent() return 26 end
	function init:IsSearchIgnoredInLayout() return true end
	layout:AddInitializer(init)
end

-- Proxy table that reads/writes a CVar instead of cfFramesDB
local function CVarProxy(key, cvar, isNumber)
	local proxy = {}
	local mt = {
		__index = function(_, k)
			if k ~= key then return nil end
			local val = GetCVar(cvar)
			if isNumber then
				return tonumber(val) or tonumber(GetCVarDefault(cvar)) or 0
			else
				return val == "1"
			end
		end,
		__newindex = function(_, k, value)
			if k ~= key then return end
			SetCVar(cvar, isNumber and tostring(value) or (value and "1" or "0"))
		end,
	}
	setmetatable(proxy, mt)
	return proxy
end

local cvarCounter = 0
function cff.CVarCheckbox(cat, cvar, name, tooltip)
	cvarCounter = cvarCounter + 1
	local key = "cff_cvar_" .. cvarCounter
	local proxy = CVarProxy(key, cvar, false)
	local default = GetCVarBool(cvar)
	local s = Settings.RegisterAddOnSetting(cat, key, key, proxy, Settings.VarType.Boolean, name, default)
	Settings.CreateCheckbox(cat, s, tooltip)
end

function cff.CVarSlider(cat, cvar, name, tooltip, min, max, step)
	cvarCounter = cvarCounter + 1
	local key = "cff_cvar_" .. cvarCounter
	local proxy = CVarProxy(key, cvar, true)
	local default = tonumber(GetCVar(cvar)) or tonumber(GetCVarDefault(cvar)) or 0
	local s = Settings.RegisterAddOnSetting(cat, key, key, proxy, Settings.VarType.Number, name, default)
	local opts = Settings.CreateSliderOptions(min, max, step)
	opts:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return format("%.2f", value) end)
	Settings.CreateSlider(cat, s, opts, tooltip)
end

StaticPopupDialogs["CFF_RELOAD_UI"] = {
	text = "This setting requires a UI reload to take effect.\nReload now?",
	button1 = "Reload",
	button2 = "Later",
	OnAccept = ReloadUI,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

EventUtil.ContinueOnAddOnLoaded("cfFrames", function()
	cff.category = Settings.RegisterVerticalLayoutCategory("cfFrames")
	Settings.RegisterAddOnCategory(cff.category)

	SettingsPanel:SetMovable(true)
	SettingsPanel:EnableMouse(true)
	SettingsPanel:RegisterForDrag("LeftButton")
	SettingsPanel:SetScript("OnDragStart", SettingsPanel.StartMoving)
	SettingsPanel:SetScript("OnDragStop", SettingsPanel.StopMovingOrSizing)

	SLASH_CFF1 = "/cff"
	SlashCmdList["CFF"] = function()
		Settings.OpenToCategory(cff.category:GetID())
	end

	cff.SetupSettings()
	cff.SetupDarkModeSettings()
	cff.SetupPlayerSettings()
	cff.SetupPetSettings()
	cff.SetupTargetSettings()
	cff.SetupNameplateSettings()
end)
