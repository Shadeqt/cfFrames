-- cfStatusText StatusText (folded into cfFrames): create + position status text on the target frame
-- (Classic's target bar template defines none). Positioning only: keeps Blizzard's native text render --
-- no font swap, no NUMERIC value-only override. It mirrors the player frame's status text onto the
-- target, so it tracks wherever the player text currently sits -- raised if cfFrames' BiggerHealthbar is
-- present, default if not -- via the MirrorOnMove SetPoint hook. Reload-gated on cfFramesDB.StatusText;
-- run from addon.SetupStatusText in Init's PLAYER_ENTERING_WORLD pass (after SetupBiggerHealthbar, so the
-- player text is already raised when we mirror it).

local _, addon = ...

-- ---- Target frame: create + mirror the status text the Classic template omits ----

-- Target bar mirrors the player bar: negate x, swap left<->right.
local function MirrorOffsets(playerBar)
	local _, _, _, cx, cy = playerBar.TextString:GetPoint(1)
	local _, _, _, lx, ly = playerBar.LeftText:GetPoint(1)
	local _, _, _, rx, ry = playerBar.RightText:GetPoint(1)
	return { center = {-cx, cy}, left = {-rx, ry}, right = {-lx, ly} }
end

-- Re-mirror the target text whenever the player text moves (cfFrames' BiggerHealthbar, or any other
-- mover) so the target stays aligned without recomputing offsets.
local function MirrorOnMove(playerText, targetText)
	hooksecurefunc(playerText, "SetPoint", function(self)
		local _, _, _, px, py = self:GetPoint(1)
		local point, rel, relPoint = targetText:GetPoint(1)
		targetText:SetPoint(point, rel, relPoint, -px, py)
	end)
end

-- Classic's target-bar template defines none of TextString/LeftText/RightText. Create all three via the
-- shared addon.CreateBarText (font strings + anchor to the target's texture frame); Blizzard's
-- UpdateTextString uses bar.TextString for percent/value and splits to bar.LeftText + bar.RightText in
-- BOTH mode.
local function MirrorBarText(playerBar, ourBar, parent)
	local offsets = MirrorOffsets(playerBar)
	addon.CreateBarText(ourBar, parent, {
		left   = { parent, offsets.left[1],   offsets.left[2] },
		center = { parent, offsets.center[1], offsets.center[2] },
		right  = { parent, offsets.right[1],  offsets.right[2] },
	})
	MirrorOnMove(playerBar.TextString, ourBar.TextString)
	MirrorOnMove(playerBar.LeftText,   ourBar.RightText)
	MirrorOnMove(playerBar.RightText,  ourBar.LeftText)
end

function addon.SetupStatusText()
	if not cfFramesDB.StatusText then return end

	MirrorBarText(PlayerFrameHealthBar, TargetFrameHealthBar, TargetFrameTextureFrame)
	MirrorBarText(PlayerFrameManaBar,   TargetFrameManaBar,   TargetFrameTextureFrame)

	-- Force text on regardless of the user's "Always Show Status Text" (statusText) CVar, and flag the
	-- bars cfManaged so the shared gate (addon.ApplyBarStatusText, hooked in Init.lua) runs after every
	-- Blizzard render: hide on NONE unless moused over, else force showPercentage=false so the render is
	-- the value (NUMERIC), splitting to LeftText/RightText in BOTH.
	TargetFrameHealthBar.lockShow = 1
	TargetFrameManaBar.lockShow = 1
	TargetFrameHealthBar.cfManaged = true
	TargetFrameManaBar.cfManaged = true

	TextStatusBar_UpdateTextString(TargetFrameHealthBar)
	TextStatusBar_UpdateTextString(TargetFrameManaBar)

	-- Mirror Blizzard's native mana-bar prefix onto the target. Blizzard sets manaBar.prefix (the
	-- localized power name -- "Mana"/"Rage"/"Energy"/...) on the player bar but leaves the target bar's
	-- prefix nil, so the player rendered "Mana 84 / 84" while the target showed a bare "84 / 84". Set it
	-- from the target's current power token the same way Blizzard does (_G[powerToken] is the same global
	-- string it uses), refreshed whenever Blizzard re-types the bar (target change / UNIT_DISPLAYPOWER).
	local function ApplyTargetManaPrefix()
		local _, powerToken = UnitPowerType("target")
		TargetFrameManaBar.prefix = powerToken and _G[powerToken] or nil
	end
	hooksecurefunc("UnitFrameManaBar_UpdateType", function(manaBar)
		if manaBar == TargetFrameManaBar then ApplyTargetManaPrefix() end
	end)
	if UnitExists("target") then ApplyTargetManaPrefix() end  -- catch a target already present (e.g. /reload)
end
