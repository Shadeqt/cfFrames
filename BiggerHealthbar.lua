local MEDIA = "Interface\\AddOns\\cfFrames\\Media\\TargetingFrame\\"
local NORMAL  = MEDIA .. "UI-TargetingFrame"
local ELITE   = MEDIA .. "UI-TargetingFrame-Elite"
local RARE    = MEDIA .. "UI-TargetingFrame-Rare"
local RELITE  = MEDIA .. "UI-TargetingFrame-Rare-Elite"
local STATUS  = MEDIA .. "UI-Player-Status"

local M = cff.MODULES
local hooked = false
local origPoint = {}
local origHeight = {}
local origTexture = {}

local function SaveAndMove(frame, dy)
	if not frame then return end
	if not origPoint[frame] then origPoint[frame] = { frame:GetPoint() } end
	local s = origPoint[frame]
	frame:ClearAllPoints()
	frame:SetPoint(s[1], s[2], s[3], s[4], (s[5] or 0) + dy)
end

local function SaveAndHeight(frame, h)
	if not frame then return end
	if not origHeight[frame] then origHeight[frame] = frame:GetHeight() end
	frame:SetHeight(h)
end

local function SaveAndTexture(frame, tex)
	if not frame then return end
	if not origTexture[frame] then origTexture[frame] = frame:GetTexture() end
	frame:SetTexture(tex)
end

local function SetPlayerFrame()
	SaveAndTexture(PlayerFrameTexture, NORMAL)
	SaveAndHeight(PlayerFrameHealthBar, 27)
	SaveAndMove(PlayerFrameHealthBar, 18)
	SaveAndMove(PlayerName, 17)
	SaveAndMove(PlayerFrameHealthBar.RightText, 10)
	SaveAndMove(PlayerFrameHealthBar.LeftText, 10)
	SaveAndMove(PlayerFrameHealthBar.TextString, 10)
	SaveAndTexture(PlayerStatusTexture, STATUS)
	SaveAndHeight(PlayerStatusTexture, 69)
end

local function HookTargetFrame()
	if hooked then return end
	hooked = true
	hooksecurefunc("TargetFrame_CheckClassification", function(frame)
		if not cfFramesDB[M.BiggerHealthbar] or not frame or not frame.unit then return end
		SaveAndTexture(TargetFrameTextureFrameTexture, NORMAL)
		SaveAndHeight(TargetFrameHealthBar, 27)
		SaveAndMove(TargetFrameHealthBar, 18)
		SaveAndMove(TargetFrame.name, 17)
		SaveAndMove(TargetFrameTextureFrameDeadText, 10)
		SaveAndHeight(TargetFrame.Background, 41)
		TargetFrameNameBackground:SetVertexColor(0, 0, 0, 0)

		local c = UnitClassification(frame.unit)
		if c == "worldboss" or c == "elite" then
			frame.borderTexture:SetTexture(ELITE)
		elseif c == "rareelite" then
			frame.borderTexture:SetTexture(RELITE)
		elseif c == "rare" then
			frame.borderTexture:SetTexture(RARE)
		else
			frame.borderTexture:SetTexture(NORMAL)
		end
	end)
end

function cff.EnableBiggerHealthbar()
	if not cfFramesDB[M.BiggerHealthbar] then return end

	SetPlayerFrame()
	HookTargetFrame()
	if UnitExists("target") then TargetFrame_CheckClassification(TargetFrame) end
end

function cff.DisableBiggerHealthbar()
	for frame, s in pairs(origPoint) do
		frame:ClearAllPoints()
		frame:SetPoint(s[1], s[2], s[3], s[4], s[5])
	end
	for frame, h in pairs(origHeight) do
		frame:SetHeight(h)
	end
	for frame, tex in pairs(origTexture) do
		frame:SetTexture(tex)
	end
	if UnitExists("target") then
		TargetFrame_CheckClassification(TargetFrame)
		TargetFrame_CheckFaction(TargetFrame)
	end
end

