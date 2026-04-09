local M = cff.MODULES
local V = cff.VALUES

local bar

local function CreatePetCastbar()
	local hp = PetFrameHealthBar
	local w, h = hp:GetWidth(), hp:GetHeight()
	bar = cff.CreateCastbar(UIParent, "pet", w, h)
	bar:SetPoint("TOP", PetFrame, "BOTTOM", 16, 5)

	if cfFramesDB[M.DarkModeCastbars] then
		cff.SaveAndDarken(bar.Border)
	end

	cff.StylePetCastbarIcon(bar)
	hooksecurefunc(bar, "Show", function(self)
		cff.StylePetCastbarIcon(self)
	end)

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

-- TEST: show pet castbar permanently at full (remove later)
EventUtil.ContinueOnAddOnLoaded("cfFrames", function()
	if not bar then CreatePetCastbar() end
	bar:SetScript("OnUpdate", nil)
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(1)
	bar:SetStatusBarColor(1, 0.7, 0)
	bar.Icon:SetTexture("Interface\\Icons\\Spell_Nature_Lightning")
	bar.Icon:Show()
	bar:Show()
end)
