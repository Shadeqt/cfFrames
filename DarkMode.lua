local M = cfFrames.MODULES

local COLOR = 0.3
local COLOR_LIGHT = 0.6

cfFrames.DARK_COLOR = COLOR

local darkenedTextures = {}
local createdTextures = {}

-- Darken an existing Blizzard texture (restored to white on Disable)
local function DarkenTexture(texture, color, noDesaturate)
	if not texture then return end
	if not texture:IsObjectType("Texture") then return end
	local name = texture:GetName()
	if name and name:match("Bg$") then return end
	if name and name:match("Portrait$") then return end
	texture:SetVertexColor(color, color, color)
	if not noDesaturate then texture:SetDesaturated(true) end
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
	texture:SetDesaturated(false)
	texture.cfDarkChanging = false
end

-- Track a texture we created (hidden on Disable, shown on Enable)
local function TrackCreatedTexture(texture)
	table.insert(createdTextures, texture)
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
	-- ExhaustionTickNormal,
	-- ExhaustionTickHighlight,
}

local XPBAR_ARTWORK = {
	MainMenuXPBarTexture0,
	MainMenuXPBarTexture1,
	MainMenuXPBarTexture2,
	MainMenuXPBarTexture3,
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

	-- Artwork (bar segments, gryphons)
	for _, tex in ipairs(ACTIONBAR_ARTWORK) do
		DarkenTexture(tex, COLOR_LIGHT)
	end

	-- XP bar borders
	for _, tex in ipairs(XPBAR_ARTWORK) do
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
					DarkenTexture(select(i, btn:GetRegions()), COLOR_LIGHT, true)
				end
			end
		end
	end
	if KeyRingButton then
		for i = 1, KeyRingButton:GetNumRegions() do
			DarkenTexture(select(i, KeyRingButton:GetRegions()), COLOR_LIGHT, true)
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

-- Raid Frames
local raidEventFrame = CreateFrame("Frame")

local function DarkenRaidFrames()
	for g = 1, NUM_RAID_GROUPS do
		local group = _G["CompactRaidGroup" .. g .. "BorderFrame"]
		if group then
			for _, region in pairs({group:GetRegions()}) do
				if region:IsObjectType("Texture") then
					DarkenTexture(region, COLOR)
				end
			end
		end

		for m = 1, 5 do
			local member = _G["CompactRaidGroup" .. g .. "Member" .. m]
			if member then
				for _, region in pairs({member:GetRegions()}) do
					local name = region:GetName()
					if name and name:find("Border") then
						DarkenTexture(region, COLOR)
					end
				end
			end
		end
	end

	for i = 1, 40 do
		local frame = _G["CompactRaidFrame" .. i]
		if frame then
			for _, region in pairs({frame:GetRegions()}) do
				local name = region:GetName()
				if name and name:find("Border") then
					DarkenTexture(region, COLOR)
				end
			end
		end
	end

	if CompactRaidFrameContainerBorderFrame then
		for _, region in pairs({CompactRaidFrameContainerBorderFrame:GetRegions()}) do
			if region:IsObjectType("Texture") then
				DarkenTexture(region, COLOR)
			end
		end
	end
end

raidEventFrame:SetScript("OnEvent", function()
	if not cfFramesDB or not cfFramesDB[M.DARK_MODE] then return end
	DarkenRaidFrames()
end)

-- Nameplates
local nameplateEventFrame = CreateFrame("Frame")

local function DarkenNameplate(nameplate)
	local uf = nameplate.UnitFrame
	local healthBar = uf and uf.healthBar
	if not healthBar or not healthBar.border then return end

	for _, region in pairs({healthBar.border:GetRegions()}) do
		DarkenTexture(region, COLOR)
	end
end

nameplateEventFrame:SetScript("OnEvent", function(_, _, unit)
	if not cfFramesDB or not cfFramesDB[M.DARK_MODE] then return end
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	if nameplate then DarkenNameplate(nameplate) end
end)

-- Icon border (used for buff icons, castbar icons, etc.)
local function GetIcon(button)
	if not button then return nil end
	return button.icon or button.Icon or (button.GetName and button:GetName() and _G[button:GetName() .. "Icon"])
end

-- Castbar icon border
local function CreateDarkIconBorder(parent, icon)
	if parent.cfDarkBorder then return parent.cfDarkBorder end
	if not icon then return nil end
	local border = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	border:SetBackdrop({ edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8.5 })
	border:SetPoint("TOPLEFT", icon, -1.5, 1.5)
	border:SetPoint("BOTTOMRIGHT", icon, 1.5, -2)
	border:SetBackdropBorderColor(COLOR, COLOR, COLOR)
	parent.cfDarkBorder = border
	TrackCreatedTexture(border)
	return border
end
cfFrames.DarkenTexture = DarkenTexture
cfFrames.CreateDarkIconBorder = CreateDarkIconBorder

-- Buff/aura borders
local function DarkenAuraButton(button)
	if not button then return end
	local name = button:GetName()
	-- Skip debuffs — preserve DebuffTypeColor
	if name and name:match("Debuff") then return end
	-- If button has a native border, darken it
	local nativeBorder = name and _G[name .. "Border"]
	if nativeBorder then
		nativeBorder:SetVertexColor(COLOR, COLOR, COLOR)
		nativeBorder:SetDesaturated(true)
		return
	end
	-- Otherwise create a dark border frame
	local icon = GetIcon(button)
	if icon then CreateDarkIconBorder(button, icon) end
end

local function RestoreAuraButton(button)
	if not button then return end
	if button.cfDarkBorder then button.cfDarkBorder:Hide() end
	local name = button:GetName()
	if name then
		local nativeBorder = _G[name .. "Border"]
		if nativeBorder then
			nativeBorder:SetVertexColor(1, 1, 1)
			nativeBorder:SetDesaturated(false)
		end
	end
end

local function ForEachAuraButton(fn)
	for i = 1, BUFF_MAX_DISPLAY do fn(_G["BuffButton" .. i]) end
	for i = 1, DEBUFF_MAX_DISPLAY do fn(_G["DebuffButton" .. i]) end
	for i = 1, NUM_TEMP_ENCHANT_FRAMES do fn(_G["TempEnchant" .. i]) end
	for i = 1, MAX_TARGET_BUFFS do fn(_G["TargetFrameBuff" .. i]) end
	for i = 1, MAX_TARGET_DEBUFFS do fn(_G["TargetFrameDebuff" .. i]) end
	for i = 1, 16 do fn(_G["PetFrameBuff" .. i]) end
end

if AuraButton_Update then
	hooksecurefunc("AuraButton_Update", function(buttonName, index)
		if not cfFramesDB[M.DARK_MODE] then return end
		local button = _G[buttonName .. index]
		if button then DarkenAuraButton(button) end
	end)
end

if TargetFrame_UpdateAuras then
	hooksecurefunc("TargetFrame_UpdateAuras", function()
		if not cfFramesDB or not cfFramesDB[M.DARK_MODE] then return end
		for i = 1, MAX_TARGET_BUFFS do
			local btn = _G["TargetFrameBuff" .. i]
			if btn and btn:IsShown() then DarkenAuraButton(btn) end
		end
		for i = 1, 16 do
			local btn = _G["PetFrameBuff" .. i]
			if btn and btn:IsShown() then DarkenAuraButton(btn) end
		end
	end)
end

-- Chat Editbox
local function DarkenChatEditbox()
	local editbox = ChatFrame1EditBox
	if not editbox then return end
	for i = 1, editbox:GetNumRegions() do
		local region = select(i, editbox:GetRegions())
		if region:GetName() then
			DarkenTexture(region, COLOR)
		end
	end
	for i = 1, NUM_CHAT_WINDOWS do
		local tab = _G["ChatFrame" .. i .. "Tab"]
		if tab then
			for j = 1, tab:GetNumRegions() do
				local region = select(j, tab:GetRegions())
				local name = region:GetName()
				if name and not name:match("Highlight") and not name:match("Glow") then
					DarkenTexture(region, COLOR)
				end
			end
		end
	end
end

-- Castbars
local function DarkenCastbars()
	if TargetFrameSpellBar and TargetFrameSpellBar.Border then
		DarkenTexture(TargetFrameSpellBar.Border, COLOR)
		TargetFrameSpellBar:HookScript("OnShow", function(self)
			if not cfFramesDB or not cfFramesDB[M.DARK_MODE] then return end
			CreateDarkIconBorder(self, self.Icon)
		end)
	end
	if CastingBarFrame and CastingBarFrame.Border then
		DarkenTexture(CastingBarFrame.Border, COLOR)
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
	DarkenRaidFrames()
	DarkenChatEditbox()
	DarkenCastbars()
	ForEachAuraButton(DarkenAuraButton)
	raidEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
	nameplateEventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
		DarkenNameplate(nameplate)
	end
	-- Re-show all created borders/textures
	for _, obj in ipairs(createdTextures) do
		obj:Show()
		if obj.SetBackdropBorderColor then
			obj:SetBackdropBorderColor(COLOR, COLOR, COLOR)
		elseif obj.SetVertexColor then
			obj:SetVertexColor(COLOR, COLOR, COLOR)
		end
	end
end

local function Disable()
	raidEventFrame:UnregisterAllEvents()
	nameplateEventFrame:UnregisterAllEvents()
	for _, tex in ipairs(darkenedTextures) do
		RestoreTexture(tex)
	end
	for _, tex in ipairs(createdTextures) do
		tex:Hide()
	end
	ForEachAuraButton(RestoreAuraButton)
end

cfFrames:RegisterModule(M.DARK_MODE, Enable, Disable)
