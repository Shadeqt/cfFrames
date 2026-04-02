local frame = TargetFrameToT
if not frame then return end

local DEFAULTS = { x = 0, y = 0, scale = 1 }
local Apply = cfFrames.Movable(frame, "TargetOfTarget", DEFAULTS)

cfFrames.TargetOfTarget = {
	Apply = Apply,
	Reset = function()
		cfFramesDB.TargetOfTarget = CopyTable(DEFAULTS)
		Apply()
	end,
}
