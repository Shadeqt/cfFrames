local M = cfFrames.MODULES

local MEDIA = "Interface\\AddOns\\cfFrames\\Media\\"
local NORMAL_TEXTURE    = MEDIA .. "UI-TargetingFrame"
local ELITE_TEXTURE     = MEDIA .. "UI-TargetingFrame-Elite"
local RARE_TEXTURE      = MEDIA .. "UI-TargetingFrame-Rare"
local RAREELITE_TEXTURE = MEDIA .. "UI-TargetingFrame-Rare-Elite"

local SENTINEL = "cfFramesBiggerHP"
local movedFrames = {}

local function MoveRegion(frame, point, relativeTo, relativePoint, xOffset, yOffset)
	if not frame then return end
	frame:ClearAllPoints()
	frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset, SENTINEL)
	movedFrames[frame] = {point, relativeTo, relativePoint, xOffset, yOffset}

	if not frame.cfBiggerHPHooked then
		hooksecurefunc(frame, "SetPoint", function(self, _, _, _, _, _, flag)
			if flag ~= SENTINEL then
				if not cfFramesDB[M.BIGGER_HEALTHBAR] then return end
				if InCombatLockdown() then return end
				self:ClearAllPoints()
				self:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset, SENTINEL)
			end
		end)
		frame.cfBiggerHPHooked = true
	end
end

-- Re-apply positions after combat ends
local combatFrame = CreateFrame("Frame")
combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
combatFrame:SetScript("OnEvent", function()
	if not cfFramesDB[M.BIGGER_HEALTHBAR] then return end
	for frame, args in pairs(movedFrames) do
		frame:ClearAllPoints()
		frame:SetPoint(args[1], args[2], args[3], args[4], args[5], SENTINEL)
	end
end)

local function Enable()
	-- Player frame border texture
	PlayerFrameTexture:SetTexture(NORMAL_TEXTURE)

	-- Player health bar
	PlayerFrameHealthBar:SetHeight(27)
	MoveRegion(PlayerFrameHealthBar, "CENTER", PlayerFrame, "CENTER", 50, 14)

	-- Player mana bar
	MoveRegion(PlayerFrameManaBar, "CENTER", PlayerFrame, "CENTER", 51, -7)

	-- Player name
	MoveRegion(PlayerName, "CENTER", PlayerFrame, "CENTER", 52, 35)

	-- Player status glow (resting/combat)
	PlayerStatusTexture:SetHeight(69)

	-- Player health text
	MoveRegion(PlayerFrameHealthBar.RightText, "RIGHT", PlayerFrame, "RIGHT", -8, 12)
	MoveRegion(PlayerFrameHealthBar.LeftText, "LEFT", PlayerFrame, "LEFT", 110, 12)
	MoveRegion(PlayerFrameHealthBar.TextString, "CENTER", PlayerFrame, "CENTER", 52, 12)

	-- Player mana text
	MoveRegion(PlayerFrameManaBar.TextString, "CENTER", PlayerFrame, "CENTER", 52, -8)

	-- Target health bar
	TargetFrameHealthBar:SetHeight(27)
	MoveRegion(TargetFrameHealthBar, "CENTER", TargetFrame, "CENTER", -50, 14)

	-- Target mana bar
	MoveRegion(TargetFrameManaBar, "CENTER", TargetFrame, "CENTER", -51, -7)

	-- Target name
	MoveRegion(TargetFrame.name, "CENTER", TargetFrame, "CENTER", -51, 35)

	-- Target dead text
	MoveRegion(TargetFrameTextureFrameDeadText, "CENTER", TargetFrame, "CENTER", -50, 12)

	-- Target background — hide and hook to prevent Blizzard resetting it on target change
	TargetFrameNameBackground:SetVertexColor(0, 0, 0, 0)
	if not TargetFrameNameBackground.cfBiggerHPHooked then
		hooksecurefunc(TargetFrameNameBackground, "SetVertexColor", function(self, r, g, b, a)
			if self.cfChanging then return end
			if not cfFramesDB[M.BIGGER_HEALTHBAR] then return end
			if r == 0 and g == 0 and b == 0 and a == 0 then return end
			self.cfChanging = true
			self:SetVertexColor(0, 0, 0, 0)
			self.cfChanging = false
		end)
		TargetFrameNameBackground.cfBiggerHPHooked = true
	end
	TargetFrame.Background:SetHeight(41)

	-- Apply classification texture for current target
	if UnitExists("target") then
		TargetFrame_CheckClassification(TargetFrame)
	end
end

-- Classification hook: swap border texture per mob type
hooksecurefunc("TargetFrame_CheckClassification", function(frame)
	if not cfFramesDB[M.BIGGER_HEALTHBAR] then return end
	if not frame or not frame.unit then return end

	local classification = UnitClassification(frame.unit)

	TargetFrame.Background:SetHeight(41)

	if classification == "worldboss" or classification == "elite" then
		frame.borderTexture:SetTexture(ELITE_TEXTURE)
	elseif classification == "rareelite" then
		frame.borderTexture:SetTexture(RAREELITE_TEXTURE)
	elseif classification == "rare" then
		frame.borderTexture:SetTexture(RARE_TEXTURE)
	else
		frame.borderTexture:SetTexture(NORMAL_TEXTURE)
	end
end)

-- Player texture hook: prevent Blizzard from resetting border texture
hooksecurefunc(PlayerFrameTexture, "SetTexture", function(self, texture)
	if not cfFramesDB[M.BIGGER_HEALTHBAR] then return end
	if texture ~= NORMAL_TEXTURE then
		self:SetTexture(NORMAL_TEXTURE)
	end
end)

local function RestorePoint(frame, point, relativeTo, relativePoint, x, y)
	frame:ClearAllPoints()
	frame:SetPoint(point, relativeTo, relativePoint, x, y, SENTINEL)
end

local function Disable()
	-- Restore default textures
	PlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")
	TargetFrameTextureFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame")

	-- Restore default heights
	PlayerFrameHealthBar:SetHeight(12)
	TargetFrameHealthBar:SetHeight(12)
	PlayerStatusTexture:SetHeight(52)
	TargetFrame.Background:SetHeight(27)

	-- Restore target frame positions (from Blizzard XML defaults)
	RestorePoint(TargetFrameHealthBar, "TOPRIGHT", TargetFrame, "TOPRIGHT", -106, -41)
	RestorePoint(TargetFrameManaBar, "TOPRIGHT", TargetFrame, "TOPRIGHT", -106, -52)
	RestorePoint(TargetFrame.name, "CENTER", TargetFrame, "CENTER", -50, 19)
	RestorePoint(TargetFrameHealthBar.TextString, "CENTER", TargetFrameHealthBar, "CENTER", 0, 0)
	RestorePoint(TargetFrameHealthBar.RightText, "RIGHT", TargetFrameHealthBar, "RIGHT", -2, 0)
	RestorePoint(TargetFrameHealthBar.LeftText, "LEFT", TargetFrameHealthBar, "LEFT", 2, 0)
	RestorePoint(TargetFrameManaBar.TextString, "CENTER", TargetFrameManaBar, "CENTER", 0, 0)
	RestorePoint(TargetFrameTextureFrameDeadText, "CENTER", TargetFrameHealthBar, "CENTER", 0, 0)

	-- Let Blizzard re-layout player frame
	PlayerFrame_ToPlayerArt(PlayerFrame)
end

cfFrames:RegisterModule(M.BIGGER_HEALTHBAR, Enable, Disable)
