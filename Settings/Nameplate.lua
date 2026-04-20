local M = cff.MODULES
local V = cff.VALUES

function cff.SetupNameplateSettings()
	local cat = cff.nameplateCategory

	cff.Header(cat, "Classification")
	cff.Checkbox(cat, M.NameplateClassification, "Show Classification Icons", "Show elite and rare icons on nameplates", function()
		if cfFramesDB[M.NameplateClassification] then
			cff.EnableNameplateClassification()
		else
			cff.DisableNameplateClassification()
		end
	end)

	cff.Header(cat, "Scale")
	cff.Slider(cat, V.NameplateScale, "Scale", "Global nameplate scale (cfFrames)", 0.5, 3, 0.05, cff.ApplyNameplateScale)
	cff.CVarSlider(cat, "nameplateSelectedScale", "Target Scale", "Scale of the selected target's nameplate", 0.5, 3, 0.05)
	cff.CVarSlider(cat, "nameplateMinScale", "Non-Target Scale", "Scale of non-selected nameplates", 0.1, 3, 0.05)

	cff.Header(cat, "Alpha")
	cff.CVarSlider(cat, "nameplateNotSelectedAlpha", "Non-Target Alpha", "Alpha of non-selected nameplates", 0, 1, 0.05)
	cff.CVarSlider(cat, "nameplateOccludedAlphaMult", "Behind Geometry Alpha", "Alpha multiplier when nameplate is behind walls/objects", 0, 1, 0.05)

	cff.Header(cat, "Visibility")
	cff.CVarCheckbox(cat, "nameplateShowAll", "Show All Nameplates", "Show nameplates at all times")
	cff.CVarCheckbox(cat, "nameplateShowEnemies", "Show Enemies", "Show enemy nameplates")
	cff.CVarCheckbox(cat, "nameplateShowFriends", "Show Friends", "Show friendly nameplates")
	cff.CVarCheckbox(cat, "nameplateShowEnemyPets", "Show Enemy Pets", "Show enemy pet nameplates")
	cff.CVarCheckbox(cat, "nameplateShowEnemyGuardians", "Show Enemy Guardians", "Show enemy guardian nameplates")
	cff.CVarCheckbox(cat, "nameplateShowEnemyTotems", "Show Enemy Totems", "Show enemy totem nameplates")
	cff.CVarCheckbox(cat, "nameplateShowEnemyMinions", "Show Enemy Minions", "Show enemy minion nameplates")
	cff.CVarCheckbox(cat, "nameplateShowFriendlyPets", "Show Friendly Pets", "Show friendly pet nameplates")
	cff.CVarCheckbox(cat, "nameplateShowFriendlyGuardians", "Show Friendly Guardians", "Show friendly guardian nameplates")
	cff.CVarCheckbox(cat, "nameplateShowFriendlyTotems", "Show Friendly Totems", "Show friendly totem nameplates")
	cff.CVarCheckbox(cat, "nameplateShowFriendlyMinions", "Show Friendly Minions", "Show friendly minion nameplates")
	cff.CVarCheckbox(cat, "nameplateShowFriendlyNPCs", "Show Friendly NPCs", "Always show friendly NPC nameplates")

	cff.Header(cat, "Class Colors")
	cff.Checkbox(cat, M.HealthbarColorNameplateEnemy, "Enemy Nameplates", "Color enemy nameplate health bars by class", function()
		cff.SyncHealthbarCVars()
	end)
	cff.Checkbox(cat, M.HealthbarColorNameplateFriendly, "Friendly Nameplates", "Color friendly nameplate health bars by class", function()
		cff.SyncHealthbarCVars()
	end)
end
