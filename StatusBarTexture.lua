local TEXTURE

local function SetBarTexture(bar)
	if not bar then return end
	local tex = bar:GetStatusBarTexture()
	if tex and tex:GetTexture() == TEXTURE then return end
	local layer, sublevel
	if tex then layer, sublevel = tex:GetDrawLayer() end
	bar:SetStatusBarTexture(TEXTURE)
	if layer then bar:GetStatusBarTexture():SetDrawLayer(layer, sublevel or 0) end
end

local function SetStaticBars()
	if TargetFrameNameBackground then TargetFrameNameBackground:SetTexture(TEXTURE) end
	SetBarTexture(CastingBarFrame)
	SetBarTexture(TargetFrameSpellBar)
	SetBarTexture(PetSpellBar)
	SetBarTexture(MainMenuExpBar)
	if ExhaustionLevelFillBar then ExhaustionLevelFillBar:SetTexture(TEXTURE) end
	if ReputationWatchBar then SetBarTexture(ReputationWatchBar.StatusBar) end
	SetBarTexture(PlayerFrameHealthBar)
	SetBarTexture(PlayerFrameManaBar)
	SetBarTexture(PetFrameHealthBar)
	SetBarTexture(PetFrameManaBar)
end

local hookedBars = {}

local function HookCompactBar(bar)
	if not bar or hookedBars[bar] then return end
	hookedBars[bar] = true
	SetBarTexture(bar)
	hooksecurefunc(bar, "SetStatusBarTexture", function(self, tex)
		if tex ~= TEXTURE then
			self:SetStatusBarTexture(TEXTURE)
		end
	end)
end

local function HookDynamicBars()
	hooksecurefunc("UnitFrameHealthBar_Update", function(bar)
		SetBarTexture(bar)
	end)
	hooksecurefunc("UnitFrameManaBar_UpdateType", function(bar)
		SetBarTexture(bar)
	end)

	if CompactUnitFrame_UpdateHealthColor then
		hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(f)
			if not f then return end
			if f.healthBar then HookCompactBar(f.healthBar) end
			if f.powerBar then HookCompactBar(f.powerBar) end
		end)
	end
end

local function HookNameplates()
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	frame:SetScript("OnEvent", function(_, _, unit)
		local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
		if not nameplate or not nameplate.UnitFrame then return end
		SetBarTexture(nameplate.UnitFrame.healthBar)
	end)
end

function cfFrames.initStatusBarTexture()
	TEXTURE = cfFramesDB.StatusBarTexture
	cfFrames.registerBarTexture(TEXTURE)
	SetStaticBars()
	HookDynamicBars()
	HookNameplates()
end
