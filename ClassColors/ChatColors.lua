local _, addon = ...

local CHAT_TYPES = {
	"SAY", "EMOTE", "YELL",
	"GUILD", "OFFICER",
	"WHISPER",
	"PARTY", "PARTY_LEADER",
	"RAID", "RAID_LEADER", "RAID_WARNING",
	"INSTANCE_CHAT", "INSTANCE_CHAT_LEADER",
	"VOICE_TEXT",
}

local function Apply()
	-- The one CVar write (the documented feature-CVar exception): Blizzard's own class-color
	-- override must be off for SetChatColorNameByClass to take effect.
	SetCVar("chatClassColorOverride", "0")
	for _, chatType in ipairs(CHAT_TYPES) do
		SetChatColorNameByClass(chatType, true)
	end
	for i = 1, 50 do
		SetChatColorNameByClass("CHANNEL" .. i, true)
	end
end

function addon.SetupChatColors()
	if not cfFramesDB.ClassColorText then return end

	Apply()

	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("CHANNEL_UI_UPDATE")
	frame:SetScript("OnEvent", Apply)

	hooksecurefunc("FCF_OpenNewWindow", Apply)
end
