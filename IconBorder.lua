local EDGE_FILE
local MASK_PATH = "Interface\\AddOns\\cfFrames\\Media\\UIFrameIconMask"

local function AddMask(icon, parent)
	if not icon._roundedMask and icon.AddMaskTexture then
		local mask = parent:CreateMaskTexture()
		mask:SetTexture(MASK_PATH)
		mask:SetAllPoints(icon)
		icon:AddMaskTexture(mask)
		icon._roundedMask = mask
	end
end

local function AddBorder(target)
	if not target then return end

	-- Resolve icon and parent frame
	local parent, icon
	if target:IsObjectType("Texture") then
		icon = target
		parent = target:GetParent()
	else
		parent = target
		local name = parent:GetName()
		if name and name:match("Debuff") then return end
		icon = parent.icon or parent.Icon or (name and _G[name .. "Icon"])
		if not icon then return end
	end

	AddMask(icon, parent)

	if parent.cfIconBorder then return end

	local border = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	border:SetBackdrop({ edgeFile = EDGE_FILE, edgeSize = 8.5 })
	border:SetPoint("TOPLEFT", icon, -1, 1)
	border:SetPoint("BOTTOMRIGHT", icon, 1, -1)
	parent.cfIconBorder = border
	cfFrames.styleRegions(border)
end

function cfFrames.initIconBorder()
	EDGE_FILE = cfFramesDB.IconBorder
	cfFrames.registerIconStyle(AddBorder)

	-- Action bar button borders
	local barNames = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton", "MultiBarLeftButton" }
	for _, barName in ipairs(barNames) do
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			local btn = _G[barName .. i]
			if btn then AddBorder(btn) end
		end
	end

	if AuraButton_Update then
		hooksecurefunc("AuraButton_Update", function(buttonName, index)
			AddBorder(_G[buttonName .. index])
		end)
	end

	if TargetFrame_UpdateAuras then
		hooksecurefunc("TargetFrame_UpdateAuras", function()
			for i = 1, MAX_TARGET_BUFFS do
				local btn = _G["TargetFrameBuff" .. i]
				if btn and btn:IsShown() then AddBorder(btn) end
			end
			for i = 1, 16 do
				local btn = _G["PetFrameBuff" .. i]
				if btn and btn:IsShown() then AddBorder(btn) end
			end
		end)
	end

	-- Target castbar icon
	if TargetFrameSpellBar and TargetFrameSpellBar.Icon then
		AddBorder(TargetFrameSpellBar.Icon)
	end

	EventUtil.ContinueOnAddOnLoaded("Blizzard_UnitFrame", function()
		if CompactUnitFrame_UtilSetBuff then
			hooksecurefunc("CompactUnitFrame_UtilSetBuff", function(buffFrame)
				AddBorder(buffFrame)
			end)
		end
	end)

	local petFrame = CreateFrame("Frame")
	petFrame:RegisterUnitEvent("UNIT_AURA", "pet")
	petFrame:SetScript("OnEvent", function()
		for i = 1, 16 do
			local btn = _G["PetFrameBuff" .. i]
			if not btn then break end
			if btn:IsShown() then AddBorder(btn) end
		end
	end)
end
