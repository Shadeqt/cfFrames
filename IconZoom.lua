local ZOOM = { 0.07, 0.93, 0.07, 0.93 }

local function GetIcon(button)
	if not button then return end
	return button.icon or button.Icon or (button.GetName and button:GetName() and _G[button:GetName() .. "Icon"])
end

local function ZoomIcon(target)
	if not target then return end
	if target:IsObjectType("Texture") then
		target:SetTexCoord(unpack(ZOOM))
		return
	end
	local icon = GetIcon(target)
	if icon then icon:SetTexCoord(unpack(ZOOM)) end
end

local function ZoomBar(prefix, count)
	for i = 1, count do
		ZoomIcon(_G[prefix .. i])
	end
end

function cfFrames.initIconZoom()
	cfFrames.registerIconStyle(ZoomIcon)

	ZoomBar("ActionButton", NUM_ACTIONBAR_BUTTONS)
	ZoomBar("MultiBarBottomLeftButton", NUM_ACTIONBAR_BUTTONS)
	ZoomBar("MultiBarBottomRightButton", NUM_ACTIONBAR_BUTTONS)
	ZoomBar("MultiBarRightButton", NUM_ACTIONBAR_BUTTONS)
	ZoomBar("MultiBarLeftButton", NUM_ACTIONBAR_BUTTONS)
	ZoomBar("PetActionButton", NUM_PET_ACTION_SLOTS)

	hooksecurefunc("ActionButton_Update", function(self)
		ZoomIcon(self)
	end)

	if PetActionBar_Update then
		hooksecurefunc("PetActionBar_Update", function()
			ZoomBar("PetActionButton", NUM_PET_ACTION_SLOTS)
		end)
	end

	if AuraButton_Update then
		hooksecurefunc("AuraButton_Update", function(buttonName, index)
			ZoomIcon(_G[buttonName .. index])
		end)
	end

	if TargetFrame_UpdateAuras then
		hooksecurefunc("TargetFrame_UpdateAuras", function()
			for i = 1, MAX_TARGET_BUFFS do
				local btn = _G["TargetFrameBuff" .. i]
				if btn and btn:IsShown() then ZoomIcon(btn) end
			end
			for i = 1, 16 do
				local btn = _G["PetFrameBuff" .. i]
				if btn and btn:IsShown() then ZoomIcon(btn) end
			end
		end)
	end

	-- Castbar icons
	if TargetFrameSpellBar and TargetFrameSpellBar.Icon then
		hooksecurefunc(TargetFrameSpellBar, "Show", function(self)
			if self.Icon then self.Icon:SetTexCoord(unpack(ZOOM)) end
		end)
		hooksecurefunc(TargetFrameSpellBar.Icon, "SetTexture", function(self)
			self:SetTexCoord(unpack(ZOOM))
		end)
	end

	-- Compact frame (party/raid) buff and debuff icons
	-- Blizzard_UnitFrame is LoD, so these functions may not exist yet
	EventUtil.ContinueOnAddOnLoaded("Blizzard_UnitFrame", function()
		if CompactUnitFrame_UtilSetBuff then
			hooksecurefunc("CompactUnitFrame_UtilSetBuff", function(buffFrame)
				if buffFrame and buffFrame.icon then
					buffFrame.icon:SetTexCoord(unpack(ZOOM))
				end
			end)
		end
		if CompactUnitFrame_UtilSetDebuff then
			hooksecurefunc("CompactUnitFrame_UtilSetDebuff", function(_, debuffFrame)
				if debuffFrame and debuffFrame.icon then
					debuffFrame.icon:SetTexCoord(unpack(ZOOM))
				end
			end)
		end
	end)
end
