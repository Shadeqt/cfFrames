-- ExperienceBarQuests.lua — Yellow overlay on XP bar showing pending quest XP
local M = cfFrames.MODULES

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
	if not bar or not cfFrames.questOverlay then return end
	if not cfFramesDB[M.QUESTIE_INTEGRATION] then cfFrames.questOverlay:Hide() return end

	local currentXP = UnitXP("player")
	local maxXP = UnitXPMax("player")
	if maxXP == 0 then cfFrames.questOverlay:Hide() return end

	local questXP = GetCompletedQuestXP()
	if questXP == 0 then cfFrames.questOverlay:Hide() return end

	local cappedQuestXP = math.min(questXP, maxXP - currentXP)
	cfFrames.questOverlay:SetMinMaxValues(0, maxXP)
	cfFrames.questOverlay:SetValue(currentXP + cappedQuestXP)
	cfFrames.questOverlay:Show()
end

local function CreateOverlay()
	local bar = MainMenuExpBar
	if not bar or cfFrames.questOverlay then return end

	local overlay = CreateFrame("StatusBar", nil, bar)
	overlay:SetAllPoints(bar)
	overlay:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	local c = QuestDifficultyColors["difficult"]
	overlay:SetStatusBarColor(c.r, c.g, c.b)
	overlay:SetMinMaxValues(0, 1)
	overlay:SetValue(0)
	overlay:SetFrameLevel(1)
	overlay:Hide()
	cfFrames.questOverlay = overlay
end

local frame = CreateFrame("Frame")

local function Enable()
	CreateOverlay()
	frame:RegisterEvent("QUEST_LOG_UPDATE")
	frame:RegisterEvent("PLAYER_XP_UPDATE")
	frame:RegisterEvent("PLAYER_LEVEL_UP")
	UpdateOverlay()
end

local function Disable()
	frame:UnregisterAllEvents()
	if cfFrames.questOverlay then cfFrames.questOverlay:Hide() end
end

frame:SetScript("OnEvent", function()
	UpdateOverlay()
end)

-- Wait for Questie to load before registering
local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("ADDON_LOADED")
loadFrame:SetScript("OnEvent", function(self, event, arg1)
	if arg1 ~= "cfFrames" and arg1 ~= "Questie" then return end
	if not cfFrames or not QuestieLoader then return end

	self:UnregisterEvent("ADDON_LOADED")
	cfFrames:RegisterModule(M.QUESTIE_INTEGRATION, Enable, Disable)
	if cfFramesDB and cfFramesDB[M.QUESTIE_INTEGRATION] then
		Enable()
	end
end)
