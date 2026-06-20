local _, addon = ...

-- DarkMode (cfFramesTest's newest implementation): darken UI chrome (unit-frame borders, action bars,
-- XP/rep chrome, minimap, chat, nameplate borders) by reducing their vertex color toward black.
-- Reload-gated on cfFramesDB.DarkMode; run once from Init's PLAYER_ENTERING_WORLD pass via SetupDarkMode.
--
-- Darkens frame CHROME/border art, not the health-bar fill -- so it doesn't fight HealthbarColor (fill
-- color) or StatusBarTexture (fill texture). It DOES tint BiggerUnitFrames' custom frame art (SetTexture
-- + SetVertexColor are independent layers).

-- Hardcoded darkness (the old DarkModeColor / DarkModeColorSecondary sliders, locked).
-- PRIMARY is shared with DarkModeIcons via the feature table (addon.DarkMode); DarkMode.lua loads first,
-- so it exists before DarkModeIcons reads it.
addon.DarkMode = {}
addon.DarkMode.PRIMARY = 0.5
local PRIMARY = addon.DarkMode.PRIMARY  -- main frames, borders, action bars, chat, nameplate borders
local SECONDARY = 0.75  -- small borderless elements (exhaustion, scroll/micro/keyring/zoom, clock)

-- The five standard action bars whose buttons get darkened. Shared with DarkModeIcons (loads after us).
addon.DarkMode.ACTION_BAR_NAMES = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton", "MultiBarLeftButton" }
local ACTION_BAR_NAMES = addon.DarkMode.ACTION_BAR_NAMES

-- Re-entrancy marker, passed as the trailing arg to SetVertexColor so DarkenHook recognizes its own
-- writes and doesn't loop. Shared (addon.SENTINEL) with ActionBarAlphaFix, which hooks the same
-- ActionButton textures -- each skips writes carrying this flag so they don't ping-pong.
local SENTINEL = addon.SENTINEL

local compactHooked = false
local nameplateHooked = false
local ldbIconHooked = false
local lodFrame = nil

local function ApplyDark(texture, color, desaturate, alpha)
	local c = color or PRIMARY
	local d = desaturate ~= false
	local _, _, _, a = texture:GetVertexColor()
	-- texture.cfPinAlpha (set on action-button borders below) overrides the live alpha so a transient
	-- ActionButton_ShowGrid alpha (0.5, set when an action is picked up) can't get latched permanently.
	texture:SetVertexColor(c, c, c, alpha or texture.cfPinAlpha or a, SENTINEL)
	texture:SetDesaturated(d)
end

-- Off is reload-gated, so no save-original/restore path is kept. Darkening sets an absolute color, so
-- it is idempotent and safe to re-run from the SetVertexColor hooks.
local function Darken(texture, color, desaturate, alpha)
	if not texture then return end
	if not texture:IsObjectType("Texture") then return end
	ApplyDark(texture, color, desaturate, alpha)
end

local function DarkenRegions(frame, color, desaturate, alpha)
	if not frame then return end
	for _, region in pairs({ frame:GetRegions() }) do
		Darken(region, color, desaturate, alpha)
	end
end

-- Shared SetVertexColor post-hook. One file-local closure reused for every hooked texture instead of
-- allocating a fresh one per texture. Skips its own writes (SENTINEL).
local function OnSetVertexColor(self, _, _, _, _, flag)
	if flag == SENTINEL then return end
	ApplyDark(self)
end

-- Darken now, then re-darken whenever Blizzard repaints the texture.
local function DarkenHook(texture)
	if not texture then return end
	Darken(texture)
	if texture.cfDarkHooked then return end
	texture.cfDarkHooked = true
	hooksecurefunc(texture, "SetVertexColor", OnSetVertexColor)
end

local function DarkenCompactMember(member)
	if not member then return end
	for _, region in pairs({ member:GetRegions() }) do
		local name = region:GetName()
		if name and (name:find("Border") or name:find("Divider") or name:find("Background")) then
			Darken(region)
		end
	end
	Darken(member.horizDivider)
	Darken(member.horizTopBorder)
	Darken(member.horizBottomBorder)
	Darken(member.vertLeftBorder)
	Darken(member.vertRightBorder)
end

local function DarkenCompactFrames()
	DarkenRegions(CompactPartyFrameBorderFrame)
	DarkenRegions(CompactRaidFrameContainerBorderFrame)
	for m = 1, MEMBERS_PER_RAID_GROUP do
		DarkenCompactMember(_G["CompactPartyFrameMember" .. m])
	end
	-- The flat (unsorted) raid list uses CompactRaidFrame1..MAX_RAID_MEMBERS, not just one group's
	-- worth -- looping only to MEMBERS_PER_RAID_GROUP left frames 6..40 (and their borders) un-darkened.
	for m = 1, MAX_RAID_MEMBERS do
		DarkenCompactMember(_G["CompactRaidFrame" .. m])
	end
	for g = 1, NUM_RAID_GROUPS do
		DarkenRegions(_G["CompactRaidGroup" .. g .. "BorderFrame"])
		for m = 1, MEMBERS_PER_RAID_GROUP do
			DarkenCompactMember(_G["CompactRaidGroup" .. g .. "Member" .. m])
		end
	end
end

-- The target frame art is darkened, but ELITE targets keep their color (not desaturated); every other
-- classification is desaturated. Re-evaluated on every target change (Blizzard re-sets the frame texture
-- in TargetFrame_CheckClassification). Idempotent (no last-state guard).
local function DarkenTargetFrameTexture()
	if not TargetFrameTextureFrameTexture then return end
	ApplyDark(TargetFrameTextureFrameTexture, nil, UnitClassification("target") ~= "elite")
end

local function DarkenFrames()
	Darken(PlayerFrameTexture)
	Darken(TargetFrameToTTextureFrameTexture)
	Darken(PetFrameTexture)
	for i = 1, MAX_PARTY_MEMBERS do
		Darken(_G["PartyMemberFrame" .. i .. "Texture"])
	end

	-- Compact party/raid frames (LoD)
	if CompactRaidFrameContainer_LayoutFrames then
		DarkenCompactFrames()
		if not compactHooked then
			compactHooked = true
			hooksecurefunc("CompactRaidFrameContainer_LayoutFrames", DarkenCompactFrames)
		end
	end
end

-- Native castbar borders. CastingBarFrame.Border doubles as the surface cfCastbars observes (reads its
-- vertex color) to follow dark mode. DarkenHook re-applies if Blizzard repaints, so the observed value
-- stays stable. BorderShield (non-interruptible casts) is darkened too; nil-safe.
local function DarkenCastbars()
	DarkenHook(CastingBarFrame.Border)
	DarkenHook(CastingBarFrame.BorderShield)
	if TargetFrameSpellBar then
		DarkenHook(TargetFrameSpellBar.Border)
		DarkenHook(TargetFrameSpellBar.BorderShield)
	end
end

local function DarkenActionBars()
	for i = 0, 3 do
		Darken(_G["MainMenuXPBarTexture" .. i])
		Darken(_G["MainMenuBarTexture" .. i])
		Darken(_G["MainMenuMaxLevelBar" .. i])
		if ReputationWatchBar and ReputationWatchBar.StatusBar then
			Darken(ReputationWatchBar.StatusBar["WatchBarTexture" .. i])
			Darken(ReputationWatchBar.StatusBar["XPBarTexture" .. i])
		end
	end

	Darken(MainMenuBarLeftEndCap)
	Darken(MainMenuBarRightEndCap)
	Darken(ExhaustionTickNormal, SECONDARY, false)
	Darken(ExhaustionTickHighlight, SECONDARY, false)

	-- Pin each border's baseline alpha (captured now, before any drag) so ApplyDark keeps re-asserting it.
	-- Otherwise picking up an action fires ActionButton_ShowGrid -> SetVertexColor(1,1,1,0.5); our hook
	-- captures that 0.5 and latches it permanently, leaving the border dimmed after a move.
	for _, barName in ipairs(ACTION_BAR_NAMES) do
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			local btn = _G[barName .. i]
			if btn then
				local tex = btn:GetNormalTexture()
				if tex then tex.cfPinAlpha = select(4, tex:GetVertexColor()) end
				DarkenHook(tex)
			end
		end
	end

	Darken(SlidingActionBarTexture0)
	Darken(SlidingActionBarTexture1)

	for i = 1, NUM_PET_ACTION_SLOTS do
		local btn = _G["PetActionButton" .. i]
		if btn then
			Darken(btn:GetNormalTexture())
		end
	end

	for i = 1, NUM_STANCE_SLOTS do
		local btn = _G["StanceButton" .. i]
		if btn then Darken(btn:GetNormalTexture()) end
	end

	for i = 0, 3 do
		DarkenHook(_G["CharacterBag" .. i .. "SlotNormalTexture"])
	end
	DarkenHook(MainMenuBarBackpackButtonNormalTexture)

	DarkenRegions(ActionBarUpButton, SECONDARY, false)
	DarkenRegions(ActionBarDownButton, SECONDARY, false)

	if MICRO_BUTTONS then
		for _, btnName in ipairs(MICRO_BUTTONS) do
			DarkenRegions(_G[btnName], SECONDARY, false)
		end
	end

	DarkenRegions(KeyRingButton, SECONDARY, false)
end

local function DarkenLibDBIcon()
	local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
	if not LDBIcon then return end
	for _, name in ipairs(LDBIcon:GetButtonList()) do
		local button = LDBIcon:GetMinimapButton(name)
		if button and button.border then
			Darken(button.border)
		end
	end
	if not ldbIconHooked then
		ldbIconHooked = true
		LDBIcon.RegisterCallback(addon, "LibDBIcon_IconCreated", function(_, button)
			if button.border then Darken(button.border) end
		end)
	end
end

-- These two live in load-on-demand Blizzard addons, so they're darkened both at setup (if already
-- loaded) and from the ADDON_LOADED handler below.
local function DarkenLFGBorder()
	if LFGMinimapFrameBorder then Darken(LFGMinimapFrameBorder) end
end

local function DarkenClock()
	if TimeManagerClockButton then DarkenRegions(TimeManagerClockButton) end
end

local function DarkenMinimap()
	Darken(MinimapBorder)
	Darken(MinimapBorderTop)
	Darken(MiniMapTrackingBorder)
	DarkenRegions(MinimapZoomIn, SECONDARY, false)
	DarkenRegions(MinimapZoomOut, SECONDARY, false)
	if GameTimeFrame then DarkenRegions(GameTimeFrame, SECONDARY, false) end
	DarkenLFGBorder()
	DarkenClock()
	DarkenLibDBIcon()
end

local function DarkenMinimapAddons(_, _, loadedAddon)
	if loadedAddon == "Blizzard_GroupFinder_VanillaStyle" then
		DarkenLFGBorder()
	elseif loadedAddon == "Blizzard_TimeManager" then
		DarkenClock()
	end
	DarkenLibDBIcon()
end

local function DarkenChat()
	for _, region in pairs({ ChatFrame1EditBox:GetRegions() }) do
		if region:GetName() then
			Darken(region)
		end
	end

	for i = 1, NUM_CHAT_WINDOWS do
		local tab = _G["ChatFrame" .. i .. "Tab"]
		if tab then
			for _, region in pairs({ tab:GetRegions() }) do
				local name = region:GetName()
				if name and not name:match("Highlight") and not name:match("Glow") then
					Darken(region)
				end
			end
		end
	end
end

local function DarkenNameplate(_, unit)
	local plate = C_NamePlate.GetNamePlateForUnit(unit)
	if not plate then return end
	local healthBar = plate.UnitFrame and plate.UnitFrame.healthBar
	local border = healthBar and healthBar.border
	if not border then return end
	for _, region in pairs({ border:GetRegions() }) do
		if region:IsObjectType("Texture") then
			DarkenHook(region)
		end
	end

	local selectionHighlight = plate.UnitFrame.selectionHighlight
	if selectionHighlight then
		selectionHighlight:SetDrawLayer("BORDER", 1)
	end
end

local function DarkenNameplates()
	if not NamePlateDriverFrame then return end
	if not nameplateHooked then
		nameplateHooked = true
		hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded", DarkenNameplate)
	end
	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		if plate.UnitFrame and plate.UnitFrame.unit then
			DarkenNameplate(nil, plate.UnitFrame.unit)
		end
	end
end

-- Reload-gated; called once from Init's PLAYER_ENTERING_WORLD pass (nameplates / compact-raid frames
-- exist there), so the SetVertexColor hooks are installed exactly once.
function addon.SetupDarkMode()
	if not cfFramesDB.DarkMode then return end

	DarkenFrames()
	-- Desaturate the target frame art except for elite targets; re-evaluated on every target change.
	DarkenTargetFrameTexture()  -- catch a target already present at setup (e.g. after /reload)
	hooksecurefunc("TargetFrame_CheckClassification", DarkenTargetFrameTexture)
	DarkenCastbars()
	DarkenActionBars()
	DarkenMinimap()
	DarkenChat()
	DarkenNameplates()

	-- Catch minimap-button addons that load on demand after us.
	if not lodFrame then
		lodFrame = CreateFrame("Frame")
		lodFrame:RegisterEvent("ADDON_LOADED")
		lodFrame:SetScript("OnEvent", DarkenMinimapAddons)
	end
end
