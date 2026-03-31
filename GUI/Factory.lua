local Factory = {}
cfFrames.Factory = Factory

local function AddTooltip(frame, text)
	if not text then return end
	frame:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(text)
		GameTooltip:Show()
	end)
	frame:HookScript("OnLeave", GameTooltip_Hide)
end

function Factory.CreateScrollPanel(panel)
	local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", 0, 0)
	scrollFrame:SetPoint("BOTTOMRIGHT", -26, 0)

	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetSize(600, 1)
	scrollFrame:SetScrollChild(scrollChild)

	scrollChild:SetScript("OnSizeChanged", function(self)
		self:SetWidth(scrollFrame:GetWidth())
	end)

	panel:HookScript("OnShow", function()
		local top = scrollChild:GetTop()
		if not top then return end
		local lowestBottom = top
		for _, child in pairs({ scrollChild:GetChildren() }) do
			local bottom = child:GetBottom()
			if bottom and bottom < lowestBottom then lowestBottom = bottom end
		end
		scrollChild:SetHeight(top - lowestBottom + 20)
	end)

	return scrollChild
end

function Factory.CreateTitle(anchor, text)
	local title = anchor:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, 0)
	title:SetText(text)
	return title
end

function Factory.CreateHeader(anchor, text)
	local parent = anchor:GetParent() or anchor

	local sep = parent:CreateTexture(nil, "ARTWORK")
	sep:SetHeight(1)
	sep:SetColorTexture(0.4, 0.4, 0.4, 0.4)
	sep:SetPoint("LEFT", parent, "LEFT", 0, 0)
	sep:SetPoint("TOP", anchor, "BOTTOM", 0, -10)
	sep:SetPoint("RIGHT", parent, "RIGHT", -16, 0)

	local header = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	header:SetPoint("LEFT", parent, "LEFT", 0, 0)
	header:SetPoint("TOP", sep, "BOTTOM", 0, -6)
	header:SetText(text)
	return header
end

function Factory.CreateCheckbox(anchor, label, dbKey, col2, tooltip)
	local parent = anchor:GetParent() or anchor
	local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
	if col2 then
		cb:SetPoint("TOPLEFT", anchor, "TOPLEFT", col2, 0)
	else
		cb:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6)
	end
	cb.Text:SetText(label)
	cb:SetHitRectInsets(0, -cb.Text:GetStringWidth(), 0, 0)
	cb:SetScript("OnShow", function(self)
		self:SetChecked(cfFramesDB and cfFramesDB[dbKey])
	end)
	cb:SetScript("OnClick", function(self)
		cfFramesDB[dbKey] = self:GetChecked()
	end)
	AddTooltip(cb, tooltip)
	return cb
end

function Factory.CreateDropdown(anchor, label, dbKey, options, tooltip)
	local parent = anchor:GetParent() or anchor
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(200, 40)
	frame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6)

	local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	title:SetPoint("TOPLEFT", 4, 0)
	title:SetText(label)

	local dd = CreateFrame("Frame", nil, frame, "UIDropDownMenuTemplate")
	dd:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -19, -2)
	UIDropDownMenu_SetWidth(dd, 160)

	local function GetLabel()
		local val = cfFramesDB and cfFramesDB[dbKey]
		for _, o in ipairs(options) do
			if o.value == val then return o.label end
		end
		return options[1].label
	end

	UIDropDownMenu_Initialize(dd, function(_, level)
		local val = cfFramesDB and cfFramesDB[dbKey]
		for _, o in ipairs(options) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = o.label
			info.value = o.value
			info.checked = (o.value == val) or (not val and o.value == options[1].value)
			info.func = function(self)
				cfFramesDB[dbKey] = self.value
				CloseDropDownMenus()
				UIDropDownMenu_SetText(dd, GetLabel())
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end)

	C_Timer.After(0, function() UIDropDownMenu_SetText(dd, GetLabel()) end)
	AddTooltip(frame, tooltip)
	return frame
end
