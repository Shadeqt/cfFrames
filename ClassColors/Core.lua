local _, addon = ...

-- Class-color feature family, absorbed from the former standalone cfClassColors addon: chat, class-word,
-- name, and level coloring across the social UI. The health-bar tint (Healthbars.lua) is the sibling
-- visual half. The Shaman pink->blue correction now lives in Fixes/ShamanColorFix.lua (a standalone Fix,
-- ungated by the coloring toggles); cfFrames is the ecosystem's sole RAID_CLASS_COLORS patcher.
--
-- This file builds the one shared piece: a reverse lookup from localized class name -> class token, used
-- by ClassNames + NameColors. Built at file scope (the LOCALIZED_CLASS_NAMES globals exist at load), so
-- it's ready before the PLAYER_ENTERING_WORLD Setup* calls run. MUST load before its consumers (.toc
-- order): ClassNames/NameColors capture addon.classNameToToken as a file-scope local.
addon.classNameToToken = {}
for token, name in pairs(LOCALIZED_CLASS_NAMES_MALE or {}) do
	addon.classNameToToken[name] = token
end
for token, name in pairs(LOCALIZED_CLASS_NAMES_FEMALE or {}) do
	addon.classNameToToken[name] = token
end
