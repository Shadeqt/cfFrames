local addonName, addon = ...

-- Shared re-entrancy marker, passed as the trailing arg to SetVertexColor. DarkMode and
-- ActionBarAlphaFix both hook SetVertexColor on the same ActionButton textures; each skips
-- writes carrying this flag so they recognize their own (and each other's) writes and don't
-- loop. The value must be shared between those features, hence the namespace.
addon.SENTINEL = "cff"

-- DB schema (the single source of truth for cfFramesDB keys).
-- All module bools default true; StatusBarTexture is the one stored value.
-- Frame-move/scale keys and DarkMode sub-toggles/colors were cut in the rebuild
-- (frame moving removed; DarkMode is one toggle with hardcoded colors), so they
-- are absent here and InitDB() prunes them from any existing saved DB.
addon.defaults = {
	-- General
	BiggerHealthbar           = true,
	DarkMode                  = true,
	NameplateClassification   = true,
	-- Class Colors (one master for the 5 absorbed cfClassColors features)
	ClassColors               = true,
	-- Hide (one bool per native element; was the single HideNative master, now split)
	HidePortraitGlow          = true,
	HidePetCombatFlash        = true,
	HideGroupIndicator        = true,
	-- Fixes
	ActionBarAlphaFix         = true,
	ToTPortraitFix            = true,
	ToTBackgroundFix          = true,
	TargetNameWidthFix        = true,
	NameplateLevelPositionFix = true,
	ActionBarIconPositionFix  = true,
	PetActionBarCheckedFix    = true,
	UnitFrameResetFix         = true,
	-- Stored value: chosen status-bar texture (StatusBar on/off is encoded here;
	-- the GUI's "Blizzard Default" dropdown entry = feature off).
	StatusBarTexture = "Interface\\AddOns\\cfFrames\\Media\\StatusBar\\smooth",
}

function addon.InitDB()
	cfFramesDB = cfFramesDB or {}
	-- Merge newly-added defaults.
	for key, value in pairs(addon.defaults) do
		if cfFramesDB[key] == nil then
			cfFramesDB[key] = value
		end
	end
	-- Prune keys no longer in the schema (e.g. cut frame-move / DarkMode-color keys).
	for key in pairs(cfFramesDB) do
		if addon.defaults[key] == nil then
			cfFramesDB[key] = nil
		end
	end
end

EventUtil.ContinueOnAddOnLoaded(addonName, function()
	addon.InitDB()
	-- Defer feature setup to PLAYER_ENTERING_WORLD (nameplates / compact-raid exist there).
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:SetScript("OnEvent", function(self)
		self:UnregisterAllEvents()
		-- Setup* calls are appended here, one per feature step (explicit order, B1).
		addon.SetupStatusBar()
		addon.SetupBiggerHealthbar()
		addon.SetupNameplateClassification()
		addon.SetupHideNative()
		addon.SetupDarkMode()
		addon.SetupDarkModeIcons()
		addon.SetupClassColors()

		-- Fixes
		addon.SetupActionBarAlphaFix()
		addon.SetupToTPortraitFix()
		addon.SetupToTBackgroundFix()
		addon.SetupTargetNameWidthFix()
		addon.SetupNameplateLevelPositionFix()
		addon.SetupActionBarIconPositionFix()
		addon.SetupPetActionBarCheckedFix()
		addon.SetupUnitFrameResetFix()
	end)
end)
