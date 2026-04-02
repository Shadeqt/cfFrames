local frame = TargetFrame
if not frame then return end

local DEFAULTS = { x = 0, y = 0, scale = 1 }
local Apply = cfFrames.Movable(frame, "TargetFrame", DEFAULTS)

cfFrames.TargetFrame = {
	Apply = Apply,
	Reset = function()
		cfFramesDB.TargetFrame = CopyTable(DEFAULTS)
		Apply()
	end,
}
