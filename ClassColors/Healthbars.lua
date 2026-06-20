local _, addon = ...

-- Healthbar class tint (cfFramesTest's newest HealthbarColor implementation): tint unit-frame health
-- bars by class (players), pet friend/hostile, tap state, or selection color (hostile NPCs). Also
-- neutralizes the target's reaction-tinted name backing to a translucent black.
--
-- StatusBarTexture.lua's SetStatusBarTexture clears the bar color, but these hooks re-apply on the next
-- health update / value change, so the class tint self-heals after a retexture regardless of load order.
-- Called from addon.SetupClassColors (gated by the ClassColors master toggle), so no own DB gate here.

-- Players -> class color; own/party/enemy pet -> green/red by friendliness; tap-denied -> grey;
-- everything else -> selection color (the right reaction tint for friendly/neutral/hostile NPCs).
local function GetColor(unit)
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		if class then return GetClassColor(class) end
	elseif UnitPlayerControlled(unit) then
		if UnitIsFriend("player", unit) then return 0, 1, 0 end
		return 1, 0, 0
	elseif UnitIsTapDenied(unit) then
		return 0.5, 0.5, 0.5
	end
	return UnitSelectionColor(unit)
end

local function ColorBar(bar, unit)
	if not bar or bar:IsForbidden() or not unit then return end
	local r, g, b = GetColor(unit)
	if r then bar:SetStatusBarColor(r, g, b) end
end

-- Color whatever bars are already present at setup: the player always exists and party members persist
-- across /reload. Target/ToT can't exist at login/reload, so the hooks below color them on acquisition.
local function ColorExistingBars()
	ColorBar(PlayerFrameHealthBar, "player")
	for i = 1, MAX_PARTY_MEMBERS do
		local unit = "party" .. i
		if UnitExists(unit) then ColorBar(_G["PartyMemberFrame" .. i .. "HealthBar"], unit) end
	end
end

function addon.SetupHealthbars()
	-- Re-apply on every health update / value change -- this is also what makes the tint self-heal after
	-- StatusBarTexture clears the color. ToT is excluded here (no unit arg on this path) and driven below.
	hooksecurefunc("UnitFrameHealthBar_Update", function(bar, unit)
		if bar == TargetFrameToTHealthBar then return end
		ColorBar(bar, unit)
	end)
	hooksecurefunc("HealthBar_OnValueChanged", function(self)
		if self.unit then ColorBar(self, self.unit) end
	end)

	if TargetFrameToTHealthBar then
		local function ColorToT()
			if UnitExists("targettarget") then ColorBar(TargetFrameToTHealthBar, "targettarget") end
		end
		hooksecurefunc(TargetFrameToTHealthBar, "SetValue", ColorToT)
		local f = CreateFrame("Frame")
		f:RegisterUnitEvent("UNIT_TARGET", "target")
		f:SetScript("OnEvent", ColorToT)
	end

	-- Neutralize the target's name backing to a translucent black (Blizzard reaction-tints it). We own
	-- the region's color by hooking its own SetVertexColor, so a reaction change without a target swap
	-- (UNIT_FACTION via TargetFrame_CheckFaction, which doesn't run TargetFrame_CheckClassification) is
	-- still caught. The guard skips our own writes (and BiggerUnitFrames' identical 0,0,0,0.5), so no
	-- recursion and no conflict. COLOR only: the 18px height trim stays owned by BiggerUnitFrames.
	if TargetFrameNameBackground then
		local applying = false
		hooksecurefunc(TargetFrameNameBackground, "SetVertexColor", function(self, r, g, b, a)
			if applying then return end
			if r == 0 and g == 0 and b == 0 and a == 0.5 then return end  -- already ours
			applying = true
			self:SetVertexColor(0, 0, 0, 0.5)
			applying = false
		end)
		TargetFrameNameBackground:SetVertexColor(0, 0, 0, 0.5)  -- paint whatever's already shown
	end

	ColorExistingBars()

	-- Re-color a member whenever Blizzard refreshes its frame. On join, GROUP_ROSTER_UPDATE fires and
	-- UnitClass() often still returns nil at that instant, so GetColor returns nil and the bar keeps its
	-- default green; the class arrives a moment later via PartyMemberFrame_UpdateMember. Hooking that
	-- colors the bar exactly when the data is ready, driven by Blizzard's own events.
	if type(PartyMemberFrame_UpdateMember) == "function" then
		hooksecurefunc("PartyMemberFrame_UpdateMember", function(self)
			if self and self.GetID then
				local id = self:GetID()
				ColorBar(_G["PartyMemberFrame" .. id .. "HealthBar"], "party" .. id)
			end
		end)
	end
end
