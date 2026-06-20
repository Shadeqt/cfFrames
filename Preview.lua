local _, addon = ...

-- /cffframe -- step the target frame through each classification border (Normal ->
-- Rare -> Rare-Elite -> Elite) so the custom art can be compared alongside the player
-- frame (which always uses the Normal art). Each call advances one step; /cffframe off
-- stops and restores. Force-shows the protected target frame, so out-of-combat only.

local forced = {}    -- frames WE force-showed (only ones hidden when we started)
local index = 0      -- 0 = not started; otherwise the current addon.frameArt slot

-- A plain :Show() doesn't stick on the unit-driven TargetFrame, so re-Show on any
-- Hide (same trick cfCastbars' /cfcb uses), and only ever touch frames that were
-- hidden when we started -- so we never "own" and later hide a live target frame.
local function ForceShow(frame)
	if not frame or frame:IsShown() then return end
	if not forced[frame] then
		hooksecurefunc(frame, "Hide", function(self)
			if forced[self] and not InCombatLockdown() then self:Show() end
		end)
		forced[frame] = true
	end
	frame:Show()
end

-- The classification art is the target frame's border region (set by cfFrames'
-- TargetFrame_CheckClassification hook); fall back to the named texture if needed.
local function BorderRegion()
	return TargetFrame.borderTexture or TargetFrameTextureFrameTexture
end

local function Stop()
	index = 0
	for frame in pairs(forced) do
		forced[frame] = nil
		if not InCombatLockdown() then frame:Hide() end
	end
	-- Put the real target's correct classification art back, if a target exists.
	if UnitExists("target") and TargetFrame_CheckClassification then
		TargetFrame_CheckClassification(TargetFrame)
	end
end

SLASH_CFFFRAME1 = "/cffframe"
SlashCmdList.CFFFRAME = function(msg)
	if InCombatLockdown() then
		print("|cff33ff99cfFrames|r: /cffframe can't toggle in combat.")
		return
	end
	if msg == "off" then
		Stop()
		print("|cff33ff99cfFrames|r: frame preview off.")
		return
	end

	local art = addon.frameArt
	local border = BorderRegion()
	if not art or not border then
		print("|cff33ff99cfFrames|r: frame art unavailable (is BiggerHealthbar loaded?).")
		return
	end

	ForceShow(TargetFrame)
	index = index % #art + 1
	border:SetTexture(art[index].tex)
	print(("|cff33ff99cfFrames|r: target frame = %s  (/cffframe to step, /cffframe off to stop)"):format(art[index].name))
end
