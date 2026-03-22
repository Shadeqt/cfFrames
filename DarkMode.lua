local M = cfFrames.MODULES

local COLOR = 0.25
local COLOR_LIGHT = 0.75

local darkenedTextures = {}

local function DarkenTexture(texture, color)
	if not texture then return end
	if not texture:IsObjectType("Texture") then return end
	local name = texture:GetName()
	if name and name:match("Bg$") then return end
	if name and name:match("Portrait$") then return end
	texture:SetVertexColor(color, color, color)
	table.insert(darkenedTextures, texture)

	if not texture.cfDarkHooked then
		hooksecurefunc(texture, "SetVertexColor", function(self, r, g, b)
			if self.cfDarkChanging then return end
			if not cfFramesDB[M.DARK_MODE] then return end
			if r == color and g == color and b == color then return end
			self.cfDarkChanging = true
			self:SetVertexColor(color, color, color)
			self.cfDarkChanging = false
		end)
		texture.cfDarkHooked = true
	end
end

local function RestoreTexture(texture)
	texture.cfDarkChanging = true
	texture:SetVertexColor(1, 1, 1)
	texture.cfDarkChanging = false
end

-- Unit Frames
local UNIT_FRAME_TEXTURES = {
	PlayerFrameTexture,
	TargetFrameTextureFrameTexture,
	TargetFrameToTTextureFrameTexture,
	PetFrameTexture,
	PartyMemberFrame1Texture,
	PartyMemberFrame2Texture,
	PartyMemberFrame3Texture,
	PartyMemberFrame4Texture,
}

local function DarkenUnitFrames()
	for _, tex in ipairs(UNIT_FRAME_TEXTURES) do
		DarkenTexture(tex, COLOR)
	end
end

-- Action Bar
local ACTIONBAR_ARTWORK = {
	MainMenuBarTexture0,
	MainMenuBarTexture1,
	MainMenuBarTexture2,
	MainMenuBarTexture3,
	MainMenuBarLeftEndCap,
	MainMenuBarRightEndCap,
	MainMenuXPBarTexture0,
	MainMenuXPBarTexture1,
	MainMenuXPBarTexture2,
	MainMenuXPBarTexture3,
	-- ExhaustionTickNormal,
	-- ExhaustionTickHighlight,
}

local function DarkenActionBar()
	-- Button borders
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local bu

		bu = _G["ActionButton" .. i]
		if bu then DarkenTexture(bu:GetNormalTexture(), COLOR) end

		bu = _G["MultiBarBottomLeftButton" .. i]
		if bu then DarkenTexture(bu:GetNormalTexture(), COLOR) end

		bu = _G["MultiBarBottomRightButton" .. i]
		if bu then DarkenTexture(bu:GetNormalTexture(), COLOR) end

		bu = _G["MultiBarRightButton" .. i]
		if bu then DarkenTexture(bu:GetNormalTexture(), COLOR) end

		bu = _G["MultiBarLeftButton" .. i]
		if bu then DarkenTexture(bu:GetNormalTexture(), COLOR) end
	end

	for i = 1, NUM_PET_ACTION_SLOTS do
		local bu = _G["PetActionButton" .. i]
		if bu then DarkenTexture(bu:GetNormalTexture(), COLOR) end
	end

	for i = 1, NUM_STANCE_SLOTS do
		local bu = _G["StanceButton" .. i]
		if bu then DarkenTexture(bu:GetNormalTexture(), COLOR) end
	end

	-- Artwork (bar segments, gryphons, XP bar borders)
	for _, tex in ipairs(ACTIONBAR_ARTWORK) do
		DarkenTexture(tex, COLOR)
	end

	-- Bag button borders
	for i = 0, 3 do
		DarkenTexture(_G["CharacterBag" .. i .. "SlotNormalTexture"], COLOR)
	end
	DarkenTexture(MainMenuBarBackpackButtonNormalTexture, COLOR)

	-- Testing with COLOR_LIGHT
	DarkenTexture(ExhaustionTickNormal, COLOR_LIGHT)
	DarkenTexture(ExhaustionTickHighlight, COLOR_LIGHT)

	if MICRO_BUTTONS then
		for _, btnName in ipairs(MICRO_BUTTONS) do
			local btn = _G[btnName]
			if btn then
				for i = 1, btn:GetNumRegions() do
					DarkenTexture(select(i, btn:GetRegions()), COLOR_LIGHT)
				end
			end
		end
	end
	if KeyRingButton then
		for i = 1, KeyRingButton:GetNumRegions() do
			DarkenTexture(select(i, KeyRingButton:GetRegions()), COLOR_LIGHT)
		end
	end
end

-- Minimap
local function DarkenMinimap()
	DarkenTexture(MinimapBorder, COLOR)
	DarkenTexture(MinimapBorderTop, COLOR)
	DarkenTexture(MiniMapTrackingBorder, COLOR)
end

local function DarkenMinimapDeferred()
	DarkenTexture(LFGMinimapFrameBorder, COLOR)

	-- Testing with COLOR_LIGHT (0.6)
	if MinimapZoomIn then
		for i = 1, MinimapZoomIn:GetNumRegions() do
			DarkenTexture(select(i, MinimapZoomIn:GetRegions()), COLOR_LIGHT)
		end
	end
	if MinimapZoomOut then
		for i = 1, MinimapZoomOut:GetNumRegions() do
			DarkenTexture(select(i, MinimapZoomOut:GetRegions()), COLOR_LIGHT)
		end
	end

	-- Clock button (region 1 = border only)
	if TimeManagerClockButton then
		DarkenTexture(select(1, TimeManagerClockButton:GetRegions()), COLOR)
	end

	-- TimeManager panel
	if TimeManagerFrame then
		local TMF_SKIP = {
			["TimeManagerGlobe"] = true,
		}
		for i = 1, TimeManagerFrame:GetNumRegions() do
			local region = select(i, TimeManagerFrame:GetRegions())
			if region and not TMF_SKIP[region:GetName()] then
				DarkenTexture(region, COLOR)
			end
		end

		local insetNineSlice = TimeManagerFrameInset and TimeManagerFrameInset.NineSlice
		if insetNineSlice then
			for i = 1, insetNineSlice:GetNumRegions() do
				DarkenTexture(select(i, insetNineSlice:GetRegions()), COLOR)
			end
		end
	end

	-- Stopwatch
	if StopwatchTabFrame then
		for i = 1, StopwatchTabFrame:GetNumRegions() do
			DarkenTexture(select(i, StopwatchTabFrame:GetRegions()), COLOR)
		end
	end
	if StopwatchFrame then
		for i = 1, StopwatchFrame:GetNumRegions() do
			DarkenTexture(select(i, StopwatchFrame:GetRegions()), COLOR)
		end
	end

	-- LibDBIcon minimap buttons
	for key, val in pairs(_G) do
		if type(key) == "string" and key:match("^LibDBIcon10_") and type(val) == "table" and val.border then
			DarkenTexture(val.border, COLOR)
		end
	end
end

-- Deferred loading
local deferFrame = CreateFrame("Frame")
deferFrame:RegisterEvent("ADDON_LOADED")
deferFrame:SetScript("OnEvent", function()
	if not cfFramesDB or not cfFramesDB[M.DARK_MODE] then return end
	DarkenActionBar()
	DarkenMinimapDeferred()
end)

-- Enable / Disable
local function Enable()
	DarkenUnitFrames()
	DarkenActionBar()
	DarkenMinimap()
	DarkenMinimapDeferred()
end

local function Disable()
	for _, tex in ipairs(darkenedTextures) do
		RestoreTexture(tex)
	end
end

cfFrames:RegisterModule(M.DARK_MODE, Enable, Disable)
