local F = cfFrames.Factory
local M = cfFrames.M
local NP = cfFrames.Nameplates

local panel = CreateFrame("Frame", "cfFramesNameplatesPanel")
panel.name = "Nameplates"
panel:Hide()

local function Refresh()
	panel:Hide()
	panel:Show()
end

local sc = F.CreateScrollPanel(panel)
local title = F.CreateTitle(sc, "Nameplates")

-- Nameplate position
local h   = F.CreateHeader(title, "Nameplate")
local npx = F.CreateSlider(h,   "X",     "Nameplates", "x",     -50, 50, 1,    nil, nil, NP.Apply)
local npy = F.CreateSlider(npx, "Y",     "Nameplates", "y",     -50, 50, 1,    nil, nil, NP.Apply)
local nps = F.CreateSlider(npy, "Scale", "Nameplates", "scale", 0.5, 2,  0.05, nil, nil, NP.Apply)

-- Castbar
local hc  = F.CreateHeader(nps, "Castbar")
local npc = F.CreateCheckbox(hc, "Show Castbar", M.NameplateCastbar)
npc:HookScript("OnClick", NP.Apply)
local cbx = F.CreateSlider(npc, "Castbar X",     "Nameplates", "castbarX",     -50, 50, 1,    nil, nil, NP.Apply)
local cby = F.CreateSlider(cbx, "Castbar Y",     "Nameplates", "castbarY",     -50, 50, 1,    nil, nil, NP.Apply)
local cbs = F.CreateSlider(cby, "Castbar Scale", "Nameplates", "castbarScale", 0.5, 3,  0.05, nil, nil, NP.Apply)

-- Castbar Icon
local hi  = F.CreateHeader(cbs, "Castbar Icon")
local ix  = F.CreateSlider(hi, "Icon X",     "Nameplates", "iconX",     -50, 50, 1,    nil, nil, NP.Apply)
local iy  = F.CreateSlider(ix, "Icon Y",     "Nameplates", "iconY",     -50, 50, 1,    nil, nil, NP.Apply)
local is  = F.CreateSlider(iy, "Icon Scale", "Nameplates", "iconScale", 0.5, 3,  0.05, nil, nil, NP.Apply)

-- Buttons
local nrb = F.CreateButton(is, "Reset", nil, function() NP.Reset(); Refresh() end)
local npb = F.CreateButton(nrb, "Preview", 90, NP.Preview)

Settings.RegisterCanvasLayoutSubcategory(cfFrames.category, panel, panel.name, panel.name)
