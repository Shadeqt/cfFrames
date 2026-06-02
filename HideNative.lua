local _, addon = ...

-- Catch-all for hiding native Blizzard UI elements. Currently: the player and pet
-- portrait glow (the pulsing combat/rested aura). More elements can be added here
-- under the one "Hide Native Elements" toggle.
--
-- Off is reload-gated like the other modules: Blizzard's defaults return on /reload,
-- so there's no restore path. Each element is reparented to a permanently-hidden
-- frame rather than :Hide()'d, because Blizzard re-Show()s them on combat/rested
-- state changes (PlayerFrame_UpdateStatus). A hidden parent makes those Show() calls
-- no-ops without needing a per-Show hook -- effective visibility is own-shown AND
-- parent-shown. Anchors are independent of parent, so position is unaffected; these
-- are texture regions (not secure frames), so reparenting is combat-safe.
local hidden = CreateFrame("Frame")
hidden:Hide()

local function HideElement(region)
	if region then region:SetParent(hidden) end
end

function addon.SetupHideNative()
	if not cfFramesDB.HideNative then return end
	-- Player: the portrait glow. PlayerStatusTexture is the actual rested/combat pulse
	-- in Classic Era (PlayerStatusGlow doesn't carry it); BiggerHealthbar only restyles
	-- PlayerStatusTexture (never force-shows) and runs before us, so hiding it here wins.
	HideElement(PlayerStatusGlow)
	HideElement(PlayerStatusTexture)
	-- Pet: combat flash + attack-mode texture.
	HideElement(PetFrameFlash)
	HideElement(PetAttackModeTexture)
end
