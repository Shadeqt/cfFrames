local M = cff.MODULES
local V = cff.VALUES

local bar

local function CreatePetCastbar()
	bar = CreateFrame("StatusBar", nil, UIParent, "SmallCastingBarFrameTemplate")
	bar:Hide()
	CastingBarFrame_OnLoad(bar, "pet")

	if cfFramesDB[M.StatusBar] then bar:SetStatusBarTexture(cff.GetStatusBarTexture()) end

	local hp = PetFrameHealthBar
	local w, h = hp:GetWidth(), hp:GetHeight()

	bar:SetSize(w, h)
	bar:ClearAllPoints()
	bar:SetPoint("TOP", PetFrame, "BOTTOM", 15, 5)

	bar.Border:ClearAllPoints()
	bar.Border:SetPoint("TOPLEFT", bar, -12, 14)
	bar.Border:SetPoint("BOTTOMRIGHT", bar, 12, -14)
	bar.Flash:ClearAllPoints()
	bar.Flash:SetPoint("TOPLEFT", bar, -12, 14)
	bar.Flash:SetPoint("BOTTOMRIGHT", bar, 12, -14)
	bar.Icon:ClearAllPoints()
	bar.Icon:SetPoint("RIGHT", bar, "LEFT", -4, 0)
	bar.Icon:SetSize(h * 1.5, h * 1.5)
	if bar.Text then bar.Text:ClearAllPoints(); bar.Text:SetPoint("CENTER") end

	bar:HookScript("OnEvent", function(self, event)
		if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
			CastingBarFrame_OnEvent(self, "PLAYER_ENTERING_WORLD")
		end
	end)

	if cfFramesDB[M.DarkModeCastbars] then
		cff.SaveAndDarken(bar.Border)
	end

	return bar
end

function cff.ApplyPetCastbar()
	if not bar then return end
	bar:SetScale(cfFramesDB[V.PetCastbarScale])
	bar:ClearAllPoints()
	bar:SetPoint("TOP", PetFrame, "BOTTOM", 13 + cfFramesDB[V.PetCastbarX], 5 + cfFramesDB[V.PetCastbarY])
end

function cff.ApplyPetCastbarIcon()
	if not bar or not bar.Icon then return end
	local hp = PetFrameHealthBar
	local h = hp and hp:GetHeight() or 7
	bar.Icon:SetScale(cfFramesDB[V.PetCastbarIconScale])
	bar.Icon:ClearAllPoints()
	bar.Icon:SetPoint("RIGHT", bar, "LEFT", -4 + cfFramesDB[V.PetCastbarIconX], cfFramesDB[V.PetCastbarIconY])
end

function cff.EnablePetCastbar()
	if not cfFramesDB[M.PetCastbar] then return end
	if not PetFrame then return end

	if not bar then CreatePetCastbar() end

	CastingBarFrame_SetUnit(bar, "pet")
	if UnitCastingInfo("pet") or UnitChannelInfo("pet") then
		CastingBarFrame_OnEvent(bar, "PLAYER_ENTERING_WORLD")
	end
end

function cff.DisablePetCastbar()
	if not bar then return end
	CastingBarFrame_SetUnit(bar, nil)
	bar:Hide()
end

function cff.EnablePetCastbarIcon()
	if not cfFramesDB[M.PetCastbarIcon] then return end
	if not bar or not bar.Icon then return end
	bar.Icon:Show()
end

function cff.DisablePetCastbarIcon()
	if not bar or not bar.Icon then return end
	bar.Icon:Hide()
end

-- Re-register when pet changes
local f = CreateFrame("Frame")
f:RegisterEvent("UNIT_PET")
f:SetScript("OnEvent", function(_, _, unit)
	if unit ~= "player" then return end
	if bar and cfFramesDB[M.PetCastbar] then
		CastingBarFrame_SetUnit(bar, "pet")
	end
end)

cff.RegisterCallback(M.StatusBar, function()
	if bar and cfFramesDB[M.StatusBar] then
		bar:SetStatusBarTexture(cff.GetStatusBarTexture())
	end
end)

cff.RegisterCallback(M.DarkMode, function()
	if bar and cfFramesDB[M.DarkModeCastbars] then
		cff.SaveAndDarken(bar.Border)
	end
end)
