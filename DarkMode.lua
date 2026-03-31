local COLOR_DARK = 0.25
local COLOR_MID = 0.5
local COLOR_LIGHT = 0.75

local function DarkenTexture(texture, color, desaturate)
	if not texture then return end
	if not texture:IsObjectType("Texture") then return end
	local c = color or COLOR_DARK
	texture:SetVertexColor(c, c, c)
	if desaturate ~= false then texture:SetDesaturated(true) end
end

local function DarkenRegions(frame, color, desaturate)
	if not frame then return end
	local regions = { frame:GetRegions() }
	for _, region in ipairs(regions) do
		DarkenTexture(region, color, desaturate)
	end
end

local function DarkenTextureHook(texture, color, desaturate)
	if not texture then return end
	local c = color or COLOR_DARK
	DarkenTexture(texture, color, desaturate)
	hooksecurefunc(texture, "SetVertexColor", function(self, r, g, b)
		if r == c and g == c and b == c then return end
		self:SetVertexColor(c, c, c)
	end)
	if desaturate ~= false then
		hooksecurefunc(texture, "SetDesaturated", function(self, desat)
			if not desat then self:SetDesaturated(true) end
		end)
	end
end

local function DarkenFrames()
	-- Player, target, target-of-target
	DarkenTexture(PlayerFrameTexture)
	DarkenTexture(TargetFrameTextureFrameTexture)
	DarkenTexture(TargetFrameToTTextureFrameTexture)

	-- Pet
	DarkenTexture(PetFrameTexture)

	-- Party
	for i = 1, 4 do
		DarkenTexture(_G["PartyMemberFrame" .. i .. "Texture"])
	end
end

local function DarkenActionBars()
	-- Artwork
	for i = 0, 3 do
		DarkenTexture(_G["MainMenuXPBarTexture" .. i])
		DarkenTexture(_G["MainMenuBarTexture" .. i], COLOR_MID)
	end
	DarkenTexture(MainMenuBarLeftEndCap, COLOR_MID)
	DarkenTexture(MainMenuBarRightEndCap, COLOR_MID)
	DarkenTexture(ExhaustionTickNormal, COLOR_LIGHT)
	DarkenTexture(ExhaustionTickHighlight, COLOR_LIGHT)

	-- Action button borders
	local barNames = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton", "MultiBarLeftButton" }
	for _, barName in ipairs(barNames) do
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			local btn = _G[barName .. i]
			if btn then
				local tex = btn:GetNormalTexture()
				DarkenTextureHook(tex)
			end
		end
	end

	-- Pet action buttons
	for i = 1, NUM_PET_ACTION_SLOTS do
		local btn = _G["PetActionButton" .. i]
		if btn then
			local tex = btn:GetNormalTexture()
			DarkenTexture(tex)
		end
	end

	-- Stance buttons
	for i = 1, NUM_STANCE_SLOTS do
		local btn = _G["StanceButton" .. i]
		if btn then
			local tex = btn:GetNormalTexture()
			DarkenTexture(tex)
		end
	end

	-- Bag buttons
	for i = 0, 3 do
		local tex = _G["CharacterBag" .. i .. "SlotNormalTexture"]
		DarkenTextureHook(tex)
	end
	DarkenTextureHook(MainMenuBarBackpackButtonNormalTexture)

	-- Page buttons
	DarkenRegions(ActionBarUpButton, COLOR_LIGHT, false)
	DarkenRegions(ActionBarDownButton, COLOR_LIGHT, false)

	-- Micro buttons
	if MICRO_BUTTONS then
		for _, btnName in ipairs(MICRO_BUTTONS) do
			DarkenRegions(_G[btnName], COLOR_LIGHT, false)
		end
	end

	-- Key ring
	DarkenRegions(KeyRingButton, COLOR_LIGHT, false)
end

local function DarkenChat()
	-- Edit box border
	if ChatFrame1EditBox then
		for i = 1, ChatFrame1EditBox:GetNumRegions() do
			local region = select(i, ChatFrame1EditBox:GetRegions())
			if region:GetName() then
				DarkenTexture(region)
			end
		end
	end

	-- Tab textures
	for i = 1, NUM_CHAT_WINDOWS do
		local tab = _G["ChatFrame" .. i .. "Tab"]
		if tab then
			for j = 1, tab:GetNumRegions() do
				local region = select(j, tab:GetRegions())
				local name = region:GetName()
				if name and not name:match("Highlight") and not name:match("Glow") then
					DarkenTexture(region)
				end
			end
		end
	end
end

local function DarkenMinimap()
	-- Borders
	DarkenTexture(MinimapBorder)
	DarkenTexture(MinimapBorderTop)
	DarkenTexture(MiniMapTrackingBorder)

	-- Zoom buttons
	DarkenRegions(MinimapZoomIn, COLOR_MID)
	DarkenRegions(MinimapZoomOut, COLOR_MID)

end

local function DarkenCastbars()
	-- Target castbar
	if TargetFrameSpellBar then
		if TargetFrameSpellBar.Border then
			DarkenTexture(TargetFrameSpellBar.Border)
		end
	end

	-- Player castbar
	if CastingBarFrame and CastingBarFrame.Border then
		DarkenTexture(CastingBarFrame.Border)
	end
end

local function DarkenMinimapDeferred()
	-- Blizzard LoD addons (loaded on demand)
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnEvent", function(_, _, addon)
		if addon == "Blizzard_GroupFinder_VanillaStyle" then
			DarkenTexture(LFGMinimapFrameBorder)
		elseif addon == "Blizzard_TimeManager" then
			-- See _Docs/clock-investigation.md for full breakdown of popup frames
			DarkenTexture((TimeManagerClockButton:GetRegions()))
		end
	end)

	-- LibDBIcon minimap buttons (other addons)
	local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
	if LDBIcon then
		for _, name in ipairs(LDBIcon:GetButtonList()) do
			local button = LDBIcon:GetMinimapButton(name)
			if button then
				local border = button.border
				if border then DarkenTexture(border) end
			end
		end
		LDBIcon.RegisterCallback(cfFrames, "LibDBIcon_IconCreated", function(_, button)
			local border = button.border
			if border then DarkenTexture(border) end
		end)
	end
end

local function DarkenCompactMember(member)
	if not member then return end
	for i = 1, member:GetNumRegions() do
		local region = select(i, member:GetRegions())
		local name = region:GetName()
		if name and (name:find("Border") or name:find("Divider") or name:find("Background")) then
			DarkenTexture(region)
		end
	end
end

local function DarkenCompactFrameLayout()
	-- Party border frame and member borders
	DarkenRegions(CompactPartyFrameBorderFrame)
	for m = 1, 5 do
		DarkenCompactMember(_G["CompactPartyFrameMember" .. m])
	end

	-- Raid group borders and member borders
	for g = 1, NUM_RAID_GROUPS do
		DarkenRegions(_G["CompactRaidGroup" .. g .. "BorderFrame"])
		for m = 1, 5 do
			DarkenCompactMember(_G["CompactRaidGroup" .. g .. "Member" .. m])
		end
	end
end

local function DarkenCompactFrames()
	if CompactRaidFrameContainer_LayoutFrames then
		hooksecurefunc("CompactRaidFrameContainer_LayoutFrames", DarkenCompactFrameLayout)
	end
end

local function DarkenNameplate(_, unit)
	local plate = C_NamePlate.GetNamePlateForUnit(unit)
	if not plate then return end
	local healthBar = plate.UnitFrame and plate.UnitFrame.healthBar
	local border = healthBar and healthBar.border
	if not border then return end
	local regions = { border:GetRegions() }
	for _, region in ipairs(regions) do
		if region:IsObjectType("Texture") then
			if not region.cfDarkHooked then
				region.cfDarkHooked = true
				DarkenTextureHook(region, COLOR_MID)
			else
				DarkenTexture(region, COLOR_MID)
			end
		end
	end

	-- Move selectionHighlight below the border (ARTWORK)
	local selectionHighlight = plate.UnitFrame.selectionHighlight
	if selectionHighlight then
		selectionHighlight:SetDrawLayer("BORDER", 1)
	end

end

local function DarkenNameplates()
	if not NamePlateDriverFrame then return end
	hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded", DarkenNameplate)
end


function cfFrames.initDarkMode()
	DarkenFrames()
	DarkenActionBars()
	DarkenChat()
	DarkenCastbars()
	DarkenMinimap()
	DarkenMinimapDeferred()
	DarkenCompactFrames()
	DarkenNameplates()

	-- Register styles so other features can request darkening without importing DarkMode
	cfFrames.registerTextureStyle(DarkenTexture)
	cfFrames.registerRegionStyle(DarkenRegions)
end
