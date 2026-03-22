local M = cfFrames.MODULES

local SIZE = 36
local DEFAULT_SIZE = 30

local function ResizeButton(button, size)
	if not button then return end
	button:SetSize(size, size)
	-- Resize native debuff border to match
	local name = button:GetName()
	if name then
		local border = _G[name .. "Border"]
		if border then
			border:SetSize(size * 1.1, size * 1.07)
		end
	end
end

-- Dark mode buff/debuff borders
local function DarkenBuffBorder(button)
	if not button then return end
	local name = button:GetName()
	-- Skip debuffs — preserve DebuffTypeColor
	if name and name:match("Debuff") then return end
	-- If button already has a native border, darken it instead of creating one
	local nativeBorder = name and _G[name .. "Border"]
	if nativeBorder then
		cfFrames.DarkenTexture(nativeBorder, cfFrames.DARK_COLOR)
		return
	end
	local border = cfFrames.CreateDarkBorder(button)
	if border then
		border:Show()
		border:SetVertexColor(cfFrames.DARK_COLOR, cfFrames.DARK_COLOR, cfFrames.DARK_COLOR)
	end
end

-- Hook player buff/debuff updates — catches all current and future buttons
if AuraButton_Update then
	hooksecurefunc("AuraButton_Update", function(buttonName, index)
		local button = _G[buttonName .. index]
		if not button then return end
		if cfFramesDB[M.BUFF_SIZE] then
			ResizeButton(button, SIZE)
		end
		if cfFramesDB[M.BUFF_SIZE] then
			DarkenBuffBorder(button)
		end
	end)
end

-- Hook target and pet aura updates
if TargetFrame_UpdateAuras then
	hooksecurefunc("TargetFrame_UpdateAuras", function()
		if not cfFramesDB or not cfFramesDB[M.BUFF_SIZE] then return end
		for i = 1, MAX_TARGET_BUFFS do
			local btn = _G["TargetFrameBuff" .. i]
			if btn and btn:IsShown() then DarkenBuffBorder(btn) end
		end
		for i = 1, 16 do
			local btn = _G["PetFrameBuff" .. i]
			if btn and btn:IsShown() then DarkenBuffBorder(btn) end
		end
	end)
end

local function ResizeAll(size)
	BUFF_BUTTON_HEIGHT = size
	for i = 1, BUFF_MAX_DISPLAY do
		ResizeButton(_G["BuffButton" .. i], size)
	end
	for i = 1, DEBUFF_MAX_DISPLAY do
		ResizeButton(_G["DebuffButton" .. i], size)
	end
	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		ResizeButton(_G["TempEnchant" .. i], size)
	end
	if BuffFrame_UpdateAllBuffAnchors then
		BuffFrame_UpdateAllBuffAnchors()
	end
end

local function Enable()
	ResizeAll(SIZE)
	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		DarkenBuffBorder(_G["TempEnchant" .. i])
	end
end

local function Disable()
	ResizeAll(DEFAULT_SIZE)
end

cfFrames:RegisterModule(M.BUFF_SIZE, Enable, Disable)
