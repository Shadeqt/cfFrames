local _, addon = ...

-- Classic-era Shaman-blue override (file scope, un-gated).
-- Era's default RAID_CLASS_COLORS.SHAMAN renders pink; this patches it to blue.
-- cfFrames is now the ecosystem's sole Shaman patcher (cfSwingTimer + the absorbed
-- Healthbars feature read RAID_CLASS_COLORS live at show time), so this runs
-- regardless of the ClassColors master toggle and must not wait for ADDON_LOADED.
local BLUE = CreateColor(0, 0.44, 0.87)
BLUE.colorStr = "ff0070de"
RAID_CLASS_COLORS["SHAMAN"] = BLUE

-- Reverse lookup: localized class name -> class token. Shared by ClassNames + NameColors.
addon.classNameToToken = {}
for token, name in pairs(LOCALIZED_CLASS_NAMES_MALE or {}) do
	addon.classNameToToken[name] = token
end
for token, name in pairs(LOCALIZED_CLASS_NAMES_FEMALE or {}) do
	addon.classNameToToken[name] = token
end

-- One gated entry for all 5 class-color sub-features (the single ClassColors master toggle).
-- This is the only enable check; each SetupX below installs its hooks unguarded.
function addon.SetupClassColors()
	if not cfFramesDB.ClassColors then return end
	addon.SetupChatColors()
	addon.SetupClassNames()
	addon.SetupNameColors()
	addon.SetupLevelColors()
	addon.SetupHealthbars()
end
