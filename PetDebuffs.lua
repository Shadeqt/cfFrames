local ICON_SIZE = 15
local ICON_SPACING = 2
local DEBUFFS_PER_ROW = 6

local debuffFrames = {}
local container

local function GetOrCreateDebuffFrame(index)
	if debuffFrames[index] then return debuffFrames[index] end

	local btn = CreateFrame("Button", nil, container)
	btn:SetSize(ICON_SIZE, ICON_SIZE)
	local col = (index - 1) % DEBUFFS_PER_ROW
	local row = math.floor((index - 1) / DEBUFFS_PER_ROW)
	btn:SetPoint("TOPLEFT", col * (ICON_SIZE + ICON_SPACING), -row * (ICON_SIZE + ICON_SPACING))

	btn.icon = btn:CreateTexture(nil, "ARTWORK")
	btn.icon:SetAllPoints()

	btn.border = btn:CreateTexture(nil, "OVERLAY")
	btn.border:SetTexture("Interface\\Buttons\\UI-Debuff-Border")
	btn.border:SetPoint("TOPLEFT", btn, "TOPLEFT", -1, 1)
	btn.border:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 1, -1)

	btn.cooldown = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
	btn.cooldown:SetAllPoints()
	btn.cooldown:SetHideCountdownNumbers(true)
	btn.cooldown:SetReverse(true)

	btn:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:SetUnitDebuff("pet", self.auraIndex)
		GameTooltip:Show()
	end)
	btn:SetScript("OnLeave", GameTooltip_Hide)

	debuffFrames[index] = btn
	return btn
end

local function CreateContainer()
	container = CreateFrame("Frame", nil, UIParent)
end

local function Update()
	if not PetFrame or not PetFrame:IsShown() then
		container:Hide()
		return
	end

	container:Show()
	container:ClearAllPoints()
	local firstBuff = _G["PetFrameBuff1"]
	local hasBuffs = firstBuff and firstBuff:IsShown()
	if hasBuffs then
		container:SetPoint("TOPLEFT", firstBuff, "BOTTOMLEFT", 0, -ICON_SPACING)
	else
		container:SetPoint("TOPLEFT", firstBuff, "TOPLEFT", 0, 0)
	end

	local index = 0
	for i = 1, 16 do
		local _, icon, _, debuffType, duration, expirationTime = UnitDebuff("pet", i)
		if not icon then break end
		index = index + 1
		local btn = GetOrCreateDebuffFrame(index)
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

	for i = index + 1, #debuffFrames do
		debuffFrames[i]:Hide()
	end

	local cols = math.min(index, DEBUFFS_PER_ROW)
	local rows = math.ceil(index / DEBUFFS_PER_ROW)
	container:SetSize(
		math.max(1, cols * (ICON_SIZE + ICON_SPACING) - ICON_SPACING),
		math.max(1, rows * (ICON_SIZE + ICON_SPACING) - ICON_SPACING)
	)
end

local function SetupEvents()
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("UNIT_AURA")
	frame:RegisterEvent("UNIT_PET")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:SetScript("OnEvent", function(_, event, arg1)
		if event == "UNIT_AURA" and arg1 ~= "pet" then return end
		Update()
	end)
end

function cfFrames.initPetDebuffs()
	CreateContainer()
	SetupEvents()
	Update()
end
