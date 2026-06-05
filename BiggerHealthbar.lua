local MEDIA = "Interface\\AddOns\\cfFrames\\Media\\TargetingFrame\\"
local NORMAL  = MEDIA .. "UI-TargetingFrame"
local ELITE   = MEDIA .. "UI-TargetingFrame-Elite"
local RARE    = MEDIA .. "UI-TargetingFrame-Rare"
local RELITE  = MEDIA .. "UI-TargetingFrame-Rare-Elite"
local STATUS  = MEDIA .. "UI-Player-Status"

local _, addon = ...
local hooked = false
local guarding = false  -- re-entrancy guard: skip the SetPoint we issue from KeepOffset's own hook

-- Off is reload-gated: Blizzard's untouched defaults return on /reload, so no Disable/restore path
-- (or module save-state table) is kept.
--
-- Nudge a region's Y by dy, self-correcting against Blizzard's repeated layout resets. We can't
-- cache a "base" once and trust it forever: if that capture ever lands on a non-default Y (a
-- transient layout pass, a different art context, the frame having been moved) the offset is wrong
-- for good. Instead we remember the exact Y we last set; on each call, if the region is no longer
-- there, Blizzard re-laid it out, so we re-baseline from its current (default) Y; if it's still
-- where we left it, we keep the baseline. We always end at baseline+dy -- never compounding (the
-- old upward creep), never stuck on a stale base. Re-read the anchor each time too, in case
-- Blizzard re-anchors to a different relative point.
local function OffsetY(frame, dy)
	if not frame then return end
	local point, relTo, relPoint, x, y = frame:GetPoint()
	if not y then return end
	if not frame.cffAppliedY or math.abs(frame.cffAppliedY - y) > 0.5 then
		frame.cffBaseY = y  -- Blizzard's current default; re-baseline off it
	end
	frame:ClearAllPoints()
	frame:SetPoint(point, relTo, relPoint, x, frame.cffBaseY + dy)
	frame.cffAppliedY = frame.cffBaseY + dy
end

local function SetBarHeight(frame, height)
	if frame then frame:SetHeight(height) end
end

local function SetFrameTexture(frame, texture)
	if frame then frame:SetTexture(texture) end
end

-- Apply OffsetY now and keep it applied. Blizzard re-anchors the player health bar / name on a
-- deferred layout pass after loading screens -- it lands AFTER any event hook (PlayerFrame_OnEvent
-- etc.) fires, so re-applying from an event loses the race and the offset reverts to default while
-- our texture/height stay (the "half-styled" result). Instead we hook the region's own SetPoint:
-- the instant anything (Blizzard's deferred layout, a frame mover) repositions it, we re-assert the
-- offset, making our write the last one -- no matter which function does it or when. The guard
-- skips the SetPoint we issue ourselves, so there's no recursion; OffsetY is self-correcting, so
-- re-asserting from a reset default lands on default+dy without compounding.
local function KeepOffset(frame, dy)
	if not frame then return end
	OffsetY(frame, dy)
	if frame.cffKept then return end
	frame.cffKept = true
	hooksecurefunc(frame, "SetPoint", function()
		if guarding then return end
		guarding = true
		OffsetY(frame, dy)
		guarding = false
	end)
end

local function SetPlayerFrame()
	SetFrameTexture(PlayerFrameTexture, NORMAL)
	SetBarHeight(PlayerFrameHealthBar, 27)
	KeepOffset(PlayerFrameHealthBar, 18)
	KeepOffset(PlayerName, 17)
	KeepOffset(PlayerFrameHealthBar.RightText, 10)
	KeepOffset(PlayerFrameHealthBar.LeftText, 10)
	KeepOffset(PlayerFrameHealthBar.TextString, 10)
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

