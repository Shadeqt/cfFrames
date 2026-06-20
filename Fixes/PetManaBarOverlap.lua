local _, addon = ...

-- Nudge the pet mana bar down 1px (cfFramesTest fix). Blizzard's PetFrame.xml anchors the pet health and
-- mana bars 7px apart while both are 8px tall, so the mana bar's top sits 1px over the health bar's
-- bottom -- a native overlap (the smooth bar texture just makes it obvious). KeepOffset re-asserts the
-- shift past Blizzard's layout passes (the pet mana bar is re-anchored on power-type changes).
function addon.SetupPetManaBarOverlapFix()
	if not cfFramesDB.PetManaBarOverlapFix then return end
	addon.KeepOffset(PetFrameManaBar, -1)  -- negative Y lowers the top-anchored bar by 1px
end
