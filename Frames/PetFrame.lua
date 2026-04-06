local V = cff.VALUES

-- PetFrame: store raw Blizzard args and inject offset
local petRaw = {}
if PetFrame then
	petRaw.point, petRaw.relativeTo, petRaw.relativePoint, petRaw.x, petRaw.y = PetFrame:GetPoint()
	petRaw.x = petRaw.x or 0
	petRaw.y = petRaw.y or 0

	local origPetSetPoint = PetFrame.SetPoint
	PetFrame.SetPoint = function(self, point, relativeTo, relativePoint, x, y, ...)
		petRaw.point, petRaw.relativeTo, petRaw.relativePoint, petRaw.x, petRaw.y = point, relativeTo, relativePoint, x or 0, y or 0
		origPetSetPoint(self, point, relativeTo, relativePoint, petRaw.x + cfFramesDB[V.PetFrameX], petRaw.y + cfFramesDB[V.PetFrameY], ...)
	end
end

function cff.ApplyPetFrame()
	if not PetFrame then return end
	PetFrame:SetScale(cfFramesDB[V.PetFrameScale])
	if petRaw.point then
		PetFrame:SetPoint(petRaw.point, petRaw.relativeTo, petRaw.relativePoint, petRaw.x, petRaw.y)
	end
end
