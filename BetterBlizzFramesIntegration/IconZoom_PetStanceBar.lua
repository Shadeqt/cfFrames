local M = cfFrames.MODULES

local function ZoomIcons(enable)
	local coord = enable and 0.08 or 0
	local coordEnd = enable and 0.92 or 1

	for i = 1, 10 do
		local pet = _G["PetActionButton" .. i]
		local icon = pet and (pet.Icon or pet.icon or _G["PetActionButton" .. i .. "Icon"])
		if icon and icon.SetTexCoord then
			icon:SetTexCoord(coord, coordEnd, coord, coordEnd)
		end
	end
	for i = 1, 12 do
		local stance = _G["StanceButton" .. i]
		local icon = stance and (stance.Icon or stance.icon or _G["StanceButton" .. i .. "Icon"])
		if icon and icon.SetTexCoord then
			icon:SetTexCoord(coord, coordEnd, coord, coordEnd)
		end
	end
end

local function Enable()
	local ocdEnabled = BetterBlizzFramesDB.playerFrameOCD and BetterBlizzFramesDB.playerFrameOCDZoom
	ZoomIcons(ocdEnabled or BetterBlizzFramesDB.zoomActionBarIcons)

	if BBF and BBF.ActionBarIconZoom then
		hooksecurefunc(BBF, "ActionBarIconZoom", function()
			if not cfFramesDB[M.BBF_INTEGRATION] then return end
			local enabled = BetterBlizzFramesDB.playerFrameOCD and BetterBlizzFramesDB.playerFrameOCDZoom
			ZoomIcons(enabled)
		end)
	end

	if BBF and BBF.ZoomDefaultActionbarIcons then
		hooksecurefunc(BBF, "ZoomDefaultActionbarIcons", function()
			if not cfFramesDB[M.BBF_INTEGRATION] then return end
			ZoomIcons(BetterBlizzFramesDB.zoomActionBarIcons)
		end)
	end
end

local function Disable()
	ZoomIcons(false)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
	if arg1 ~= "cfFrames" and arg1 ~= "BetterBlizzFrames" then return end
	if not cfFramesDB or not BetterBlizzFramesDB then return end

	self:UnregisterEvent("ADDON_LOADED")
	cfFrames:RegisterModule(M.BBF_INTEGRATION, Enable, Disable)
	if cfFramesDB[M.BBF_INTEGRATION] then
		Enable()
	end
end)
