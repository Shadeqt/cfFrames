local _, addon = ...

-- Hardcoded darkness (the old DarkModeColor / DarkModeColorSecondary sliders, locked).
local PRIMARY = 0.25    -- main frames, borders, action bars, chat, nameplate borders
local SECONDARY = 0.75  -- small borderless elements (exhaustion, scroll/micro/keyring/zoom, clock)

local compactHooked = false
local nameplateHooked = false
local ldbIconHooked = false
local lodFrame = nil

local function ApplyDark(texture, color, desaturate, alpha)
	local c = color or PRIMARY
	local d = desaturate ~= false
	local _, _, _, a = texture:GetVertexColor()
	texture:SetVertexColor(c, c, c, alpha or a, addon.SENTINEL)
	texture:SetDesaturated(d)
end

-- Off is reload-gated, so no save-original/restore path is kept. Darkening sets an absolute color,
-- so it is idempotent and safe to re-run from the SetVertexColor hooks.
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

-- Darken now, then re-darken whenever Blizzard repaints the texture. The hook skips its own writes
-- (SENTINEL) so DarkMode and ActionBarAlphaFix don't ping-pong on the shared ActionButton textures.
local function DarkenHook(texture)
	if not texture then return end
	Darken(texture)
	if texture.cffHooked then return end
	texture.cffHooked = true
	hooksecurefunc(texture, "SetVertexColor", function(self, _, _, _, _, flag)
		if flag == addon.SENTINEL then return end
		ApplyDark(self)
	end)
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
		DarkenCompactMember(_G["CompactRaidFrame" .. m])
	end
	for g = 1, NUM_RAID_GROUPS do
		DarkenRegions(_G["CompactRaidGroup" .. g .. "BorderFrame"])
		for m = 1, MEMBERS_PER_RAID_GROUP do
			DarkenCompactMember(_G["CompactRaidGroup" .. g .. "Member" .. m])
		end
	end
end

local function DarkenFrames()
	Darken(PlayerFrameTexture)
	Darken(TargetFrameTextureFrameTexture)
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

	local barNames = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton", "MultiBarLeftButton" }
	for _, barName in ipairs(barNames) do
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			local btn = _G[barName .. i]
			if btn then
				DarkenHook(btn:GetNormalTexture())
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

local function DarkenMinimap()
	Darken(MinimapBorder)
	Darken(MinimapBorderTop)
	Darken(MiniMapTrackingBorder)
	DarkenRegions(MinimapZoomIn, SECONDARY, false)
	DarkenRegions(MinimapZoomOut, SECONDARY, false)
	if GameTimeFrame then DarkenRegions(GameTimeFrame, SECONDARY, false) end
	if LFGMinimapFrameBorder then Darken(LFGMinimapFrameBorder) end
	if TimeManagerClockButton then DarkenRegions(TimeManagerClockButton) end
	DarkenLibDBIcon()
end

local function DarkenMinimapAddons(_, _, loadedAddon)
	if loadedAddon == "Blizzard_GroupFinder_VanillaStyle" then
		Darken(LFGMinimapFrameBorder)
	elseif loadedAddon == "Blizzard_TimeManager" then
		DarkenRegions(TimeManagerClockButton)
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

function addon.SetupDarkMode()
	if not cfFramesDB.DarkMode then return end

	DarkenFrames()
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
