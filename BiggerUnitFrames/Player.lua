local _, addon = ...
local HBL = addon.BiggerUnitFrames

-- Player: swap in the UnitFramesImproved frame art and enlarge the player health bar. This art lines up
-- with Blizzard's default level/glow/icon positions, so it needs no alignment nudges -- just textures +
-- bar enlarge + the name/text raise the taller bar window requires. KeepOffset re-asserts past Blizzard's
-- deferred layout passes (the player frame isn't re-applied on an event, unlike the target).
local DIR           = "Interface\\AddOns\\cfFrames\\Media\\UnitFramesImproved\\"
local NORMAL_BORDER = DIR .. "UI-TargetingFrame"
local PLAYER_STATUS = DIR .. "UI-Player-Status"

function HBL.SetupPlayer()
	if PlayerFrameTexture then PlayerFrameTexture:SetTexture(NORMAL_BORDER) end
	if PlayerStatusTexture then PlayerStatusTexture:SetTexture(PLAYER_STATUS) end
	addon.KeepOffset(PlayerName, HBL.VERTICAL_OFFSET)
	if PlayerFrameHealthBar then
		PlayerFrameHealthBar:SetHeight(HBL.HEALTH_BAR_HEIGHT)
		addon.KeepOffset(PlayerFrameHealthBar, HBL.VERTICAL_OFFSET)
		-- Raise the bar's native text to stay centered in the enlarged bar.
		addon.KeepOffset(PlayerFrameHealthBar.TextString, HBL.HEALTH_BAR_TEXT_OFFSET)
		addon.KeepOffset(PlayerFrameHealthBar.LeftText,   HBL.HEALTH_BAR_TEXT_OFFSET)
		addon.KeepOffset(PlayerFrameHealthBar.RightText,  HBL.HEALTH_BAR_TEXT_OFFSET)
	end
end
