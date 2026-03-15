local Widgets = {}
cfFrames.Widgets = Widgets

function Widgets.CreateTitle(anchor, text, x, y)
	local fontString = anchor:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	fontString:SetPoint("TOPLEFT", anchor, "TOPLEFT", x, y)
	fontString:SetText(text)
	local separator = Widgets.CreateSeparator(fontString, 0, -4)
	return separator
end

function Widgets.CreateHeader(anchor, text, x, y)
	local anchorFrame = anchor.section or anchor
	local parent = anchorFrame:GetParent() or anchorFrame
	local fontString = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fontString:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", x, y)
	fontString:SetText(text)
	return fontString
end

function Widgets.CreateSeparator(anchor, x, y)
	local parent = anchor:GetParent() or anchor
	local separator = parent:CreateTexture(nil, "ARTWORK")
	separator:SetHeight(1)
	separator:SetColorTexture(0.5, 0.5, 0.5, 0.5)
	separator:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", x, y)
	separator:SetPoint("RIGHT", parent, "RIGHT", -16, 0)
	return separator
end

function Widgets.CreateSection(anchor, x, y)
	local parent = anchor:GetParent() or anchor
	local section = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	section:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", x, y)
	section:SetPoint("RIGHT", parent, "RIGHT", -16, 0)
	section:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 12,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	section:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)

	-- Interior anchor so normal widget chaining works inside the section
	local interior = CreateFrame("Frame", nil, section)
	interior:SetPoint("TOPLEFT", section, "TOPLEFT", 4, 0)
	interior:SetSize(1, 1)
	interior.section = section
	return interior
end

function Widgets.FitToContent(interior, padding)
	local section = interior:GetParent()
	local sectionTop = section:GetTop()
	if not sectionTop then return end
	local lowestBottom = sectionTop
	for _, child in pairs({section:GetChildren()}) do
		local childBottom = child:GetBottom()
		if childBottom and childBottom < lowestBottom then
			lowestBottom = childBottom
		end
	end
	section:SetHeight(sectionTop - lowestBottom + (padding or 10))
end

local function AddTooltip(frame, text)
	if not text then return end
	frame:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(text)
		GameTooltip:Show()
	end)
	frame:HookScript("OnLeave", GameTooltip_Hide)
end

function Widgets.CreateCheckbox(anchor, label, dbKey, x, y, tooltip)
	local parent = anchor:GetParent() or anchor
	local checkbox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
	local anchorPoint = (y == 0) and "TOPLEFT" or "BOTTOMLEFT"
	checkbox:SetPoint("TOPLEFT", anchor, anchorPoint, x, y)
	checkbox.Text:SetText(label)
	checkbox:SetHitRectInsets(0, -checkbox.Text:GetStringWidth(), 0, 0)
	checkbox:SetScript("OnShow", function(self)
		self:SetChecked(cfFramesDB and cfFramesDB[dbKey])
	end)
	checkbox:SetScript("OnClick", function(self)
		local enabled = self:GetChecked()
		cfFramesDB[dbKey] = enabled
		local module = cfFrames.modules[dbKey]
		if module then
			if enabled then module.Enable() else module.Disable() end
		end
	end)
	function checkbox:SetActive(active)
		if active then
			self:Enable()
			self.Text:SetTextColor(1, 0.82, 0)
		else
			self:Disable()
			self.Text:SetTextColor(0.5, 0.5, 0.5)
		end
	end

	AddTooltip(checkbox, tooltip)
	return checkbox
end
