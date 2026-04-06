local F = cfFrames.Factory
local M = cfFrames.M
local PC = cfFrames.PlayerCastbar
local TC = cfFrames.TargetCastbar
local COL2 = 225

local panel = CreateFrame("Frame", "cfFramesCastbarsPanel")
panel.name = "Castbars"
panel:Hide()

local function Refresh()
	panel:Hide()
	panel:Show()
end

local sc = F.CreateScrollPanel(panel)
local title = F.CreateTitle(sc, "Castbars")

-- Headers
local h = F.CreateHeader(title, "Player Castbar")

local tLabel = sc:CreateFontString(nil, "ARTWORK", "GameFontNormal")
tLabel:SetPoint("LEFT", h, "LEFT", COL2, 0)
tLabel:SetText("Target Castbar")

-- X
local px = F.CreateSlider(h,  "X",     "PlayerCastbar", "x",     -500, 500, 1,    nil,  nil, PC.Apply)
local tx = F.CreateSlider(px, "X",     "TargetCastbar", "x",     -500, 500, 1,    COL2, nil, TC.Apply)

-- Y
local py = F.CreateSlider(px, "Y",     "PlayerCastbar", "y",     -500, 500, 1,    nil,  nil, PC.Apply)
local ty = F.CreateSlider(py, "Y",     "TargetCastbar", "y",     -500, 500, 1,    COL2, nil, TC.Apply)

-- Scale
local ps = F.CreateSlider(py, "Scale", "PlayerCastbar", "scale", 0.5,  2,   0.05, nil,  nil, PC.Apply)
local ts = F.CreateSlider(ps, "Scale", "TargetCastbar", "scale", 0.5,  2,   0.05, COL2, nil, TC.Apply)

-- Icons
local pic = F.CreateCheckbox(ps, "Show Icon", M.CastbarPlayerIcon)
pic:HookScript("OnClick", PC.Apply)
local tic = F.CreateCheckbox(pic, "Show Icon", M.CastbarTargetIcon, COL2)
tic:HookScript("OnClick", TC.Apply)

local pix = F.CreateSlider(pic, "Icon X",     "PlayerCastbarIcon", "x",     -100, 100, 1,    nil,  nil, PC.Apply)
local tix = F.CreateSlider(pix, "Icon X",     "TargetCastbarIcon", "x",     -100, 100, 1,    COL2, nil, TC.Apply)
local piy = F.CreateSlider(pix, "Icon Y",     "PlayerCastbarIcon", "y",     -100, 100, 1,    nil,  nil, PC.Apply)
local tiy = F.CreateSlider(piy, "Icon Y",     "TargetCastbarIcon", "y",     -100, 100, 1,    COL2, nil, TC.Apply)
local pis = F.CreateSlider(piy, "Icon Scale", "PlayerCastbarIcon", "scale", 0.5,  3,   0.05, nil,  nil, PC.Apply)
local tis = F.CreateSlider(pis, "Icon Scale", "TargetCastbarIcon", "scale", 0.5,  3,   0.05, COL2, nil, TC.Apply)

-- Buttons
local prb = F.CreateButton(pis, "Reset",   nil, function() PC.Reset(); Refresh() end)
local ppb = F.CreateButton(prb, "Preview", 90,  PC.Preview)
local trb = F.CreateButton(tis, "Reset",   nil, function() TC.Reset(); Refresh() end)
local tpb = F.CreateButton(trb, "Preview", 90,  TC.Preview)

Settings.RegisterCanvasLayoutSubcategory(cfFrames.category, panel, panel.name, panel.name)
