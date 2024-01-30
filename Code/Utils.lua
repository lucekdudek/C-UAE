function Debug(...)
	if LoadedModOptions.Debug then
		print(...)
	end
end

function CalculateAdjustedUnitLevel(level, affiliation)
	return Min(20, Max(1, level + AffiliationWeight[affiliation] + LoadedModOptions.ArmamentStrengthFactor))
end

function CalculateCostRange(level, minFactor, maxFactor)
	local lowEnd = Max(0, (level - 1) * minFactor)
	local highEnd = Min(100, level * maxFactor)
	return lowEnd, highEnd
end

function GetCostIdx(cost, weapons)
	for i, w in ipairs(weapons) do
		if (w.Cost or 0) >= cost then
			return i
		end
	end
	return #weapons
end

function GetSuitableArnaments(level, _type, orginalCost)
	Debug("- getting suitable arnaments for AdjustedLvl:", level, _type, "Orginal Cost", orginalCost)
	local normalizedOrginalCost = orginalCost or DefaultCost[_type]

	local orginalCostIdx = GetCostIdx(normalizedOrginalCost, AllWeapons[_type])
	local costRangeFrom, costRangeTo = CalculateCostRange(level, 5, 15)

	local minIdx = Min(orginalCostIdx, Max(1, DivRound(#AllWeapons[_type] * costRangeFrom, 100)))
	local maxIdx = Max(orginalCostIdx, Min(#AllWeapons[_type], DivRound(#AllWeapons[_type] * costRangeTo, 100)))

	local minCost = AllWeapons[_type][minIdx].Cost or 0
	local maxCost = AllWeapons[_type][maxIdx].Cost or 0
	local suitableArnament = table.ifilter(AllWeapons[_type], function(i, a)
		return (a.Cost or 0) >= minCost and (a.Cost or 0) <= maxCost
	end)

	Debug("-> min:", suitableArnament[1].id, suitableArnament[1].Cost, "max:", suitableArnament[#suitableArnament].id, suitableArnament[#suitableArnament].Cost)
	return suitableArnament
end

function GetGrenadeCurrentType()
	if GameState.Night or GameState.Underground then
		return "GrenadeNight"
	else
		return "GrenadeDay"
	end
end

function GetWeaponType(weapon)
	local _type = weapon.ItemType or weapon.WeaponType
	if _type == "Grenade" or _type == "GrenadeGas" or _type == "GrenadeFire" or _type == "Throwables" then
		return GetGrenadeCurrentType()
	elseif _type == "HeavyWeapon" then
		for heavyWeaponType, heavyWeaponCaliber in pairs(HeavyWeaponTypeToCaliber) do
			print()
			if weapon.Caliber == heavyWeaponCaliber then
				return heavyWeaponType
			end
		end
	else
		return _type
	end
end

function CheckItemsForQuestItems(items)
	for _, h in ipairs(items) do
		if QuestItemsIcons[h.Icon] then
			Debug("- Found quest item", h.Icon)
			return true
		end
	end
	return false
end

function CheckForUnsupportedTypes(items)
	for _, i in ipairs(items) do
		local _type = GetWeaponType(i)
		if not AllWeapons[_type] then
			Debug("- Found unsupported weapon type", _type)
			return true
		end
	end
	return false
end

function RemoveWeaponsAndAmmo(unit)
	Debug("C-UAE Removing orginal items from", unit.Affiliation)
	unit:ForEachItem(function(item, slot_name)
		-- Ordnance is Ammo for heavy weapons
		if slot_name == "Inventory" and (IsKindOf(item, "Ammo") or IsKindOf(item, "Ordnance")) then
			unit:RemoveItem(slot_name, item)
			DoneObject(item)
		elseif slot_name ~= "Inventory" then
			Debug("-", slot_name, item.ItemType or item.WeaponType or "", "Cost:", item.Cost, "Condition:", item.Condition)
			unit:RemoveItem(slot_name, item)
			DoneObject(item)
		end
	end)
end

function GetOrginalEq(unit)
	local orginalHandheldsA = { unit:GetItemAtPos("Handheld A", 1, 1), unit:GetItemAtPos("Handheld A", 2, 1) }
	local orginalHandheldsB = { unit:GetItemAtPos("Handheld B", 1, 1), unit:GetItemAtPos("Handheld B", 2, 1) }
	local orginalHead = unit:GetItemAtPos("Head", 1, 1)
	local orginalTorso = unit:GetItemAtPos("Torso", 1, 1)
	local orginalLegs = unit:GetItemAtPos("Legs", 1, 1)
	return orginalHandheldsA, orginalHandheldsB, orginalHead, orginalTorso, orginalLegs
end
