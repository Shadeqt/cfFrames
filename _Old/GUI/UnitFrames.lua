local F = cfFrames.Factory
local PF = cfFrames.PlayerFrame
local TF = cfFrames.TargetFrame
local ToT = cfFrames.TargetOfTarget
local COL2 = 225
local COL3 = COL2 * 2

local panel = CreateFrame("Frame", "cfFramesUnitFramesPanel")
panel.name = "Unit Frames"
panel:Hide()

local function Refresh()
	panel:Hide()
	panel:Show()
end

local sc = F.CreateScrollPanel(panel)
local title = F.CreateTitle(sc, "Unit Frames")

-- Headers
local h = F.CreateHeader(title, "Player Frame")

local tLabel = sc:CreateFontString(nil, "ARTWORK", "GameFontNormal")
tLabel:SetPoint("LEFT", h, "LEFT", COL2, 0)
tLabel:SetText("Target Frame")

local totLabel = sc:CreateFontString(nil, "ARTWORK", "GameFontNormal")
totLabel:SetPoint("LEFT", h, "LEFT", COL3, 0)
totLabel:SetText("Target of Target")

-- X
local px  = F.CreateSlider(h,  "X",     "PlayerFrame",   "x",     -1000, 1000, 1,    nil,  nil, PF.Apply)
local tx  = F.CreateSlider(px, "X",     "TargetFrame",   "x",     -1000, 1000, 1,    COL2, nil, TF.Apply)
local totx = F.CreateSlider(px, "X",    "TargetOfTarget", "x",    -1000, 1000, 1,    COL3, nil, ToT.Apply)

-- Y
local py  = F.CreateSlider(px, "Y",     "PlayerFrame",   "y",     -1000, 1000, 1,    nil,  nil, PF.Apply)
local ty  = F.CreateSlider(py, "Y",     "TargetFrame",   "y",     -1000, 1000, 1,    COL2, nil, TF.Apply)
local toty = F.CreateSlider(py, "Y",    "TargetOfTarget", "y",    -1000, 1000, 1,    COL3, nil, ToT.Apply)

-- Scale
local ps  = F.CreateSlider(py, "Scale", "PlayerFrame",   "scale", 0.5, 2, 0.05, nil,  nil, PF.Apply)
local ts  = F.CreateSlider(ps, "Scale", "TargetFrame",   "scale", 0.5, 2, 0.05, COL2, nil, TF.Apply)
local tots = F.CreateSlider(ps, "Scale", "TargetOfTarget", "scale", 0.5, 2, 0.05, COL3, nil, ToT.Apply)

-- Reset buttons
local prb  = F.CreateButton(ps, "Reset", nil, function() PF.Reset(); Refresh() end)
local trb  = F.CreateButton(prb, "Reset", COL2, function() TF.Reset(); Refresh() end)
local totrb = F.CreateButton(prb, "Reset", COL3, function() ToT.Reset(); Refresh() end)

Settings.RegisterCanvasLayoutSubcategory(cfFrames.category, panel, panel.name, panel.name)
