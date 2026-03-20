-- ExperienceBarQuests.lua — Yellow overlay on XP bar showing pending quest XP
local questOverlay = nil

local function GetCompletedQuestXP()
	if not QuestieLoader then return 0 end
	local QuestXP = QuestieLoader:ImportModule("QuestXP")
	if not QuestXP or not QuestXP.GetQuestLogRewardXP then return 0 end

	local totalXP = 0
	for i = 1, GetNumQuestLogEntries() do
		local _, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(i)
		if not isHeader and questID and isComplete and isComplete > 0 then
			totalXP = totalXP + (QuestXP:GetQuestLogRewardXP(questID) or 0)
		end
	end
	return totalXP
end

local function UpdateOverlay()
	local bar = MainMenuExpBar
	if not bar or not questOverlay then return end

	local currentXP = UnitXP("player")
	local maxXP = UnitXPMax("player")
	if maxXP == 0 then questOverlay:Hide() return end

	local questXP = GetCompletedQuestXP()
	if questXP == 0 then questOverlay:Hide() return end

	local barWidth = bar:GetWidth()
	local currentFraction = currentXP / maxXP
	local questFraction = math.min(questXP, maxXP - currentXP) / maxXP

	questOverlay:ClearAllPoints()
	questOverlay:SetPoint("LEFT", bar, "LEFT", currentFraction * barWidth, 0)
	questOverlay:SetWidth(math.max(questFraction * barWidth, 0.001))
	questOverlay:Show()
end

local function CreateOverlay()
	local bar = MainMenuExpBar
	if not bar or questOverlay then return end

	questOverlay = CreateFrame("StatusBar", nil, bar)
	questOverlay:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	local c = QuestDifficultyColors["difficult"]
	questOverlay:SetStatusBarColor(c.r, c.g, c.b)
	questOverlay:SetMinMaxValues(0, 1)
	questOverlay:SetValue(1)
	questOverlay:SetHeight(bar:GetHeight())
	questOverlay:SetFrameLevel(1)
	questOverlay:Hide()
	cfFrames.questOverlay = questOverlay
end

local loaded = {}
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("PLAYER_XP_UPDATE")
frame:RegisterEvent("PLAYER_LEVEL_UP")

frame:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 == "cfFrames" or arg1 == "Questie" then
			loaded[arg1] = true
		end
		if loaded["cfFrames"] and loaded["Questie"] then
			self:UnregisterEvent("ADDON_LOADED")
			CreateOverlay()
			UpdateOverlay()
		end
	else
		UpdateOverlay()
	end
end)
