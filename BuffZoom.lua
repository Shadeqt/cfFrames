local M = cfFrames.MODULES

local BORDER_COLOR = 0.3
local ZOOM = { 0.05, 0.95, 0.05, 0.95 }
local DEFAULT_COORDS = { 0, 1, 0, 1 }

local function GetIcon(button)
	if not button then return nil end
	return button.icon or button.Icon or (button.GetName and button:GetName() and _G[button:GetName() .. "Icon"])
end

local function ZoomIcon(button, coords)
	local icon = GetIcon(button)
	if icon then icon:SetTexCoord(unpack(coords)) end
end

local function CreateBuffBorder(button)
	if button.cfBuffBorder then return button.cfBuffBorder end
	local icon = GetIcon(button)
	if not icon then return nil end
	local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
	border:SetBackdrop({ edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 8.5 })
	border:SetPoint("TOPLEFT", icon, -1.5, 1.5)
	border:SetPoint("BOTTOMRIGHT", icon, 1.5, -2)
	border:SetBackdropBorderColor(BORDER_COLOR, BORDER_COLOR, BORDER_COLOR)
	border:SetFrameLevel(button:GetFrameLevel() + 2)
	button.cfBuffBorder = border
	return border
end

local function DarkenBuffBorder(button)
	if not button then return end
	local name = button:GetName()
	-- Skip debuffs — preserve DebuffTypeColor
	if name and name:match("Debuff") then return end
	-- If button has a native border, darken it
	local nativeBorder = name and _G[name .. "Border"]
	if nativeBorder then
		nativeBorder:SetVertexColor(BORDER_COLOR, BORDER_COLOR, BORDER_COLOR)
		nativeBorder:SetDesaturated(true)
		return
	end
	local border = CreateBuffBorder(button)
	if border then
		border:Show()
	end
end

local function ApplyZoom(button)
	if not button then return end
	DarkenBuffBorder(button)
	ZoomIcon(button, ZOOM)
end

-- Hook player buff/debuff updates
if AuraButton_Update then
	hooksecurefunc("AuraButton_Update", function(buttonName, index)
		if not cfFramesDB[M.BUFF_ZOOM] then return end
		local button = _G[buttonName .. index]
		if button then ApplyZoom(button) end
	end)
end

-- Hook target and pet aura updates
if TargetFrame_UpdateAuras then
	hooksecurefunc("TargetFrame_UpdateAuras", function()
		if not cfFramesDB or not cfFramesDB[M.BUFF_ZOOM] then return end
		for i = 1, MAX_TARGET_BUFFS do
			local btn = _G["TargetFrameBuff" .. i]
			if btn and btn:IsShown() then ApplyZoom(btn) end
		end
		for i = 1, 16 do
			local btn = _G["PetFrameBuff" .. i]
			if btn and btn:IsShown() then ApplyZoom(btn) end
		end
	end)
end

local function RestoreButton(button)
	if not button then return end
	-- Restore zoom
	ZoomIcon(button, DEFAULT_COORDS)
	-- Hide custom border
	if button.cfBuffBorder then button.cfBuffBorder:Hide() end
	-- Restore native border color
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
	for i = 1, BUFF_MAX_DISPLAY do
		fn(_G["BuffButton" .. i])
	end
	for i = 1, DEBUFF_MAX_DISPLAY do
		fn(_G["DebuffButton" .. i])
	end
	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		fn(_G["TempEnchant" .. i])
	end
	for i = 1, MAX_TARGET_BUFFS do
		fn(_G["TargetFrameBuff" .. i])
	end
	for i = 1, MAX_TARGET_DEBUFFS do
		fn(_G["TargetFrameDebuff" .. i])
	end
	for i = 1, 16 do
		fn(_G["PetFrameBuff" .. i])
	end
end

local function Enable()
	ForEachAuraButton(ApplyZoom)
end

local function Disable()
	ForEachAuraButton(RestoreButton)
end

cfFrames:RegisterModule(M.BUFF_ZOOM, Enable, Disable)
