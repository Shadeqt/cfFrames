local _, addon = ...

-- cfPet (folded into cfFrames): show the pet's level as a small badge below-left of PetFrame, but only
-- when it differs from the player's (which is most levels while leveling a Hunter pet). Reload-gated on
-- cfFramesDB.PetLevelBadge; run from addon.SetupPetLevel in Init's PLAYER_ENTERING_WORLD pass. Follows
-- cfDarkMode by consuming the public cfDarkMode.Darken API for the badge ring -- with no producer present
-- the ring stays vanilla.

function addon.SetupPetLevel()
	if not cfFramesDB.PetLevelBadge then return end
	-- Hunter only: warlock pets always match player level; no other class has a leveling pet.
	local _, class = UnitClass("player")
	if class ~= "HUNTER" then return end

	local frame = CreateFrame("Frame", nil, PetFrame)
	frame:SetFrameLevel(PetFrame:GetFrameLevel() + 10)

	local border = frame:CreateTexture(nil, "OVERLAY")
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	border:SetSize(38, 38)
	border:SetPoint("CENTER", PetFrame, "BOTTOMLEFT", 15, 8)

	-- Follow cfDarkMode's chrome darkness on the badge ring via the public API, exactly as XpBar.lua does.
	-- No producer -> the ring stays vanilla.
	if cfDarkMode then cfDarkMode.Darken(border) end

	local bg = frame:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall")
	bg:SetVertexColor(0, 0, 0, 0.3)
	bg:SetSize(16, 16)
	bg:SetPoint("CENTER", border, "CENTER", -7.5, 8)

	local text = frame:CreateFontString(nil, "OVERLAY", "GameNormalNumberFont")
	local font, _, flags = text:GetFont()
	text:SetFont(font, 8, flags)
	text:SetPoint("CENTER", border, "CENTER", -7.5, 8)

	-- playerLevel override: while PLAYER_LEVEL_UP fires, UnitLevel("player") still reports the OLD level, so
	-- a ding that opens a pet/player gap (pet was at your level, now one below) would compare stale-equal and
	-- leave the badge hidden. The event carries the NEW level as its first arg -- passing it in reads the
	-- correct level with no frame-defer timing guess, so the badge updates immediately. Other callers omit it
	-- and fall back to UnitLevel("player"), which is current outside that event.
	local function Update(playerLevel)
		playerLevel = playerLevel or UnitLevel("player")
		if UnitExists("pet") and UnitLevel("pet") ~= playerLevel then
			text:SetText(UnitLevel("pet"))
			text:Show(); bg:Show(); border:Show()
		else
			text:Hide(); bg:Hide(); border:Hide()
		end
	end

	local events = CreateFrame("Frame")
	events:SetScript("OnEvent", function(_, event, newLevel)
		Update(event == "PLAYER_LEVEL_UP" and newLevel or nil)
	end)
	events:RegisterUnitEvent("UNIT_PET", "player")
	events:RegisterEvent("PLAYER_ENTERING_WORLD")
	events:RegisterEvent("PLAYER_LEVEL_UP")
	events:RegisterUnitEvent("UNIT_LEVEL", "pet")
	Update()
end
