local MEDIA = "Interface\\AddOns\\cfFrames\\Media\\TargetingFrame\\"
local NORMAL_TEXTURE    = MEDIA .. "UI-TargetingFrame"
local ELITE_TEXTURE     = MEDIA .. "UI-TargetingFrame-Elite"
local RARE_TEXTURE      = MEDIA .. "UI-TargetingFrame-Rare"
local RAREELITE_TEXTURE = MEDIA .. "UI-TargetingFrame-Rare-Elite"
local STATUS_TEXTURE    = MEDIA .. "UI-Player-Status"

local SENTINEL = "cfFramesBiggerHP"
local movedFrames = {}

local function MoveRegion(frame, point, relativeTo, relativePoint, xOffset, yOffset)
	if not frame then return end
	frame:ClearAllPoints()
	frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset, SENTINEL)
	movedFrames[frame] = {point, relativeTo, relativePoint, xOffset, yOffset}

	if not frame.cfsBiggerHPHooked then
		hooksecurefunc(frame, "SetPoint", function(self, _, _, _, _, _, flag)
			if flag ~= SENTINEL then
				if InCombatLockdown() then return end
				self:ClearAllPoints()
				self:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset, SENTINEL)
			end
		end)
		frame.cfsBiggerHPHooked = true
	end
end

local function ShiftRegion(frame, dx, dy)
	if not frame then return end
	local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
	MoveRegion(frame, point, relativeTo, relativePoint, (xOfs or 0) + dx, (yOfs or 0) + dy)
end

local function ResizePlayerHealthbar()
	PlayerFrameTexture:SetTexture(NORMAL_TEXTURE)
	PlayerFrameHealthBar:SetHeight(27)
	ShiftRegion(PlayerFrameHealthBar, 0, 18)
	ShiftRegion(PlayerName, 0, 17)
	ShiftRegion(PlayerFrameHealthBar.RightText, 0, 10)
	ShiftRegion(PlayerFrameHealthBar.LeftText, 0, 10)
	ShiftRegion(PlayerFrameHealthBar.TextString, 0, 10)
end

local function HookPlayerStatusTexture()
	PlayerStatusTexture:SetTexture(STATUS_TEXTURE)
	PlayerStatusTexture:SetHeight(69)
	hooksecurefunc(PlayerStatusTexture, "SetTexture", function(self, texture)
		if texture ~= STATUS_TEXTURE then
			self:SetTexture(STATUS_TEXTURE)
			self:SetHeight(69)
		end
	end)
end

local function HookPlayerFrameTexture()
	hooksecurefunc(PlayerFrameTexture, "SetTexture", function(self, texture)
		if texture ~= NORMAL_TEXTURE then
			self:SetTexture(NORMAL_TEXTURE)
		end
	end)
end

local function ResizeTargetHealthbar()
	TargetFrameTextureFrameTexture:SetTexture(NORMAL_TEXTURE)
	TargetFrameHealthBar:SetHeight(27)
	ShiftRegion(TargetFrameHealthBar, 0, 18)
	ShiftRegion(TargetFrame.name, 0, 17)
	ShiftRegion(TargetFrameTextureFrameDeadText, 0, 10)
	TargetFrame.Background:SetHeight(41)
end

local function HookTargetNameBackground()
	TargetFrameNameBackground:SetVertexColor(0, 0, 0, 0)
	hooksecurefunc(TargetFrameNameBackground, "SetVertexColor", function(self, r, g, b, a)
		if self.cfsChanging then return end
		if r == 0 and g == 0 and b == 0 and a == 0 then return end
		self.cfsChanging = true
		self:SetVertexColor(0, 0, 0, 0)
		self.cfsChanging = false
	end)
end

local function HookTargetClassification()
	hooksecurefunc("TargetFrame_CheckClassification", function(frame)
		if not frame or not frame.unit then return end

		TargetFrame.Background:SetHeight(41)

		local classification = UnitClassification(frame.unit)
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

	if UnitExists("target") then
		TargetFrame_CheckClassification(TargetFrame)
	end
end

local function SetupPlayerFrame()
	ResizePlayerHealthbar()
	HookPlayerStatusTexture()
	HookPlayerFrameTexture()
end

local function SetupTargetFrame()
	ResizeTargetHealthbar()
	HookTargetNameBackground()
	HookTargetClassification()
end

function cfFrames.initBiggerHealthbar()
	SetupPlayerFrame()
	SetupTargetFrame()
end
