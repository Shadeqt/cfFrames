local _, addon = ...

-- The health-bar class tint is the only class-color feature cfFrames keeps. The chat/name/level text
-- coloring and the Shaman-blue RAID_CLASS_COLORS patch now live in the standalone cfClassColors (the
-- ecosystem's sole Shaman patcher). Healthbars reads RAID_CLASS_COLORS at show time -- whatever has
-- patched it -- so cfFrames needs no patch and no classNameToToken helper here.
--
-- The cfFramesDB.ClassColors toggle (GUI: "Health Bar Class Colors") gates the tint; SetupHealthbars
-- installs its hooks unguarded.
function addon.SetupClassColors()
	if not cfFramesDB.ClassColors then return end
	addon.SetupHealthbars()
end
