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
	Cuae_Debug("C-UAE Building tables...")
	for _type, _ in pairs(Cuae_AllWeapons) do
		local suitableWeapons = {}
		if _type == "GrenadeDay" or _type == "GrenadeNight" then
			local allGrenades = table.ifilter(GetWeaponsByType("Grenade"), function(i, g)
				return (g.ItemType == 'Grenade' or (_type == "GrenadeNight" and g.ItemType == "Throwables") or g.ItemType == "GrenadeGas" or g.ItemType == "GrenadeFire") and
					not table.find(Cuae_ExcludeWeapons, g.id)
			end)
			for _, w in pairs(allGrenades) do
				if w.id == "ToxicGasGrenade" then
					w.Cost = 800
				end
				table.insert(suitableWeapons, w)
			end
		elseif _type == "MeleeWeapon" then
			local allMelee = table.ifilter(GetWeaponsByType(_type), function(i, w)
				return not table.find(Cuae_ExcludeWeapons, w.id) and g_Classes[w.id].CanAppearInShop
			end)
			for _, w in pairs(allMelee) do
				if w.id == "Tomahawk_1" then
					w.Cost = 150
				end
				table.insert(suitableWeapons, w)
			end
		elseif _type == "HeavyWeapon40mmGrenade" or _type == "HeavyWeaponWarhead" or _type == "HeavyWeaponMortarShell" then
			local allWeapons = table.ifilter(GetWeaponsByType("HeavyWeapon"), function(i, w)
				return (Cuae_HeavyWeaponTypeToCaliber[_type] or "Unsuppoerted") == g_Classes[w.id].Caliber and
					not table.find(Cuae_ExcludeWeapons, w.id) and g_Classes[w.id].CanAppearInShop
			end)
			for _, w in pairs(allWeapons) do
				table.insert(suitableWeapons, w)
			end
		elseif _type == "Head" or _type == "Torso" or _type == "Legs" then
			local allArmors = table.ifilter(GetWeaponsByType("Armor"), function(i, a)
				return _type == (g_Classes[a.id].Slot or 'Torso') and not table.find(Cuae_ExcludeWeapons, a.id) and
					g_Classes[a.id].CanAppearInShop
			end)
			for _, w in pairs(allArmors) do
				if w.id == "LightHelmet" then
					w.Cost = 1000
				end
				table.insert(suitableWeapons, w)
			end
		else
			local allWeapons = table.ifilter(GetWeaponsByType(_type), function(i, w)
				return not table.find(Cuae_ExcludeWeapons, w.id) and g_Classes[w.id].CanAppearInShop
			end)
			for _, w in pairs(allWeapons) do
				table.insert(suitableWeapons, w)
			end
		end
		-- sort by Cost
		table.sort(suitableWeapons, function(a, b) return (a.Cost or 0) < (b.Cost or 0) end)

		Cuae_AllWeapons[_type] = suitableWeapons
	end
	Cuae_Debug("C-UAE Building tables DONE")
end

-- build tables
function OnMsg.NewGame()
	CUAEBuildWeaponTables()
end

function OnMsg.PreLoadSessionData()
	CUAEBuildWeaponTables()
end

function OnMsg.ModsReloaded()
	CUAEBuildWeaponTables()
	-- CUAEAddImmunityTable({
	-- 	'FlakLeggings',
	-- 	'AK47',
	-- })
	-- CUAEAddExclusionTable({
	-- 	Legion = {
	-- 		'AK74',
	-- 	}
	-- })

	-- for _type, _ in pairs(Cuae_AllWeapons) do
	-- 	local _tab = Cuae_GetAllWeaponsOfType(_type, "Legion")
	-- 	Cuae_Debug(">", _type)
	-- 	if _tab then
	-- 		for _, w in pairs(_tab) do
	-- 			-- Cuae_Debug(w.id)
	-- 			Cuae_Debug(">>", w.id, "Cost:", w.Cost, "/", g_Classes[w.id].Cost, "CanAppearInShop:", g_Classes[w.id].CanAppearInShop, "PenetrationClass", g_Classes[w.id].PenetrationClass, "base_drop_chance", g_Classes[w.id].base_drop_chance)
	-- 			-- for _, slot in pairs(g_Classes[w.id].ComponentSlots) do
	-- 			-- 	Cuae_Debug(">>-", slot.SlotType, "DefaultComponent", slot.DefaultComponent)
	-- 			-- 	for _, component in pairs(slot.AvailableComponents) do
	-- 			-- 		local compCls = WeaponComponents[component]
	-- 			-- 		if compCls then
	-- 			-- 			Cuae_Debug(component, "ModificationDifficulty", compCls.ModificationDifficulty, "Cost", compCls.Cost, "compCls.AdditionalCosts", compCls.AdditionalCosts)
	-- 			-- 		end
	-- 			-- 	end
	-- 			-- end
	-- 		end
	-- 	end
	-- end
end

-- alter armament
local function changeArnament(unit, avgAllyLevel)
	local orginalHandhelds, orginalHead, orginalTorso, orginalLegs = Cuae_GetOrginalEq(unit)
	if orginalHandhelds.A1 == nil and orginalHandhelds.A2 == nil then
		Cuae_Debug("C-UAE Chaning Arnament SKIP du to empty orginalHandheldsA", Cuae_UnitAffiliation(unit))
		return
	end
	Cuae_RemoveAmmo(unit)
	Cuae_GenerateNewWeapons(unit, avgAllyLevel, orginalHandhelds)
	Cuae_GeneratNewArmor(unit, avgAllyLevel, orginalHead, orginalTorso, orginalLegs)
	if IsKindOf(unit, "Unit") then unit:UpdateOutfit() end
end

-- main entrypoint
function OnMsg.ConflictStart(sector_id)
	if not Cuae_LoadedModOptions.ApplyChangesInSateliteView then
		return
	end
	local allySquads, enemySquads = GetSquadsInSector(sector_id, "exclTravel", "inclMilitia", "exclArrive", "exclRetreat")

	local allyUnits = GetUnitsFromSquads(allySquads, "getUnitData")

	local count, sum = 0, 0
	for _, u in ipairs(allyUnits) do
		count = count + 1
		sum = sum + u:GetLevel()
	end
	local avgAllyLevel = count > 0 and sum // count or 1
	Cuae_Debug("C-UAE Calcualted avg Ally level", sum, "//", count, "=", avgAllyLevel)

	for _, unit_data in pairs(allyUnits) do
		if unit_data.species == "Human" and (Cuae_AffiliationWeight[Cuae_UnitAffiliation(unit_data)]) and not unit_data:IsDead() then
			Cuae_Debug("C-UAE Chaning Arnament of an ally on ConflictStart... unit.CUAE", unit_data.CUAE, unit_data.session_id)
			if not unit_data.CUAE then
				changeArnament(unit_data, avgAllyLevel)
				unit_data.CUAE = true
			end
			Cuae_Debug("C-UAE Chaning Arnament of an ally on ConflictStart DONE")
		end
	end

	local enemyUnits = GetUnitsFromSquads(enemySquads, "getUnitData")
	for _, unit_data in pairs(enemyUnits) do
		if unit_data.species == "Human" and (Cuae_AffiliationWeight[Cuae_UnitAffiliation(unit_data)]) and not unit_data:IsDead() then
			Cuae_Debug("C-UAE Chaning Arnament of an enemy on ConflictStart... unit.CUAE", unit_data.CUAE, unit_data.session_id)
			if not unit_data.CUAE then
				changeArnament(unit_data, avgAllyLevel)
				unit_data.CUAE = true
			end
			Cuae_Debug("C-UAE Chaning Arnament of an enemy on ConflictStart DONE")
		end
	end
end

function OnMsg.UnitCreated(unit)
	if unit.species == "Human" and (Cuae_AffiliationWeight[Cuae_UnitAffiliation(unit)]) and not unit:IsDead() then
		Cuae_Debug("C-UAE Chaning Arnament on UnitCreated... unit.CUAE", unit.CUAE, unit.session_id)
		if not unit.CUAE then
			changeArnament(unit, 1)
			unit.CUAE = true
		end
		Cuae_Debug("C-UAE Chaning Arnament on UnitCreated DONE")
	end
end

-- function OnMsg.ModsReloaded()
-- 	local cuaeSettings = {
-- 		-- visible options
-- 		-- ReplaceWeapons = true,
-- 		-- AddWeaponComponents = true,
-- 		-- ReplaceArmor = true,
-- 		-- ExtraGrenadesChance = 50,
-- 		-- ArmamentStrengthFactor = 0,
-- 		-- hidden options
-- 		-- DisallowSilencers = true,
-- 		-- ExtraHandgun = false,
-- 		-- ExtraGrenadesCount = 3,
-- 		-- AlternativeWeaponTypeTables = {
-- 		-- 	Handgun = {{"SMG",50}, {"Shotgun",80}, {"AssaultRifle",100}},
-- 		-- 	SMG = {{"AssaultRifle",25}},
-- 		-- 	Shotgun = {{"AssaultRifle",15}},
-- 		-- 	AssaultRifle = {{"Sniper",12}, {"MachineGun",20}},
-- 		-- },
-- 		-- ApplyChangesInSateliteView = true,
-- 		Debug = true,
-- 	}
-- 	CUAEForceSettings(cuaeSettings)
-- end
