local MEDIA = "Interface\\AddOns\\cfFrames\\Media\\TargetingFrame\\"
local NORMAL  = MEDIA .. "UI-TargetingFrame"
local ELITE   = MEDIA .. "UI-TargetingFrame-Elite"
local RARE    = MEDIA .. "UI-TargetingFrame-Rare"
local RELITE  = MEDIA .. "UI-TargetingFrame-Rare-Elite"
local STATUS  = MEDIA .. "UI-Player-Status"

local _, addon = ...
local hooked = false

-- Off is reload-gated: Blizzard's untouched defaults return on /reload, so no Disable/restore path
-- (or module save-state table) is kept.
--
-- OffsetY must re-assert (original base point + dy), not (current point + dy): the target
-- classification hook fires on every new target, so computing from the current point would compound
-- and the bar would creep upward each time. The base point is cached on the frame, keeping it
-- idempotent without a module-level table.
local function OffsetY(frame, dy)
	if not frame then return end
	if not frame.cffBasePoint then
		frame.cffBasePoint = { frame:GetPoint() }
	end
	local p = frame.cffBasePoint
	frame:ClearAllPoints()
	frame:SetPoint(p[1], p[2], p[3], p[4], (p[5] or 0) + dy)
end

local function SetBarHeight(frame, height)
	if frame then frame:SetHeight(height) end
end

local function SetFrameTexture(frame, texture)
	if frame then frame:SetTexture(texture) end
end

local function SetPlayerFrame()
	SetFrameTexture(PlayerFrameTexture, NORMAL)
	SetBarHeight(PlayerFrameHealthBar, 27)
	OffsetY(PlayerFrameHealthBar, 18)
	OffsetY(PlayerName, 17)
	OffsetY(PlayerFrameHealthBar.RightText, 10)
	OffsetY(PlayerFrameHealthBar.LeftText, 10)
	OffsetY(PlayerFrameHealthBar.TextString, 10)
	SetFrameTexture(PlayerStatusTexture, STATUS)
	SetBarHeight(PlayerStatusTexture, 69)
end

local function HookTargetFrame()
	if hooked then return end
	hooked = true
	-- Installed only when enabled; off is reload-gated, so no in-hook enabled check is needed.
	hooksecurefunc("TargetFrame_CheckClassification", function(frame)
		if not frame or not frame.unit then return end
		SetFrameTexture(TargetFrameTextureFrameTexture, NORMAL)
		SetBarHeight(TargetFrameHealthBar, 27)
		OffsetY(TargetFrameHealthBar, 18)
		OffsetY(TargetFrame.name, 17)
		OffsetY(TargetFrameTextureFrameDeadText, 10)
		SetBarHeight(TargetFrame.Background, 41)
		TargetFrameNameBackground:SetVertexColor(0, 0, 0, 0)

		local classification = UnitClassification(frame.unit)
		if classification == "worldboss" or classification == "elite" then
			frame.borderTexture:SetTexture(ELITE)
		elseif classification == "rareelite" then
			frame.borderTexture:SetTexture(RELITE)
		elseif classification == "rare" then
			frame.borderTexture:SetTexture(RARE)
		else
			frame.borderTexture:SetTexture(NORMAL)
		end
	end)
end

function addon.SetupBiggerHealthbar()
	if not cfFramesDB.BiggerHealthbar then return end
	SetPlayerFrame()
	HookTargetFrame()
	if UnitExists("target") then TargetFrame_CheckClassification(TargetFrame) end
end

