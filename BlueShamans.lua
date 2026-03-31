local PINK = "|cfff48cba"
local BLUE_CODE = "|cff0070de"

function cfFrames.initBlueShamans()
	local BLUE = CreateColor(0, 0.44, 0.87)
	BLUE.colorStr = "ff0070de"

	RAID_CLASS_COLORS["SHAMAN"] = BLUE

	-- Chat config legend uses inline color codes; fix on each show
	local localShaman = LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE["SHAMAN"] or "Shaman"

	local function RecolorLegend(frame)
		for _, region in pairs({ frame:GetRegions() }) do
			if region.GetText and region.SetText then
				local text = region:GetText()
				if text and text:find(localShaman, 1, true) then
					region:SetText(text:gsub(PINK .. localShaman, BLUE_CODE .. localShaman))
				end
			end
		end
	end

	EventUtil.ContinueOnAddOnLoaded("Blizzard_ChatFrameBase", function()
		if ChatConfigFrame then
			ChatConfigFrame:HookScript("OnShow", function()
				if ChatConfigChatSettingsClassColorLegend then
					RecolorLegend(ChatConfigChatSettingsClassColorLegend)
				end
				if ChatConfigChannelSettingsClassColorLegend then
					RecolorLegend(ChatConfigChannelSettingsClassColorLegend)
				end
			end)
		end
	end)
end
