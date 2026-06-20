local _, addon = ...

-- BiggerUnitFrames (cfFramesTest's newest implementation, UnitFramesImproved variant): enlarge the
-- player + target health bars and swap in the UnitFramesImproved frame art. Reload-gated on
-- cfFramesDB.BiggerHealthbar (the DB key is kept from the old single-file BiggerHealthbar feature so
-- saved settings + the GUI checkbox carry over). Layout offsetting uses addon.ApplyOffset/KeepOffset
-- (promoted to Init.lua).
--
-- Everything but the addon.SetupBiggerHealthbar entry point is file-local: the player and target paths
-- share only the sizing constants below, so no state is published on the addon table.

local DIR           = "Interface\\AddOns\\cfFrames\\Media\\UnitFramesImproved\\"
local NORMAL_BORDER = DIR .. "UI-TargetingFrame"
local PLAYER_STATUS = DIR .. "UI-Player-Status"

-- Health-bar sizing for the taller bar window in the UnitFramesImproved art (player + target share it).
-- The bar grows downward from its top anchor, so the offset slides the enlarged bar back up into the
-- window; the name rides up by the same amount. The bar's status text + the Dead/Corpse overlay follow
-- the bar with the text offset.
local HEALTH_BAR_HEIGHT      = 28
local VERTICAL_OFFSET        = 18
local HEALTH_BAR_TEXT_OFFSET = 10

-- Player: swap in the UnitFramesImproved frame art and enlarge the player health bar. This art lines up
-- with Blizzard's default level/glow/icon positions, so it needs no alignment nudges -- just textures +
-- bar enlarge + the name/text raise the taller bar window requires. KeepOffset re-asserts past Blizzard's
-- deferred layout passes (the player frame isn't re-applied on an event, unlike the target).
local function SetupPlayer()
	if PlayerFrameTexture then PlayerFrameTexture:SetTexture(NORMAL_BORDER) end
	if PlayerStatusTexture then PlayerStatusTexture:SetTexture(PLAYER_STATUS) end
	addon.KeepOffset(PlayerName, VERTICAL_OFFSET)
	if PlayerFrameHealthBar then
		PlayerFrameHealthBar:SetHeight(HEALTH_BAR_HEIGHT)
		addon.KeepOffset(PlayerFrameHealthBar, VERTICAL_OFFSET)
		-- Raise the bar's native text to stay centered in the enlarged bar.
		addon.KeepOffset(PlayerFrameHealthBar.TextString, HEALTH_BAR_TEXT_OFFSET)
		addon.KeepOffset(PlayerFrameHealthBar.LeftText,   HEALTH_BAR_TEXT_OFFSET)
		addon.KeepOffset(PlayerFrameHealthBar.RightText,  HEALTH_BAR_TEXT_OFFSET)
	end
end

-- Target border art per unit classification; anything not listed falls back to NORMAL_BORDER.
local BORDER_TEXTURE_BY_CLASSIFICATION = {
	worldboss = DIR .. "UI-TargetingFrame-Elite",
	elite     = DIR .. "UI-TargetingFrame-Elite",
	rareelite = DIR .. "UI-TargetingFrame-Rare-Elite",
	rare      = DIR .. "UI-TargetingFrame-Rare",
}

-- Target: enlarge the target health bar and swap in the UnitFramesImproved classification border art,
-- raising the name and "Dead" overlay onto the bigger bar. Re-applied inside TargetFrame_CheckClassification
-- (Blizzard fires it per target change and resets the texture there), so ApplyOffset (self-correcting,
-- re-applied each change) is used rather than the persistent KeepOffset hook.
local function ApplyTargetArt()
	if TargetFrameTextureFrameTexture then
		local classification = UnitClassification("target")
		TargetFrameTextureFrameTexture:SetTexture(
			BORDER_TEXTURE_BY_CLASSIFICATION[classification] or NORMAL_BORDER)
	end
	addon.ApplyOffset(TargetFrameTextureFrameName, VERTICAL_OFFSET)
	if TargetFrameHealthBar then
		TargetFrameHealthBar:SetHeight(HEALTH_BAR_HEIGHT)
		addon.ApplyOffset(TargetFrameHealthBar, VERTICAL_OFFSET)
	end
	addon.ApplyOffset(TargetFrameTextureFrameDeadText, HEALTH_BAR_TEXT_OFFSET)

	-- Target dark backing: TargetFrameNameBackground is the target's only backing region. Trim its
	-- default 19px to 18px so its bottom edge clears the raised bar, and set the translucent black that
	-- HealthbarColor also writes (they agree, and HealthbarColor's SetVertexColor hook guards against a
	-- write loop). The trim is owned here (it only matters once this feature raised the bar).
	if TargetFrameNameBackground then
		TargetFrameNameBackground:SetHeight(18)
		TargetFrameNameBackground:SetVertexColor(0, 0, 0, 0.5)
	end
end

local function SetupTarget()
	hooksecurefunc("TargetFrame_CheckClassification", ApplyTargetArt)
	if UnitExists("target") then ApplyTargetArt() end  -- catch a target already present (e.g. after /reload)
end

-- Reload-gated; called once from Init's PLAYER_ENTERING_WORLD pass.
function addon.SetupBiggerHealthbar()
	if not cfFramesDB.BiggerHealthbar then return end
	SetupPlayer()
	SetupTarget()
end
