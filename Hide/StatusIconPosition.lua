local _, addon = ...

-- Not a hide but a move, bundled into the Hide group for now. The player rest and
-- combat icons (PlayerRestIcon / PlayerAttackIcon) overlap PlayerLevelText, so only one
-- is readable at a time. The combat icon is anchored relative to the rest icon, so
-- shifting the rest icon OFFSET px left drags the combat icon along too and uncovers the
-- level number for both states. Blizzard toggles these icons' visibility
-- (PlayerFrame_UpdateStatus) but doesn't re-anchor them, so re-applying the rest icon's
-- existing point with an x offset at setup holds across combat/rested changes. No GUI
-- yet -- applied unconditionally from SetupHideNative.
function addon.MovePlayerStatusIcons()
	-- The combat icon (PlayerAttackIcon) is anchored relative to the rest icon, so
	-- moving the rest icon drags the combat icon along by the same amount -- moving the
	-- rest icon alone moves both; touching the combat icon too would double its offset.
	if not PlayerRestIcon then return end
	-- Keep GetPoint's multi-return intact: an `and` guard on the same line would
	-- truncate it to a single value, leaving relativeTo/x/y nil (arithmetic on nil x).
	local point, relativeTo, relativePoint, x, y = PlayerRestIcon:GetPoint(1)
	if point and x then
		PlayerRestIcon:SetPoint(point, relativeTo, relativePoint, x - 25, y)
	end
end
