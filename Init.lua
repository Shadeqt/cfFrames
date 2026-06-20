local addonName, addon = ...

-- Re-entrancy marker, passed as the trailing arg to SetVertexColor. ActionBarAlphaFix and the
-- standalone cfDarkMode addon both hook SetVertexColor on the SAME ActionButton textures; each skips
-- writes carrying this flag so they recognize their own (and each other's) writes and don't loop.
-- The literal "cff" is a SHARED CONTRACT with cfDarkMode (its Init.lua sets the identical value):
-- changing one without the other reintroduces the ping-pong. This creates no presence dependency --
-- each addon works alone; the shared string only governs how they coexist.
addon.SENTINEL = "cff"

-- Shared layout helpers (used by BiggerUnitFrames and the PetManaBarOverlap fix). Promoted here from
-- the per-feature file so both can reach them. Raise a region's Y by dy, self-correcting against
-- Blizzard's repeated layout resets: re-baseline from the current default Y whenever it moves, so the
-- offset never compounds and never sticks to a stale base. Re-reads the anchor each call in case
-- Blizzard re-anchors to a new point.
local isReapplying = false  -- re-entrancy guard for the SetPoint hooks below
function addon.ApplyOffset(region, dy)
	if not region then return end
	local point, relativeTo, relativePoint, x, y = region:GetPoint()
	if not y then return end
	if not region.cfAppliedY or math.abs(region.cfAppliedY - y) > 0.5 then
		region.cfBaselineY = y  -- Blizzard's current default; re-baseline off it
	end
	region:ClearAllPoints()
	region:SetPoint(point, relativeTo, relativePoint, x, region.cfBaselineY + dy)
	region.cfAppliedY = region.cfBaselineY + dy
end

-- Apply addon.ApplyOffset and keep it applied past Blizzard's deferred layout by hooking the region's
-- own SetPoint and re-asserting -- making our write the last one. The guard skips the SetPoint we issue
-- ourselves; ApplyOffset is self-correcting, so re-asserting lands on default+dy without compounding.
function addon.KeepOffset(region, dy)
	if not region then return end
	addon.ApplyOffset(region, dy)
	if region.cfOffsetHookInstalled then return end
	region.cfOffsetHookInstalled = true
	hooksecurefunc(region, "SetPoint", function()
		if isReapplying then return end
		isReapplying = true
		addon.ApplyOffset(region, dy)
		isReapplying = false
	end)
end

-- DB schema (the single source of truth for cfFramesDB keys).
-- All module bools default true; StatusBarTexture is the one stored value.
-- Cut keys (frame-move/scale, the old DarkMode sub-toggles/colors, and the DarkMode master toggle now
-- that dark mode is the standalone cfDarkMode addon) are absent here, and InitDB() prunes them from any
-- existing saved DB.
addon.defaults = {
	-- General
	BiggerHealthbar           = true,
	NameplateClassification   = true,
	-- Class Colors (one master for the 5 absorbed cfClassColors features)
	ClassColors               = true,
	-- Hide (one bool per native element; was the single HideNative master, now split)
	HidePortraitGlow          = true,
	HidePlayerAttackGlow      = true,
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
	TargetCastbarBorderFix    = true,
	PetManaBarOverlapFix      = true,
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
	addon.SetupSettings()   -- register the GUI now that the DB is populated (explicit order, B1)
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
		addon.SetupTargetCastbarBorderFix()
		addon.SetupPetManaBarOverlapFix()
	end)
end)
