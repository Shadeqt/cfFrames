local M = cfFrames.MODULES

local ZOOM = { 0.075, 0.925, 0.075, 0.925 }
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
	return button.icon or button.Icon or _G[button:GetName() .. "Icon"]
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

local function Enable()
	ZoomActionBars(ZOOM)
	ZoomPetBar(ZOOM)
end

local function Disable()
	ZoomActionBars(DEFAULT)
	ZoomPetBar(DEFAULT)
end

cfFrames:RegisterModule(M.ICON_ZOOM, Enable, Disable)
