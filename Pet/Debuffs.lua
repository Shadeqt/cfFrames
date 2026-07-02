local _, addon = ...

-- cfPet (folded into cfFrames): custom debuff grid for the pet, below PetFrame's buff row. Color-codes by
-- debuff type, shows a reverse cooldown spiral, tooltips on hover. Reload-gated on cfFramesDB.PetDebuffs;
-- run from addon.SetupPetDebuffs in Init's PLAYER_ENTERING_WORLD pass. Creates its own button grid (no
-- shared surface), anchored under Blizzard's first pet buff icon.

local ICON_SIZE = 15
local ICON_SPACING = 2
local DEBUFFS_PER_ROW = 6
local MAX_DEBUFFS = 16

function addon.SetupPetDebuffs()
	if not cfFramesDB.PetDebuffs then return end
	-- Hunter/Warlock only: nobody else has a persistent pet in Classic Era.
	local _, class = UnitClass("player")
	if class ~= "HUNTER" and class ~= "WARLOCK" then return end

	local container = CreateFrame("Frame", nil, PetFrame)
	local frames = {}

	local function GetOrCreateFrame(index)
		if frames[index] then return frames[index] end

		local btn = CreateFrame("Button", nil, container)
		btn:SetSize(ICON_SIZE, ICON_SIZE)
		local col = (index - 1) % DEBUFFS_PER_ROW
		local row = math.floor((index - 1) / DEBUFFS_PER_ROW)
		btn:SetPoint("TOPLEFT", col * (ICON_SIZE + ICON_SPACING), -row * (ICON_SIZE + ICON_SPACING))

		btn.icon = btn:CreateTexture(nil, "ARTWORK")
		btn.icon:SetAllPoints()

		-- Share cfDarkMode's aura-icon zoom so these debuffs crop like every other square buff/debuff.
		-- Debuff -> zoom only; the dispel-type colored border below is this grid's own overlay. nil-check:
		-- no cfDarkMode = no zoom, which is correct (nothing to match).
		if cfDarkMode then cfDarkMode.Zoom(btn) end

		btn.border = btn:CreateTexture(nil, "OVERLAY")
		-- UI-Debuff-Overlays is a white/tintable border; the plain UI-Debuff-Border is
		-- pre-colored red, so SetVertexColor on it just multiplies against red.
		btn.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
		btn.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
		btn.border:SetPoint("TOPLEFT", -1, 1)
		btn.border:SetPoint("BOTTOMRIGHT", 1, -1)

		btn.cooldown = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
		btn.cooldown:SetAllPoints()
		btn.cooldown:SetReverse(true)
		-- Keep the swirl, drop the countdown text (Blizzard's built-in number on the spiral).
		btn.cooldown:SetHideCountdownNumbers(true)

		btn:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
			GameTooltip:SetUnitDebuff("pet", self.auraIndex)
			GameTooltip:Show()
		end)
		btn:SetScript("OnLeave", GameTooltip_Hide)

		frames[index] = btn
		return btn
	end

	local function Update()
		container:ClearAllPoints()
		-- Anchor below PetFrameBuff1 (Blizzard's first pet buff icon) when buffs are shown,
		-- else sit where it would.
		local firstBuff = PetFrameBuff1
		if firstBuff and firstBuff:IsShown() then
			container:SetPoint("TOPLEFT", firstBuff, "BOTTOMLEFT", 0, -ICON_SPACING)
		else
			container:SetPoint("TOPLEFT", firstBuff, "TOPLEFT", 0, 0)
		end

		local count = 0
		for i = 1, MAX_DEBUFFS do
			local _, icon, _, debuffType, duration, expirationTime = UnitDebuff("pet", i)
			if not icon then break end
			count = i
			local btn = GetOrCreateFrame(i)
			btn.auraIndex = i
			btn.icon:SetTexture(icon)

			local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"]
			btn.border:SetVertexColor(color.r, color.g, color.b)

			if duration and duration > 0 then
				btn.cooldown:SetCooldown(expirationTime - duration, duration)
				btn.cooldown:Show()
			else
				btn.cooldown:Hide()
			end
			btn:Show()
		end

		for i = count + 1, #frames do frames[i]:Hide() end

		local cols = math.min(count, DEBUFFS_PER_ROW)
		local rows = math.ceil(count / DEBUFFS_PER_ROW)
		container:SetSize(
			math.max(1, cols * (ICON_SIZE + ICON_SPACING) - ICON_SPACING),
			math.max(1, rows * (ICON_SIZE + ICON_SPACING) - ICON_SPACING)
		)
	end

	local events = CreateFrame("Frame")
	events:SetScript("OnEvent", function(_, event, arg1)
		if event == "UNIT_AURA" and arg1 ~= "pet" then return end
		if event == "UNIT_PET" and arg1 ~= "player" then return end
		Update()
	end)
	events:RegisterEvent("UNIT_AURA")
	events:RegisterEvent("UNIT_PET")
	events:RegisterEvent("PLAYER_ENTERING_WORLD")
	Update()
end
