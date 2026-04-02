local frame = PlayerFrame
if not frame then return end

local DEFAULTS = { x = 0, y = 0, scale = 1 }
local Apply = cfFrames.Movable(frame, "PlayerFrame", DEFAULTS)

cfFrames.PlayerFrame = {
	Apply = Apply,
	Reset = function()
		cfFramesDB.PlayerFrame = CopyTable(DEFAULTS)
		Apply()
	end,
}
