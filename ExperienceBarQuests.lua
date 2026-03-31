local overlay

local function GetCompletedQuestXP()
	local totalXP = 0
	for i = 1, GetNumQuestLogEntries() do
		local _, _, _, isHeader, _, isComplete = GetQuestLogTitle(i)
		if not isHeader then
			SelectQuestLogEntry(i)
			if isComplete or GetNumQuestLeaderBoards() == 0 then
				totalXP = totalXP + (GetQuestLogRewardXP() or 0)
			end
		end
	end
	return totalXP
end

local function UpdateOverlay()
	local bar = MainMenuExpBar
	if not bar or not overlay then return end

	local currentXP = UnitXP("player")
	local maxXP = UnitXPMax("player")
	if maxXP == 0 then overlay:Hide() return end

	local questXP = GetCompletedQuestXP()
	if questXP == 0 then overlay:Hide() return end

	local cappedQuestXP = math.min(questXP, maxXP - currentXP)
	overlay:SetMinMaxValues(0, maxXP)
	overlay:SetValue(currentXP + cappedQuestXP)
	overlay:Show()
end

local function CreateOverlay()
	local bar = MainMenuExpBar
	if not bar then return end

	overlay = CreateFrame("StatusBar", nil, bar)
	overlay:SetAllPoints(bar)
	overlay:SetStatusBarTexture(cfFrames.getBarTexture())
	overlay:GetStatusBarTexture():SetDrawLayer("BACKGROUND", -1)
	local c = QuestDifficultyColors["difficult"]
	overlay:SetStatusBarColor(c.r, c.g, c.b)
	overlay:SetMinMaxValues(0, 1)
	overlay:SetValue(0)
	overlay:SetFrameLevel(bar:GetFrameLevel())
	overlay:Hide()
end

function cfFrames.initExperienceBarQuests()
	CreateOverlay()
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("QUEST_LOG_UPDATE")
	frame:RegisterEvent("PLAYER_XP_UPDATE")
	frame:RegisterEvent("PLAYER_LEVEL_UP")
	frame:SetScript("OnEvent", UpdateOverlay)
	UpdateOverlay()
end
