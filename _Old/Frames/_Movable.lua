local pendingQueue = {}
local deferred = {}
local allMovables = {}

local function EnsureDB(dbKey, defaults)
	if not cfFramesDB[dbKey] then
		if cfFramesDB.elements and cfFramesDB.elements[dbKey] then
			cfFramesDB[dbKey] = cfFramesDB.elements[dbKey]
			cfFramesDB.elements[dbKey] = nil
		else
			cfFramesDB[dbKey] = CopyTable(defaults)
		end
	end
end

local function Apply(frame, dbKey, originX, originY)
	local db = cfFramesDB[dbKey]
	if not db then return end

	if InCombatLockdown() and frame:IsProtected() then
		pendingQueue[dbKey] = { frame = frame, originX = originX, originY = originY }
		return
	end

	frame:SetScale(db.scale)
	frame:SetPointsOffset(originX + db.x, originY + db.y)
end

function cfFrames.Movable(frame, dbKey, defaults)
	if not frame then return function() end end

	local originX, originY

	-- Deferred: capture origin + ensure DB (runs at ADDON_LOADED)
	table.insert(deferred, function()
		EnsureDB(dbKey, defaults)
		local _, _, _, ox, oy = frame:GetPoint()
		originX = ox or 0
		originY = oy or 0
	end)

	local function DoApply()
		Apply(frame, dbKey, originX, originY)
	end

	table.insert(allMovables, DoApply)
	return DoApply
end

-- Capture origins (called from Init.lua at ADDON_LOADED)
function cfFrames.InitMovables()
	for _, fn in ipairs(deferred) do fn() end
end

-- Apply all (called at PLAYER_ENTERING_WORLD)
local function ApplyAll()
	for _, fn in ipairs(allMovables) do fn() end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_ENTERING_WORLD" then
		ApplyAll()
	elseif event == "PLAYER_REGEN_ENABLED" then
		for dbKey, entry in pairs(pendingQueue) do
			Apply(entry.frame, dbKey, entry.originX, entry.originY)
		end
		wipe(pendingQueue)
	end
end)
