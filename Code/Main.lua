local function addCuaePorperty()
	UnitProperties.properties[#UnitProperties.properties + 1] = {
		id = "CUAE",
		editor = "bool",
		default = false,
		no_edit = true,
	}
end

-- register property when loading mod
addCuaePorperty()

function CUAEBuildWeaponTables()
	Cuae_L("I", "Building tables...")
	-- todo optimize
	for _type, _ in pairs(Cuae_AllArmaments) do
		local suitableWeapons = {}
		if _type == "Flare" then
			local allUtility = table.ifilter(GetWeaponsByType("Grenade"), function(i, g)
				return IsKindOf(g_Classes[g.id], "Flare") and not table.find(Cuae_ExcludeWeapons, g.id)
			end)
			for _, u in pairs(allUtility) do
				table.insert(suitableWeapons, u)
			end
		elseif _type == "Proximity" then
			local allUtility = table.ifilter(GetWeaponsByType("Grenade"), function(i, g)
				return IsKindOf(g_Classes[g.id], "ThrowableTrapItem") and g_Classes[g.id].TriggerType == "Proximity" and not table.find(Cuae_ExcludeWeapons, g.id)
			end)
			for _, u in pairs(allUtility) do
				table.insert(suitableWeapons, u)
			end
		elseif _type == "Timed" then
			local allUtility = table.ifilter(GetWeaponsByType("Grenade"), function(i, g)
				return IsKindOf(g_Classes[g.id], "ThrowableTrapItem") and g_Classes[g.id].TriggerType == "Timed" and not table.find(Cuae_ExcludeWeapons, g.id)
			end)
			for _, u in pairs(allUtility) do
				table.insert(suitableWeapons, u)
			end
		elseif _type == "Remote" then
			local allUtility = table.ifilter(GetWeaponsByType("Grenade"), function(i, g)
				return IsKindOf(g_Classes[g.id], "ThrowableTrapItem") and g_Classes[g.id].TriggerType == "Remote" and not table.find(Cuae_ExcludeWeapons, g.id)
			end)
			for _, u in pairs(allUtility) do
				table.insert(suitableWeapons, u)
			end
		elseif _type == "Smoke" then
			local allUtility = table.ifilter(GetWeaponsByType("Grenade"), function(i, g)
				return g_Classes[g.id].aoeType == "smoke" and not table.find(Cuae_ExcludeWeapons, g.id)
			end)
			for _, u in pairs(allUtility) do
				table.insert(suitableWeapons, u)
			end
		elseif _type == "Explosive" then
			local allUtility = table.ifilter(GetWeaponsByType("Grenade"), function(i, g)
				return g_Classes[g.id].ItemType == "Grenade" and g_Classes[g.id].DeathType == "BlowUp" and not table.find(Cuae_ExcludeWeapons, g.id)
			end)
			for _, u in pairs(allUtility) do
				table.insert(suitableWeapons, u)
			end
		elseif _type == "Flash" then
			local allUtility = table.ifilter(GetWeaponsByType("Grenade"), function(i, g)
				return IsKindOfClasses(g_Classes[g.id], "ConcussiveGrenade", "ConcussiveGrenade_IED") and not table.find(Cuae_ExcludeWeapons, g.id)
			end)
			for _, u in pairs(allUtility) do
				table.insert(suitableWeapons, u)
			end
		elseif _type == "Fire" then
			local allUtility = table.ifilter(GetWeaponsByType("Grenade"), function(i, g)
				return g_Classes[g.id].aoeType == "fire" and not table.find(Cuae_ExcludeWeapons, g.id)
			end)
			for _, u in pairs(allUtility) do
				table.insert(suitableWeapons, u)
			end
		elseif _type == "Tear" then
			local allUtility = table.ifilter(GetWeaponsByType("Grenade"), function(i, g)
				return g_Classes[g.id].aoeType == "teargas" and not table.find(Cuae_ExcludeWeapons, g.id)
			end)
			for _, u in pairs(allUtility) do
				table.insert(suitableWeapons, u)
			end
		elseif _type == "Toxic" then
			local allUtility = table.ifilter(GetWeaponsByType("Grenade"), function(i, g)
				return g_Classes[g.id].aoeType == "toxicgas" and not table.find(Cuae_ExcludeWeapons, g.id)
			end)
			for _, u in pairs(allUtility) do
				table.insert(suitableWeapons, u)
			end
		elseif _type == "MeleeWeapon" then
			local allMelee = table.ifilter(GetWeaponsByType(_type), function(i, w)
				return not table.find(Cuae_ExcludeWeapons, w.id) and g_Classes[w.id].CanAppearInShop
			end)
			for _, w in pairs(allMelee) do
				table.insert(suitableWeapons, w)
			end
		elseif _type == "Head" or _type == "Torso" or _type == "Legs" then
			local allArmors = table.ifilter(GetWeaponsByType("Armor"), function(i, a)
				return _type == (g_Classes[a.id].Slot or "Torso") and not table.find(Cuae_ExcludeWeapons, a.id) and (g_Classes[a.id].CanAppearInShop or table.find(Cuae_Whitelist, a.id))
			end)
			for _, w in pairs(allArmors) do
				table.insert(suitableWeapons, w)
			end
		else
			local allWeapons = table.ifilter(GetWeaponsByType(_type), function(i, w)
				return not table.find(Cuae_ExcludeWeapons, w.id) and (g_Classes[w.id].CanAppearInShop or (table.find(Cuae_Whitelist, w.id) and Cuae_GboPatchedOrNoGbo(w)))
			end)
			for _, w in pairs(allWeapons) do
				table.insert(suitableWeapons, w)
			end
		end
		-- sort by Cost
		table.sort(suitableWeapons, function(a, b)
			return Cuae_ComparePresets(a, b)
		end)

		Cuae_AllArmaments[_type] = suitableWeapons
	end
	Cuae_L("I", "Building tables DONE")
end

-- build tables
OnMsg.NewGame = CUAEBuildWeaponTables
OnMsg.LoadSessionData = CUAEBuildWeaponTables
OnMsg.ModsReloaded = CUAEBuildWeaponTables


-- alter armament
function Cuae_ChangeArmament(settings, unit, avgAllyLevel)
	local originalWeaponsAndUtil, originalHead, originalTorso, originalLegs = Cuae_GetOriginalEq(unit)
	if next(originalWeaponsAndUtil.W) == nil then
		Cuae_L("W", "Changing Armament SKIP due to no weapons", Cuae_UnitAffiliation(settings, unit))
		return
	end

	local loadoutTable = Cuae_GetLoadoutTable(settings, Cuae_UnitAffiliation(settings, unit), unit.role)
	local changePolicy = Cuae_GetChangePolicy(loadoutTable, settings.ReplaceWeapons, originalWeaponsAndUtil)

	-- TODO get ammo profile
	Cuae_RemoveAmmo(settings, unit)

	Cuae_ApplyChangePolicy(settings, unit, avgAllyLevel, changePolicy)

	Cuae_GenerateNewArmor(settings, unit, avgAllyLevel, originalHead, originalTorso, originalLegs)
	if IsKindOf(unit, "Unit") then
		unit:UpdateOutfit()
	end
end

local function getAvgLevel(units)
	local count, sum = 0, 0
	for _, u in ipairs(units) do
		count = count + 1
		sum = sum + u:GetLevel()
	end
	local avgLevel = count > 0 and sum // count or 1
	Cuae_L("D", "Calculated units avg level", sum, "//", count, "=", avgLevel)
	return avgLevel
end

-- main entrypoint
function OnMsg.ConflictStart(sector_id)
	-- build tables just in case
	CUAEBuildWeaponTables()
	if not Cuae_LoadedModOptions.ApplyChangesInSateliteView then
		return
	end
	local allySquads, enemySquads = GetSquadsInSector(sector_id, "exclTravel", "inclMilitia", "exclArrive", "exclRetreat")

	local allyUnits = GetUnitsFromSquads(allySquads, "getUnitData")

	local avgAllyLevel = getAvgLevel(allyUnits)
	for _, unit_data in ipairs(allyUnits) do
		if unit_data.species == "Human" and (Cuae_AffiliationWeight[Cuae_UnitAffiliation(Cuae_LoadedModOptions, unit_data)]) and not unit_data:IsDead() then
			Cuae_L("I", "Changing Armament of an ally on ConflictStart... unit.CUAE", unit_data.CUAE, unit_data.session_id, unit_data.role)
			if not unit_data.CUAE then
				Cuae_ChangeArmament(Cuae_LoadedModOptions, unit_data, avgAllyLevel)
				unit_data.CUAE = true
			end
			Cuae_L("I", "Changing Armament of an ally on ConflictStart DONE")
		end
	end

	local enemyUnits = GetUnitsFromSquads(enemySquads, "getUnitData")
	for _, unit_data in ipairs(enemyUnits) do
		if unit_data.species == "Human" and (Cuae_AffiliationWeight[Cuae_UnitAffiliation(Cuae_LoadedModOptions, unit_data)]) and not unit_data:IsDead() then
			Cuae_L("I", "Changing Armament of an enemy on ConflictStart unit.CUAE:", unit_data.CUAE, unit_data.session_id, unit_data.role)
			if not unit_data.CUAE then
				Cuae_ChangeArmament(Cuae_LoadedModOptions, unit_data, 1)
				unit_data.CUAE = true
			end
			Cuae_L("I", "Changing Armament of an enemy on ConflictStart DONE")
		end
	end
end

function OnMsg.UnitCreated(unit)
	if unit.species == "Human" and (Cuae_AffiliationWeight[Cuae_UnitAffiliation(Cuae_LoadedModOptions, unit)]) and not unit:IsDead() then
		Cuae_L("I", "Changing Armament on UnitCreated... unit.CUAE", unit.CUAE, unit.session_id, unit.role)
		if not unit.CUAE then
			Cuae_ChangeArmament(Cuae_LoadedModOptions, unit, 1)
			unit.CUAE = true
		end
		Cuae_L("I", "Changing Armament on UnitCreated DONE")
	end
end
