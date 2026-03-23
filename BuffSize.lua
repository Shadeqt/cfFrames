local M = cfFrames.MODULES

local SCALE = 1.2

local function Enable()
	BuffFrame:SetScale(SCALE)
	TemporaryEnchantFrame:SetScale(SCALE)
end

local function Disable()
	BuffFrame:SetScale(1)
	TemporaryEnchantFrame:SetScale(1)
end

cfFrames:RegisterModule(M.BUFF_SIZE, Enable, Disable)
