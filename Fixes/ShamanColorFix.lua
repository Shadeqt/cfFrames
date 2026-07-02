local _, addon = ...

-- Era's default RAID_CLASS_COLORS.SHAMAN renders pink; correct it to blue. A standalone Fix, NOT part of
-- the class-color coloring features: it's ungated by the ClassColors / ClassColorText toggles so the
-- corrected color stays in place ecosystem-wide (cfFrames' own health tint, cfSwingTimer's main-hand bar,
-- cfCastbars all read RAID_CLASS_COLORS live and follow it). cfFrames is the sole patcher of this global.
--
-- Runs at FILE SCOPE -- before any reader resolves the color at show time -- so it cannot use the normal
-- `if not cfFramesDB.X` gate: file scope runs before InitDB() populates defaults, and a fresh character's
-- cfFramesDB is still nil here. Default-on semantics: skip only on an explicit `false` (an existing
-- character who unchecked it). Reload-gated like every other Fix.
if cfFramesDB and cfFramesDB.ShamanColorFix == false then return end

local BLUE = CreateColor(0, 0.44, 0.87)
BLUE.colorStr = "ff0070de"
RAID_CLASS_COLORS["SHAMAN"] = BLUE
