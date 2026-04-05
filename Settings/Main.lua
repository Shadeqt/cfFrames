EventUtil.ContinueOnAddOnLoaded("cfFrames", function()
	local M = cff.MODULES
	local d = cff.DEFAULTS
	local category = Settings.RegisterVerticalLayoutCategory("cfFrames")
	cff.category = category

	local general = {
		[M.StatusBar] = function(key)
			local s = Settings.RegisterAddOnSetting(
				category, key, key, cfFramesDB,
				Settings.VarType.String, "Status Bar Texture", d[key]
			)
			Settings.CreateDropdown(category, s, function()
				local c = Settings.CreateControlTextContainer()
				c:Add("Interface\\TargetingFrame\\UI-StatusBar", "Blizzard")
				c:Add("Interface\\AddOns\\cfFrames\\Media\\StatusBar\\BlizzardRetailBarCrop2", "Retail Bar")
				c:Add("Interface\\AddOns\\cfFrames\\Media\\StatusBar\\DragonflightTexture", "Dragonflight")
				return c:GetData()
			end, "Choose status bar texture")
			Settings.SetOnValueChangedCallback(key, function()
				cff.EnableStatusBar()
			end)
		end,
		[M.BiggerHealthbar] = function(key)
			local s = Settings.RegisterAddOnSetting(
				category, key, key, cfFramesDB,
				Settings.VarType.Boolean, "Bigger Health Bars", d[key]
			)
			Settings.CreateCheckbox(category, s, "Enlarge player and target health bars")
			Settings.SetOnValueChangedCallback(key, function()
				if cfFramesDB[key] then
					cff.EnableBiggerHealthbar()
				else
					cff.DisableBiggerHealthbar()
				end
			end)
		end,
		[M.HealthbarColor] = function(key)
			local s = Settings.RegisterAddOnSetting(
				category, key, key, cfFramesDB,
				Settings.VarType.Boolean, "Class Health Colors", d[key]
			)
			Settings.CreateCheckbox(category, s, "Color health bars by class for players, by reaction for NPCs")
			Settings.SetOnValueChangedCallback(key, function()
				if cfFramesDB[key] then
					cff.EnableHealthbarColor()
				else
					cff.DisableHealthbarColor()
				end
			end)
		end,
	}
	for _, key in ipairs(M) do
		if general[key] then general[key](key) end
	end

	-- Fixes
	local layout = SettingsPanel:GetLayout(category)
	local headerInitializer = CreateFromMixins(ScrollBoxFactoryInitializerMixin)
	headerInitializer:Init("SettingsListSectionHeaderTemplate")
	function headerInitializer:InitFrame(frame)
		frame.Title:SetText("Fixes (requires reload)")
	end
	function headerInitializer:ShouldShow()
		return true
	end
	function headerInitializer:GetExtent()
		return 26
	end
	function headerInitializer:IsSearchIgnoredInLayout()
		return true
	end
	layout:AddInitializer(headerInitializer)

	local fixes = {
		[M.ActionBarAlphaFix]         = { name = "Action Bar Alpha Fix",         tooltip = "Reduces action bar button texture alpha to 50%" },
		[M.ToTPortraitFix]            = { name = "ToT Portrait Fix",             tooltip = "Adjusts Target-of-Target portrait position and size" },
		[M.TargetCastbarBorderFix]    = { name = "Target Castbar Border Fix",    tooltip = "Widens target castbar border to align properly" },
		[M.TargetNameWidthFix]        = { name = "Target Name Width Fix",        tooltip = "Increases target name text width to reduce truncation" },
		[M.TargetCastbarIconFix]      = { name = "Target Castbar Icon Fix",      tooltip = "Adjusts target castbar icon vertical position" },
		[M.NameplateLevelPositionFix] = { name = "Nameplate Level Position Fix", tooltip = "Centers level text on compact unit frame nameplates" },
	}
	for _, key in ipairs(M) do
		local fix = fixes[key]
		if fix then
			local s = Settings.RegisterAddOnSetting(category, key, key, cfFramesDB, Settings.VarType.Boolean, fix.name, d[key])
			Settings.CreateCheckbox(category, s, fix.tooltip)
		end
	end

	SettingsPanel:SetMovable(true)
	SettingsPanel:EnableMouse(true)
	SettingsPanel:RegisterForDrag("LeftButton")
	SettingsPanel:SetScript("OnDragStart", SettingsPanel.StartMoving)
	SettingsPanel:SetScript("OnDragStop", SettingsPanel.StopMovingOrSizing)

	SLASH_CFF1 = "/cff"
	SlashCmdList["CFF"] = function()
		Settings.OpenToCategory(category:GetID())
	end
end)
