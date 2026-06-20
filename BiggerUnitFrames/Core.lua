local _, addon = ...

-- BiggerUnitFrames (cfFramesTest's newest implementation, UnitFramesImproved variant): enlarge the
-- player + target health bars and swap in the UnitFramesImproved frame art. Shared sizing constants live
-- here; the per-frame art + offsets live in Player.lua / Target.lua. Reload-gated on
-- cfFramesDB.BiggerHealthbar (the DB key is kept from the old single-file BiggerHealthbar feature so
-- saved settings + the GUI checkbox carry over). Layout offsetting uses addon.ApplyOffset/KeepOffset
-- (promoted to Init.lua).

local HBL = {}
addon.BiggerUnitFrames = HBL

-- Health-bar sizing for the taller bar window in the UnitFramesImproved art (player + target share it).
-- The bar grows downward from its top anchor, so the offset slides the enlarged bar back up into the
-- window; the name rides up by the same amount. The bar's status text + the Dead/Corpse overlay follow
-- the bar with the text offset.
HBL.HEALTH_BAR_HEIGHT      = 28
HBL.VERTICAL_OFFSET        = 18
HBL.HEALTH_BAR_TEXT_OFFSET = 10

-- Reload-gated; called once from Init's PLAYER_ENTERING_WORLD pass. SetupPlayer/SetupTarget are defined
-- in the sibling files (loaded after this one); both exist by the time this runs at runtime.
function addon.SetupBiggerHealthbar()
	if not cfFramesDB.BiggerHealthbar then return end
	HBL.SetupPlayer()
	HBL.SetupTarget()
end
