local M = cff.MODULES
local V = cff.VALUES

local bars = {}

local function GetPartyFrame(index)
	return _G["PartyMemberFrame" .. index]
end

local function GetPartyHealthBar(index)
	return _G["PartyMemberFrame" .. index .. "HealthBar"]
end

local function CreatePartyCastbar(index)
	local partyFrame = GetPartyFrame(index)
	local hp = GetPartyHealthBar(index)
	if not partyFrame or not hp then return end

	local w, h = hp:GetWidth(), hp:GetHeight()
	local bar = cff.CreateCastbar(partyFrame, "party" .. index, w, h)
	bar:SetPoint("TOP", partyFrame, "BOTTOM", 16, 5)
	bar:SetScale(cfFramesDB[V.PartyCastbarScale])

	bar.Icon:SetScale(cfFramesDB[V.PartyCastbarIconScale])
	if not cfFramesDB[M.PartyCastbarIcon] then bar.Icon:Hide() end

	if cfFramesDB[M.DarkModeCastbars] then
		cff.SaveAndDarken(bar.Border)
	end

	cff.StylePetCastbarIcon(bar)
	hooksecurefunc(bar, "Show", function(self)
		cff.StylePetCastbarIcon(self)
		if not cfFramesDB[M.PartyCastbarIcon] then self.Icon:Hide() end
	end)

	bars[index] = bar
	return bar
end

local function GetPartyCastbar(index)
	if bars[index] then return bars[index] end
	return CreatePartyCastbar(index)
end

function cff.EnablePartyCastbar()
	if not cfFramesDB[M.PartyCastbar] then return end

	for i = 1, 4 do
		local bar = GetPartyCastbar(i)
		if bar then
			CastingBarFrame_SetUnit(bar, "party" .. i)
			if UnitCastingInfo("party" .. i) or UnitChannelInfo("party" .. i) then
				CastingBarFrame_OnEvent(bar, "PLAYER_ENTERING_WORLD")
			end
		end
	end
end

function cff.DisablePartyCastbar()
	for i = 1, 4 do
		if bars[i] then
			CastingBarFrame_SetUnit(bars[i], nil)
			bars[i]:Hide()
		end
	end
end

function cff.EnablePartyCastbarIcon()
	if not cfFramesDB[M.PartyCastbarIcon] then return end
	for i = 1, 4 do
		if bars[i] and bars[i].Icon then bars[i].Icon:Show() end
	end
end

function cff.DisablePartyCastbarIcon()
	for i = 1, 4 do
		if bars[i] and bars[i].Icon then bars[i].Icon:Hide() end
	end
end

cff.RegisterCallback(M.StatusBar, function()
	for i = 1, 4 do
		if bars[i] and cfFramesDB[M.StatusBar] then
			bars[i]:SetStatusBarTexture(cff.GetStatusBarTexture())
		end
	end
end)

cff.RegisterCallback(M.DarkMode, function()
	for i = 1, 4 do
		if bars[i] and cfFramesDB[M.DarkModeCastbars] then
			cff.SaveAndDarken(bars[i].Border)
		end
	end
end)

-- TEST: show party castbars permanently at full (remove later)
EventUtil.ContinueOnAddOnLoaded("cfFrames", function()
	for i = 1, 4 do
		local partyFrame = GetPartyFrame(i)
		local hp = GetPartyHealthBar(i)
		print("Party" .. i, "frame:", partyFrame and "yes" or "nil", "hp:", hp and hp:GetWidth() or "nil")
		if partyFrame then
			partyFrame:Show()
			partyFrame.hideDesired = nil
			hooksecurefunc(partyFrame, "Hide", function(self) self:Show() end)
			if not hp or hp:GetWidth() == 0 then
				-- No health bar data when solo, create castbar with fallback size
				local bar = cff.CreateCastbar(partyFrame, "party" .. i, 60, 8)
				bar:SetPoint("TOP", partyFrame, "BOTTOM", 16, 5)
				bar:SetScript("OnUpdate", nil)
				bar:SetMinMaxValues(0, 1)
				bar:SetValue(1)
				bar:SetStatusBarColor(1, 0.7, 0)
				bar.Icon:SetTexture("Interface\\Icons\\Spell_Nature_Lightning")
				bar.Icon:Show()
				bar:Show()
				bars[i] = bar
			else
				local bar = GetPartyCastbar(i)
				if bar then
					bar:SetScript("OnUpdate", nil)
					bar:SetMinMaxValues(0, 1)
					bar:SetValue(1)
					bar:SetStatusBarColor(1, 0.7, 0)
					bar.Icon:SetTexture("Interface\\Icons\\Spell_Nature_Lightning")
					bar.Icon:Show()
					bar:Show()
				end
			end
		end
	end
end)
