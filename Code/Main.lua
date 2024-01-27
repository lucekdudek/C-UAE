local function changeArnament(unit, orginalHandheldsA, orginalHandheldsB, orginalHead, orginalTorso, orginalLegs)
	RemoveWeaponsAndAmmo(unit)
	GenerateNewWeapons(unit, orginalHandheldsA, orginalHandheldsB)
	GeneratNewArmor(unit, orginalHead, orginalTorso, orginalLegs)
	unit:UpdateOutfit()
end

-- main entrypoint

-- build tables
function OnMsg.ModsReloaded()
	-- print("C-UAE Building tables...")
	for _type, _ in pairs(AllWeapons) do
		local suitableWeapons = {}
		if _type == "Grenade" then
			local allGrenades = table.ifilter(GetWeaponsByType(_type), function(i, g)
				--Filter out cars, flares, gas tanks and other trash
				return (g.ItemType == 'Grenade' or g.ItemType == "Throwables" or g.ItemType == "GrenadeGas" or g.ItemType == "GrenadeFire") and
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
				return not table.find(ExcludeWeapons, w.id)
			end)
			for _, w in pairs(allMelee) do
				if w.id == "Tomahawk_1" then
					w.Cost = 20
				end
				table.insert(suitableWeapons, w)
			end
		elseif _type == "Head" or _type == "Torso" or _type == "Legs" then
			local allArmors = table.ifilter(GetWeaponsByType("Armor"), function(i, a)
				return _type == (a.Slot or 'Torso') and not table.find(ExcludeArmors, a.id)
			end)
			for _, w in pairs(allArmors) do
				if w.id == "PostApoHelmet" then
					w.Cost = 1500
				elseif w.id == "Gasmaskenhelm" then
					w.Cost = 4500
				elseif w.Cost == nil then
					w.Cost = 1
				end
				table.insert(suitableWeapons, w)
			end
		else
			local allWeapons = table.ifilter(GetWeaponsByType(_type), function(i, w)
				return not table.find(ExcludeWeapons, w.id) and w.CanAppearInShop
			end)
			for _, w in pairs(allWeapons) do
				table.insert(suitableWeapons, w)
			end
		end
		-- sort by Cost
		table.sort(suitableWeapons, function(self, other) return (self.Cost or 0) < (other.Cost or 0) end)

		AllWeapons[_type] = suitableWeapons
	end
	-- debug -- print
	-- for _type, _tab in pairs(AllWeapons) do
	-- 	for _, w in pairs(_tab) do
	-- 		-- print(_type, w.id, "Cost:", w.Cost, "Tier:", w.Tier)
	-- 	end
	-- end
	-- print("C-UAE Building tables DONE")
end

-- alter armory
function OnMsg.UnitCreated(unit)
	-- if unit.Affiliation == "AIM" then
	if unit.species == "Human" and (AffiliationWeight[unit.Affiliation]) and not (unit.militia or unit:IsCivilian()) and unit:GetActiveWeapons() and not unit:IsDead() then
		-- print("C-UAE Chaning Arnament...")
		if not unit:HasStatusEffect("CUAE") then
			unit:AddStatusEffect("CUAE")

			local orginalHandheldsA, orginalHandheldsB, orginalHead, orginalTorso, orginalLegs = GetOrginalEq(unit)
			if CheckItemsForQuestItems(orginalHandheldsA) or CheckItemsForQuestItems(orginalHandheldsB) or CheckItemsForQuestItems({ orginalHead, orginalTorso, orginalLegs }) then
				-- print("SKIP ENEMY due to a unique item", unit.session_id)
				return
			end
			changeArnament(unit, orginalHandheldsA, orginalHandheldsB, orginalHead, orginalTorso, orginalLegs)
		end
		-- print("C-UAE Chaning Arnament DONE")
	end
end
