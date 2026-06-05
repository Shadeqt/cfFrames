local _, addon = ...

-- The player "group indicator" banner (the "1"/role badge shown above the player
-- frame in a party). Reparenting the container hides its Middle/Left/Right textures
-- and the text child in one go; Blizzard re-Show()s it from
-- PlayerFrame_UpdateGroupIndicator, which the hidden parent neutralises.
function addon.HideGroupIndicator()
	addon.HideElement(PlayerFrameGroupIndicator)
end
