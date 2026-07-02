local _, addon = ...

-- cfPet (folded into cfFrames): pet XP bar below PetFrame. Reload-gated on cfFramesDB.PetXpBar; run from
-- addon.SetupPetXpBar in Init's PLAYER_ENTERING_WORLD pass. Mirrors PetFrameHealthBar's texture (a surface
-- observation) and follows cfDarkMode by consuming the public cfDarkMode.Darken API for the border. XP
-- color is the non-rested-XP purple Blizzard hardcodes in MainMenuBar.lua (we can't mirror MainMenuExpBar's
-- color because it flips to blue when rested).

function addon.SetupPetXpBar()
	if not cfFramesDB.PetXpBar then return end
	-- Hunter only: warlock pets don't gain XP.
	local _, class = UnitClass("player")
	if class ~= "HUNTER" then return end

	local bar = CreateFrame("StatusBar", nil, PetFrame)
	bar:SetSize(40, 6)
	bar:SetPoint("TOP", PetFrame, "BOTTOM", -40, 5)

	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(0, 0, 0, 0.3)

	local border = bar:CreateTexture(nil, "OVERLAY")
	border:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-BarBorder")
	border:SetSize(42, 12)
	border:SetPoint("CENTER", bar, "CENTER", 0, 0)

	local function SyncBarTexture()
		local tex = PetFrameHealthBar:GetStatusBarTexture()
		if tex then bar:SetStatusBarTexture(tex:GetTexture()) end
		-- SetStatusBarTexture clears the bar's color — re-apply (cfQuestXP gotcha).
		bar:SetStatusBarColor(0.58, 0, 0.55)
	end

	-- Follow cfDarkMode's chrome darkness on our own border via the public API, not by observing
	-- PetFrameTexture. No producer -> leave the vanilla border.
	local function SyncBorderColor()
		if cfDarkMode then cfDarkMode.Darken(border) end
	end

	local function Update()
		if not UnitExists("pet") or UnitLevel("pet") == UnitLevel("player") then
			bar:Hide()
			return
		end
		local currXP, nextXP = GetPetExperience()
		if nextXP > 0 then
			bar:SetMinMaxValues(0, nextXP)
			bar:SetValue(currXP)
			bar:Show()
		else
			bar:Hide()
		end
	end

	hooksecurefunc(PetFrameHealthBar, "SetStatusBarTexture", SyncBarTexture)

	local events = CreateFrame("Frame")
	events:SetScript("OnEvent", Update)
	events:RegisterUnitEvent("UNIT_PET", "player")
	events:RegisterEvent("PLAYER_ENTERING_WORLD")
	events:RegisterEvent("PLAYER_LEVEL_UP")
	events:RegisterUnitEvent("UNIT_LEVEL", "pet")
	events:RegisterEvent("UNIT_PET_EXPERIENCE")

	SyncBarTexture()
	SyncBorderColor()
	Update()
end
