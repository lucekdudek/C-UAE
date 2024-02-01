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

local function buildWeaponTables()
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
			-- TODO handle item.CanThrow
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
				return _type == (a.Slot or 'Torso') and g_Classes[a.id].CanAppearInShop
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
function OnMsg.ModsReloaded()
	buildWeaponTables()

	-- CUAEAddImmunityTable({
	-- 	'FlakLeggings',
	-- 	'AK47',
	-- })
	-- CUAEAddExclusionTable({
	-- 	Legion = {
	-- 		'AK74',
	-- 	}
	-- })

	-- for _type, _tab in pairs(Cuae_AllWeapons) do
	-- 	Cuae_Debug(_type)
	-- 	for _, w in pairs(_tab) do
	-- 		-- Cuae_Debug(w.id)
	-- 		Cuae_Debug(">>", w.id, "Cost:", w.Cost, "/", g_Classes[w.id].Cost, "CanAppearInShop:", g_Classes[w.id].CanAppearInShop)
	-- 		for _, slot in pairs(g_Classes[w.id].ComponentSlots) do
	-- 			Cuae_Debug(">>-", slot.SlotType, "DefaultComponent", slot.DefaultComponent)
	-- 			for _, component in pairs(slot.AvailableComponents) do
	-- 				local compCls = WeaponComponents[component]
	-- 				if compCls then
	-- 					Cuae_Debug(component, "ModificationDifficulty", compCls.ModificationDifficulty, "Cost", compCls.Cost, "compCls.AdditionalCosts", compCls.AdditionalCosts)
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
end

-- alter armament
local function changeArnament(unit)
	local orginalHandheldsA, orginalHandheldsB, orginalHead, orginalTorso, orginalLegs = Cuae_GetOrginalEq(unit)
	Cuae_RemoveAmmo(unit)
	GenerateNewWeapons(unit, orginalHandheldsA, orginalHandheldsB)
	Cuae_GeneratNewArmor(unit, orginalHead, orginalTorso, orginalLegs)
	unit:UpdateOutfit()
end

-- main entrypoint
function OnMsg.UnitCreated(unit)
	if unit.species == "Human" and (Cuae_AffiliationWeight[unit.Affiliation]) and not (unit.militia or unit:IsCivilian()) and unit:GetActiveWeapons() and not unit:IsDead() then
		if GetMapName() == "I-1 - Flag Hill" and GameState.ConflictScripted then
			Cuae_Debug("C-UAE Chaning Arnament SKIP du to I-1 - Flag Hill double map loading issue")
			return
		end
		Cuae_Debug("C-UAE Chaning Arnament... unit.CUAE", unit.CUAE, unit.session_id)
		if not unit.CUAE then
			unit.CUAE = true
			changeArnament(unit)
		end
		Cuae_Debug("C-UAE Chaning Arnament DONE")
	end
end
