local _, addon = ...
local classNameToToken = addon.classNameToToken

local PINK_SHAMAN = "|cfff48cba"
local localShaman = LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE["SHAMAN"] or "Shaman"

local function StripPinkShaman(text)
	if text:find(PINK_SHAMAN .. localShaman, 1, true) then
		return text:gsub(PINK_SHAMAN .. localShaman .. "|r", localShaman)
	end
	return text
end

local function ColorClassInText(fontString)
	local text = fontString and fontString:GetText()
	if not text then return end
	text = StripPinkShaman(text)
	for className, token in pairs(classNameToToken) do
		if text:find(className, 1, true) then
			local color = RAID_CLASS_COLORS[token]
			if color then
				fontString:SetText(text:gsub(className, color:WrapTextInColorCode(className)))
				return true
			end
		end
	end
end

local function ColorByClass(fontString, class)
	local c = RAID_CLASS_COLORS[class]
	if c then fontString:SetTextColor(c.r, c.g, c.b) end
end

function addon.SetupClassNames()
	-- Character frame
	hooksecurefunc("PaperDollFrame_SetLevel", function()
		ColorClassInText(CharacterLevelText)
	end)

	-- Inspect frame (LoD)
	EventUtil.ContinueOnAddOnLoaded("Blizzard_InspectUI", function()
		hooksecurefunc("InspectPaperDollFrame_SetLevel", function()
			ColorClassInText(InspectLevelText)
		end)
	end)

	-- Guild member detail (guard against our own SetText re-triggering the hook)
	local updating = false
	hooksecurefunc(GuildMemberDetailLevel, "SetText", function(self)
		if updating then return end
		updating = true
		ColorClassInText(self)
		updating = false
	end)

	-- Guild list
	hooksecurefunc("GuildStatus_Update", function()
		local offset = FauxScrollFrame_GetOffset(GuildListScrollFrame)
		for i = 1, GUILDMEMBERS_TO_DISPLAY do
			local _, _, _, _, _, _, _, _, online, _, class = GetGuildRosterInfo(offset + i)
			if online then
				ColorByClass(_G["GuildFrameButton" .. i .. "Class"], class)
			end
		end
	end)

	-- Friends list
	hooksecurefunc("FriendsFrame_UpdateFriendButton", function(button)
		if button.buttonType ~= FRIENDS_BUTTON_TYPE_WOW then return end
		local info = C_FriendList.GetFriendInfoByIndex(button.id)
		if not info or not info.className or not info.connected then return end
		ColorClassInText(button.name)
	end)

	-- Friends tooltip
	FriendsTooltip:HookScript("OnShow", function()
		ColorClassInText(FriendsTooltipGameAccount1Name)
	end)

	-- GameTooltip
	GameTooltip:HookScript("OnTooltipSetUnit", function(self)
		local _, unit = self:GetUnit()
		if not unit or not UnitIsPlayer(unit) then return end
		for i = 2, self:NumLines() do
			if ColorClassInText(_G["GameTooltipTextLeft" .. i]) then break end
		end
	end)

	-- Chat config legend (LoD)
	EventUtil.ContinueOnAddOnLoaded("Blizzard_ChatFrameBase", function()
		if not ChatConfigFrame then return end
		ChatConfigFrame:HookScript("OnShow", function()
			local legends = { ChatConfigChatSettingsClassColorLegend, ChatConfigChannelSettingsClassColorLegend }
			for _, frame in pairs(legends) do
				if frame then
					for _, region in pairs({ frame:GetRegions() }) do
						if region.GetText then
							ColorClassInText(region)
						end
					end
				end
			end
		end)
	end)
end
