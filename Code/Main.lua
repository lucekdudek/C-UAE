function BuildWeaponTables()
	Debug("C-UAE Building tables...")
	for _type, _ in pairs(AllWeapons) do
		local suitableWeapons = {}
		if _type == "GrenadeDay" or _type == "GrenadeNight" then
			local allGrenades = table.ifilter(GetWeaponsByType("Grenade"), function(i, g)
				return (g.ItemType == 'Grenade' or (_type == "GrenadeNight" and g.ItemType == "Throwables") or g.ItemType == "GrenadeGas" or g.ItemType == "GrenadeFire") and
					not table.find(ExcludeWeapons, g.id)
			end)
			for _, w in pairs(allGrenades) do
				if w.id == "ToxicGasGrenade" then
					w.Cost = 800
				end
				table.insert(suitableWeapons, w)
			end
		elseif _type == "MeleeWeapon" then
			local allMelee = table.ifilter(GetWeaponsByType(_type), function(i, w)
				return not table.find(ExcludeWeapons, w.id) and g_Classes[w.id].CanAppearInShop
			end)
			for _, w in pairs(allMelee) do
				if w.id == "Tomahawk_1" then
					w.Cost = 150
				end
				table.insert(suitableWeapons, w)
			end
		elseif _type == "HeavyWeapon40mmGrenade" or _type == "HeavyWeaponWarhead" or _type == "HeavyWeaponMortarShell" then
			local allWeapons = table.ifilter(GetWeaponsByType("HeavyWeapon"), function(i, w)
				return (HeavyWeaponTypeToCaliber[_type] or "Unsuppoerted") == g_Classes[w.id].Caliber and
					not table.find(ExcludeWeapons, w.id) and g_Classes[w.id].CanAppearInShop
			end)
			for _, w in pairs(allWeapons) do
				table.insert(suitableWeapons, w)
			end
		elseif _type == "Head" or _type == "Torso" or _type == "Legs" then
			local allArmors = table.ifilter(GetWeaponsByType("Armor"), function(i, a)
				return _type == (a.Slot or 'Torso') and
					(a.id == "PostApoHelmet" or a.id == "Gasmaskenhelm" or g_Classes[a.id].CanAppearInShop)
			end)
			for _, w in pairs(allArmors) do
				if w.id == "LightHelmet" then
					w.Cost = 1000
				elseif w.id == "PostApoHelmet" then
					w.Cost = 5000
				elseif w.id == "Gasmaskenhelm" then
					w.Cost = 12000
				end
				table.insert(suitableWeapons, w)
			end
		else
			local allWeapons = table.ifilter(GetWeaponsByType(_type), function(i, w)
				return not table.find(ExcludeWeapons, w.id) and g_Classes[w.id].CanAppearInShop
			end)
			for _, w in pairs(allWeapons) do
				table.insert(suitableWeapons, w)
			end
		end
		-- sort by Cost
		table.sort(suitableWeapons, function(a, b) return (a.Cost or 0) < (b.Cost or 0) end)

		AllWeapons[_type] = suitableWeapons
	end
	Debug("C-UAE Building tables DONE")
end

-- build tables
function OnMsg.ModsReloaded()
	BuildWeaponTables()
	-- for _type, _tab in pairs(AllWeapons) do
	-- 	Debug(_type)
	-- 	for _, w in pairs(_tab) do
	-- 		-- Debug(w.id)
	-- 		Debug(">>", w.id, "Cost:", w.Cost, "/", g_Classes[w.id].Cost, "CanAppearInShop:",
	-- 			g_Classes[w.id].CanAppearInShop, "Caliber:", g_Classes[w.id].Caliber)
	-- 		-- for _, slot in pairs(g_Classes[w.id].ComponentSlots) do
	-- 		-- 	Debug(">>-", slot.SlotType)
	-- 		-- 	for _, component in pairs(slot.AvailableComponents) do
	-- 		-- 		Debug(">>->", component)
	-- 		-- 	end
	-- 		-- end
	-- 	end
	-- end
end

-- alter armament
local function changeArnament(unit, orginalHandheldsA, orginalHandheldsB, orginalHead, orginalTorso, orginalLegs)
	RemoveWeaponsAndAmmo(unit)
	GenerateNewWeapons(unit, orginalHandheldsA, orginalHandheldsB)
	GeneratNewArmor(unit, orginalHead, orginalTorso, orginalLegs)
	unit:UpdateOutfit()
end

-- main entrypoint
function OnMsg.UnitCreated(unit)
	-- if unit.Affiliation == "AIM" then
	if unit.species == "Human" and (AffiliationWeight[unit.Affiliation]) and not (unit.militia or unit:IsCivilian()) and unit:GetActiveWeapons() and not unit:IsDead() then
		Debug("C-UAE Chaning Arnament...")
		if not unit:HasStatusEffect("CUAE") then
			unit:AddStatusEffect("CUAE")

			local orginalHandheldsA, orginalHandheldsB, orginalHead, orginalTorso, orginalLegs = GetOrginalEq(unit)
			if CheckItemsForQuestItems(orginalHandheldsA) or CheckItemsForQuestItems(orginalHandheldsB) or CheckItemsForQuestItems({ orginalHead, orginalTorso, orginalLegs }) or CheckForUnsupportedTypes(orginalHandheldsA) or CheckForUnsupportedTypes(orginalHandheldsB) then
				Debug("C-UAE Chaning Arnament SKIP")
				return
			end
			changeArnament(unit, orginalHandheldsA, orginalHandheldsB, orginalHead, orginalTorso, orginalLegs)
		end
		Debug("C-UAE Chaning Arnament DONE")
	end
end
