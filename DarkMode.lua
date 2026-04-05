local originalState = {}
local compactHooked = false
local nameplateHooked = false
local ldbIconHooked = false
local lodFrame = nil

local function ApplyDark(texture, color, desaturate, alpha)
	local c = color or cfFramesDB.DarkModeColor
	local d = desaturate ~= false
	local _, _, _, a = texture:GetVertexColor()
	texture:SetVertexColor(c, c, c, alpha or a, cff.SENTINEL)
	texture:SetDesaturated(d)
end

local function SaveAndDarken(texture, color, desaturate, alpha)
	if not texture then return end
	if not texture:IsObjectType("Texture") then return end

	if not originalState[texture] then
		local r, g, b, a = texture:GetVertexColor()
		local d = texture:IsDesaturated()
		originalState[texture] = { r = r, g = g, b = b, a = a, d = d }
	end

	ApplyDark(texture, color, desaturate, alpha)
end

local function SaveAndDarkenRegions(frame, color, desaturate, alpha)
	if not frame then return end
	for _, region in pairs({ frame:GetRegions() }) do
		SaveAndDarken(region, color, desaturate, alpha)
	end
end

local function SaveAndDarkenHook(texture, dbKey)
	if not texture then return end
	SaveAndDarken(texture)
	if texture.cffHooked then return end
	texture.cffHooked = true
	hooksecurefunc(texture, "SetVertexColor", function(self, _, _, _, _, flag)
		if flag == cff.SENTINEL then return end
		if not cfFramesDB.DarkMode then return end
		if dbKey and not cfFramesDB[dbKey] then return end
		ApplyDark(self)
	end)
end

local function IsMainBarTexture(texture)
	local name = texture:GetName()
	return name and name:match("^ActionButton%d+NormalTexture$")
end

local function Restore(texture)
	if not texture then return end
	local s = originalState[texture]
	if not s then return end

	local a = IsMainBarTexture(texture) and 0.5 or s.a
	texture:SetVertexColor(s.r, s.g, s.b, a, cff.SENTINEL)
	texture:SetDesaturated(s.d)
	originalState[texture] = nil
end

local function DarkenCompactMember(member)
	if not member then return end
	for _, region in pairs({ member:GetRegions() }) do
		local name = region:GetName()
		if name and (name:find("Border") or name:find("Divider") or name:find("Background")) then
			SaveAndDarken(region)
		end
	end
	SaveAndDarken(member.horizDivider)
	SaveAndDarken(member.horizTopBorder)
	SaveAndDarken(member.horizBottomBorder)
	SaveAndDarken(member.vertLeftBorder)
	SaveAndDarken(member.vertRightBorder)
end

local function DarkenCompactFrames()
	SaveAndDarkenRegions(CompactPartyFrameBorderFrame)
	SaveAndDarkenRegions(CompactRaidFrameContainerBorderFrame)
	for m = 1, 5 do
		DarkenCompactMember(_G["CompactPartyFrameMember" .. m])
		DarkenCompactMember(_G["CompactRaidFrame" .. m])
	end
	for g = 1, NUM_RAID_GROUPS do
		SaveAndDarkenRegions(_G["CompactRaidGroup" .. g .. "BorderFrame"])
		for m = 1, 5 do
			DarkenCompactMember(_G["CompactRaidGroup" .. g .. "Member" .. m])
		end
	end
end

local function DarkenFrames()
	SaveAndDarken(PlayerFrameTexture)
	SaveAndDarken(TargetFrameTextureFrameTexture)
	SaveAndDarken(TargetFrameToTTextureFrameTexture)
	SaveAndDarken(PetFrameTexture)
	for i = 1, 4 do
		SaveAndDarken(_G["PartyMemberFrame" .. i .. "Texture"])
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
	local sc = cfFramesDB.DarkModeColorSecondary
	for i = 0, 3 do
		SaveAndDarken(_G["MainMenuXPBarTexture" .. i])
		SaveAndDarken(_G["MainMenuBarTexture" .. i])
		SaveAndDarken(_G["MainMenuMaxLevelBar" .. i])
		if ReputationWatchBar and ReputationWatchBar.StatusBar then
			SaveAndDarken(ReputationWatchBar.StatusBar["WatchBarTexture" .. i])
			SaveAndDarken(ReputationWatchBar.StatusBar["XPBarTexture" .. i])
		end
	end

	SaveAndDarken(MainMenuBarLeftEndCap)
	SaveAndDarken(MainMenuBarRightEndCap)
	SaveAndDarken(ExhaustionTickNormal, sc, false)
	SaveAndDarken(ExhaustionTickHighlight, sc, false)

	local barNames = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton", "MultiBarLeftButton" }
	for _, barName in ipairs(barNames) do
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			local btn = _G[barName .. i]
			if btn then
				SaveAndDarkenHook(btn:GetNormalTexture(), "DarkModeActionBars")
			end
		end
	end

	for i = 1, NUM_PET_ACTION_SLOTS do
		local btn = _G["PetActionButton" .. i]
		if btn then SaveAndDarken(btn:GetNormalTexture()) end
	end

	for i = 1, NUM_STANCE_SLOTS do
		local btn = _G["StanceButton" .. i]
		if btn then SaveAndDarken(btn:GetNormalTexture()) end
	end

	for i = 0, 3 do
		SaveAndDarkenHook(_G["CharacterBag" .. i .. "SlotNormalTexture"], "DarkModeActionBars")
	end
	SaveAndDarkenHook(MainMenuBarBackpackButtonNormalTexture, "DarkModeActionBars")

	SaveAndDarkenRegions(ActionBarUpButton, sc, false)
	SaveAndDarkenRegions(ActionBarDownButton, sc, false)

	if MICRO_BUTTONS then
		for _, btnName in ipairs(MICRO_BUTTONS) do
			SaveAndDarkenRegions(_G[btnName], sc, false)
		end
	end

	SaveAndDarkenRegions(KeyRingButton, sc, false)
end

local function DarkenLibDBIcon()
	local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
	if not LDBIcon then return end
	for _, name in ipairs(LDBIcon:GetButtonList()) do
		local button = LDBIcon:GetMinimapButton(name)
		if button and button.border then
			SaveAndDarken(button.border)
		end
	end
	if not ldbIconHooked then
		ldbIconHooked = true
		LDBIcon.RegisterCallback(cff, "LibDBIcon_IconCreated", function(_, button)
			if not cfFramesDB.DarkMode then return end
			if button.border then SaveAndDarken(button.border) end
		end)
	end
end

local function DarkenMinimap()
	local sc = cfFramesDB.DarkModeColorSecondary
	SaveAndDarken(MinimapBorder)
	SaveAndDarken(MinimapBorderTop)
	SaveAndDarken(MiniMapTrackingBorder)
	SaveAndDarkenRegions(MinimapZoomIn, sc, false)
	SaveAndDarkenRegions(MinimapZoomOut, sc, false)
	if GameTimeFrame then SaveAndDarkenRegions(GameTimeFrame, sc, false) end
	if LFGMinimapFrameBorder then SaveAndDarken(LFGMinimapFrameBorder) end
	if TimeManagerClockButton then SaveAndDarkenRegions(TimeManagerClockButton) end
	DarkenLibDBIcon()
end

local function DarkenMinimapAddons(_, _, addon)
	if addon == "Blizzard_GroupFinder_VanillaStyle" then
		SaveAndDarken(LFGMinimapFrameBorder)
	elseif addon == "Blizzard_TimeManager" then
		SaveAndDarkenRegions(TimeManagerClockButton)
	end
	DarkenLibDBIcon()
end

local function DarkenChat()
	for _, region in pairs({ ChatFrame1EditBox:GetRegions() }) do
		if region:GetName() then
			SaveAndDarken(region)
		end
	end

	for i = 1, NUM_CHAT_WINDOWS do
		local tab = _G["ChatFrame" .. i .. "Tab"]
		if tab then
			for _, region in pairs({ tab:GetRegions() }) do
				local name = region:GetName()
				if name and not name:match("Highlight") and not name:match("Glow") then
					SaveAndDarken(region)
				end
			end
		end
	end
end

local function DarkenCastbars()
	if TargetFrameSpellBar and TargetFrameSpellBar.Border then
		SaveAndDarken(TargetFrameSpellBar.Border)
	end
	if CastingBarFrame and CastingBarFrame.Border then
		SaveAndDarken(CastingBarFrame.Border)
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
			if not region.cffHooked then
				region.cffHooked = true
				SaveAndDarkenHook(region, "DarkModeNameplates")
			else
				SaveAndDarken(region)
			end
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

function cff.EnableDarkMode()
	if not cfFramesDB.DarkMode then return end
	if cfFramesDB.DarkModeFrames then DarkenFrames() end
	if cfFramesDB.DarkModeActionBars then DarkenActionBars() end
	if cfFramesDB.DarkModeMinimap then
		DarkenMinimap()
		if not lodFrame then
			lodFrame = CreateFrame("Frame")
			lodFrame:RegisterEvent("ADDON_LOADED")
			lodFrame:SetScript("OnEvent", function(...)
				if not cfFramesDB.DarkMode or not cfFramesDB.DarkModeMinimap then return end
				DarkenMinimapAddons(...)
			end)
		end
	end
	if cfFramesDB.DarkModeChat then DarkenChat() end
	if cfFramesDB.DarkModeCastbars then DarkenCastbars() end
	if cfFramesDB.DarkModeNameplates then DarkenNameplates() end
end

function cff.DisableDarkMode()
	for texture in pairs(originalState) do
		Restore(texture)
	end
end
