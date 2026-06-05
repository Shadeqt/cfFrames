local _, addon = ...

local function ColorByLevel(fontString, level)
	if not level or level <= 0 then return end
	local c = GetQuestDifficultyColor(level)
	fontString:SetTextColor(c.r, c.g, c.b)
end

function addon.SetupLevelColors()
	-- Target frame
	hooksecurefunc("TargetFrame_CheckLevel", function()
		ColorByLevel(TargetFrameTextureFrameLevelText, UnitLevel("target"))
	end)

	-- Who list
	hooksecurefunc("WhoList_Update", function()
		local offset = FauxScrollFrame_GetOffset(WhoListScrollFrame)
		for i = 1, WHOS_TO_DISPLAY do
			local info = C_FriendList.GetWhoInfo(i + offset)
			if info then
				ColorByLevel(_G["WhoFrameButton" .. i .. "Level"], info.level)
			end
		end
	end)

	-- Guild list
	hooksecurefunc("GuildStatus_Update", function()
		local offset = FauxScrollFrame_GetOffset(GuildListScrollFrame)
		for i = 1, GUILDMEMBERS_TO_DISPLAY do
			local _, _, _, level, _, _, _, _, online = GetGuildRosterInfo(offset + i)
			if level and online then
				ColorByLevel(_G["GuildFrameButton" .. i .. "Level"], level)
			end
		end
	end)

	-- Friends list (color the level number inside the button text)
	hooksecurefunc("FriendsFrame_UpdateFriendButton", function(button)
		if button.buttonType ~= FRIENDS_BUTTON_TYPE_WOW then return end
		local info = C_FriendList.GetFriendInfoByIndex(button.id)
		if not info or not info.connected then return end
		local text = button.name:GetText()
		if not text then return end
		if info.level and info.level > 0 then
			local c = GetQuestDifficultyColor(info.level)
			text = text:gsub("%d+", CreateColor(c.r, c.g, c.b):WrapTextInColorCode("%1"), 1)
			button.name:SetText(text)
		end
	end)

	-- If a target somehow already exists at setup, color its level now; normally there's
	-- none (the target is cleared on reload/login), so this is a guarded no-op and the
	-- CheckLevel hook above handles every target acquired afterward.
	if UnitExists("target") then TargetFrame_CheckLevel() end
end
