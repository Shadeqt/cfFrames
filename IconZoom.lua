local M = cfFrames.MODULES

local ZOOM = { 0.07, 0.93, 0.07, 0.93 }
local DEFAULT = { 0, 1, 0, 1 }

cfFrames.ICON_ZOOM_COORDS = ZOOM

local ACTION_BAR_PREFIXES = {
	"ActionButton",
	"MultiBarBottomLeftButton",
	"MultiBarBottomRightButton",
	"MultiBarRightButton",
	"MultiBarLeftButton",
}

local function GetIcon(button)
	if not button then return nil end
	return button.icon or button.Icon or (button.GetName and button:GetName() and _G[button:GetName() .. "Icon"])
end

local function ZoomActionBars(coords)
	for _, prefix in ipairs(ACTION_BAR_PREFIXES) do
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			local icon = GetIcon(_G[prefix .. i])
			if icon then icon:SetTexCoord(unpack(coords)) end
		end
	end
end

local function ZoomPetBar(coords)
	for i = 1, NUM_PET_ACTION_SLOTS do
		local icon = GetIcon(_G["PetActionButton" .. i])
		if icon then icon:SetTexCoord(unpack(coords)) end
	end
end

-- Persist zoom when icons change
hooksecurefunc("ActionButton_Update", function(self)
	if not cfFramesDB[M.ICON_ZOOM] then return end
	local icon = GetIcon(self)
	if icon then icon:SetTexCoord(unpack(ZOOM)) end
end)

if PetActionBar_Update then
	hooksecurefunc("PetActionBar_Update", function()
		if not cfFramesDB[M.ICON_ZOOM] then return end
		ZoomPetBar(ZOOM)
	end)
end

-- Buff/aura icon zoom
local function ZoomAuraIcon(button, coords)
	local icon = GetIcon(button)
	if icon then icon:SetTexCoord(unpack(coords)) end
end

-- Buff/aura icon border (for buttons that lack a native border)
local function CreateIconBorder(button)
	if not button then return end
	if button.cfIconBorder then return end
	local name = button:GetName()
	-- Skip debuffs and buttons with native borders
	if name and name:match("Debuff") then return end
	if name and _G[name .. "Border"] then return end
	local icon = GetIcon(button)
	if not icon then return end
	local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
	border:SetBackdrop({ edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8.5 })
	border:SetPoint("TOPLEFT", icon, -1.5, 1.5)
	border:SetPoint("BOTTOMRIGHT", icon, 1.5, -2)
	if cfFramesDB[M.DARK_MODE] and cfFrames.DARK_COLOR then
		border:SetBackdropBorderColor(cfFrames.DARK_COLOR, cfFrames.DARK_COLOR, cfFrames.DARK_COLOR)
	else
		border:SetBackdropBorderColor(1, 1, 1)
	end
	button.cfIconBorder = border
end

local function RemoveIconBorder(button)
	if not button then return end
	if button.cfIconBorder then
		button.cfIconBorder:Hide()
		button.cfIconBorder = nil
	end
end

if AuraButton_Update then
	hooksecurefunc("AuraButton_Update", function(buttonName, index)
		if not cfFramesDB[M.ICON_ZOOM] then return end
		local button = _G[buttonName .. index]
		if button then
			ZoomAuraIcon(button, ZOOM)
			CreateIconBorder(button)
		end
	end)
end

if TargetFrame_UpdateAuras then
	hooksecurefunc("TargetFrame_UpdateAuras", function()
		if not cfFramesDB[M.ICON_ZOOM] then return end
		for i = 1, MAX_TARGET_BUFFS do
			local btn = _G["TargetFrameBuff" .. i]
			if btn and btn:IsShown() then
				ZoomAuraIcon(btn, ZOOM)
				CreateIconBorder(btn)
			end
		end
		for i = 1, 16 do
			local btn = _G["PetFrameBuff" .. i]
			if btn and btn:IsShown() then
				ZoomAuraIcon(btn, ZOOM)
				CreateIconBorder(btn)
			end
		end
	end)
end

local function ForEachAuraButton(fn)
	for i = 1, BUFF_MAX_DISPLAY do fn(_G["BuffButton" .. i]) end
	for i = 1, DEBUFF_MAX_DISPLAY do fn(_G["DebuffButton" .. i]) end
	for i = 1, NUM_TEMP_ENCHANT_FRAMES do fn(_G["TempEnchant" .. i]) end
	for i = 1, MAX_TARGET_BUFFS do fn(_G["TargetFrameBuff" .. i]) end
	for i = 1, MAX_TARGET_DEBUFFS do fn(_G["TargetFrameDebuff" .. i]) end
	for i = 1, 16 do fn(_G["PetFrameBuff" .. i]) end
end

local function ZoomAllAuras(coords)
	ForEachAuraButton(function(btn) ZoomAuraIcon(btn, coords) end)
end

local function Enable()
	ZoomActionBars(ZOOM)
	ZoomPetBar(ZOOM)
	ZoomAllAuras(ZOOM)
	ForEachAuraButton(CreateIconBorder)
end

local function Disable()
	ZoomActionBars(DEFAULT)
	ZoomPetBar(DEFAULT)
	ZoomAllAuras(DEFAULT)
	ForEachAuraButton(RemoveIconBorder)
end

cfFrames:RegisterModule(M.ICON_ZOOM, Enable, Disable)
