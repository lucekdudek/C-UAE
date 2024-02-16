function Cuae_Debug(...)
	if Cuae_LoadedModOptions.Debug then
		print(...)
	end
end

function Cuae_GetAllWeaponsOfType(_type, affiliation)
	local allWeapons = Cuae_AllWeapons[_type] or {}
	local exclusionTable = Cuae_AffiliationExclusionTable[affiliation]
	local weapons = exclusionTable and
		table.ifilter(allWeapons, function(_, w) return not exclusionTable[w.id] end) or
		allWeapons
	return weapons
end

function Cuae_GetAllAmmunitionOfCaliber(weaponCaliber, affiliation)
	if not Cuae_AllAmmunition[weaponCaliber] then
		Cuae_Debug("C-UAE Building", weaponCaliber, "ammunition table...")
		Cuae_AllAmmunition[weaponCaliber] = GetAmmosWithCaliber(weaponCaliber)
		table.sort(Cuae_AllAmmunition[weaponCaliber], function(a, b) return (a.Cost or 0) < (b.Cost or 0) end)
		for _, a in pairs(Cuae_AllAmmunition[weaponCaliber]) do
			Cuae_Debug(">>", a.id, "Cost:", a.Cost)
		end
		Cuae_Debug("C-UAE Building", weaponCaliber, "ammunition table DONE")
	end
	local allAmmunition = Cuae_AllAmmunition[weaponCaliber] or {}
	local exclusionTable = Cuae_AffiliationExclusionTable[affiliation]
	local ammunition = exclusionTable and
		table.ifilter(allAmmunition, function(_, w) return not exclusionTable[w.id] end) or
		allAmmunition
	return ammunition
end

function Cuae_CalculateAdjustedUnitLevel(level, affiliation)
	return Min(20, Max(1, level + Cuae_AffiliationWeight[affiliation] + Cuae_LoadedModOptions.ArmamentStrengthFactor))
end

function Cuae_CalculateCostRange(level, minFactor, maxFactor)
	local lowEnd = Max(0, (level - 1) * minFactor)
	local highEnd = Min(100, level * maxFactor)
	return lowEnd, highEnd
end

local function getCostIdx(cost, weapons)
	for i, w in ipairs(weapons) do
		if (w.Cost or 0) >= cost then
			return i
		end
	end
	return #weapons
end

function Cuae_GetSuitableArnaments(affiliation, level, _type, orginalCost)
	Cuae_Debug("- getting suitable arnaments for AdjustedLvl:", level, _type, "Orginal Cost", orginalCost)
	local allWeaponsOfTyp = Cuae_GetAllWeaponsOfType(_type, affiliation)
	if #allWeaponsOfTyp <= 1 then
		return allWeaponsOfTyp
	end

	local orginalCostIdx = getCostIdx(orginalCost, allWeaponsOfTyp)
	local costRangeFrom, costRangeTo = Cuae_CalculateCostRange(level, 5, 11)

	local minIdx = Min(orginalCostIdx, Max(1, DivRound(#allWeaponsOfTyp * costRangeFrom, 100)))
	local maxIdx = Max(orginalCostIdx, Min(#allWeaponsOfTyp, DivRound(#allWeaponsOfTyp * costRangeTo, 100)))

	local minCost = allWeaponsOfTyp[minIdx].Cost or 0
	local maxCost = allWeaponsOfTyp[maxIdx].Cost or 0
	local suitableArnament = table.ifilter(allWeaponsOfTyp, function(i, a)
		return (a.Cost or 0) >= minCost and (a.Cost or 0) <= maxCost
	end)

	Cuae_Debug("-> min:", suitableArnament[1].id, suitableArnament[1].Cost, "max:",
		suitableArnament[#suitableArnament].id, suitableArnament[#suitableArnament].Cost)
	return suitableArnament
end

function Cuae_GetGrenadeCurrentType()
	if GameState.Night or GameState.Underground then
		return "GrenadeNight"
	else
		return "GrenadeDay"
	end
end

function Cuae_RemoveAmmo(unit)
	Cuae_Debug("C-UAE Removing orginal ammo from", unit.Affiliation)
	unit:ForEachItem(function(item, slot_name)
		-- Ordnance is Ammo for heavy weapons
		if slot_name == "Inventory" and (IsKindOf(item, "Ammo") or IsKindOf(item, "Ordnance")) then
			Cuae_Debug("-", "Caliber:", item.Caliber, item.class, "Cost:", item.Cost, "Amount", item.Amount)
			unit:RemoveItem(slot_name, item)
			DoneObject(item)
		end
	end)
end

function Cuae_Removeitem(unit, slot, item)
	Cuae_Debug("- Removing orginal item", "Type:", item.ItemType or item.WeaponType or "", item.class, "Cost:", item
		.Cost)
	unit:RemoveItem(slot, item)
	DoneObject(item)
end

function Cuae_GetOrginalEq(unit)
	local orginalHandheldsA = { unit:GetItemAtPos("Handheld A", 1, 1), unit:GetItemAtPos("Handheld A", 2, 1) }
	local orginalHandheldsB = { unit:GetItemAtPos("Handheld B", 1, 1), unit:GetItemAtPos("Handheld B", 2, 1) }
	local orginalHead = unit:GetItemAtPos("Head", 1, 1)
	local orginalTorso = unit:GetItemAtPos("Torso", 1, 1)
	local orginalLegs = unit:GetItemAtPos("Legs", 1, 1)
	return orginalHandheldsA, orginalHandheldsB, orginalHead, orginalTorso, orginalLegs
end

function Cuae_TableSlice(tbl, first, last)
	local sliced = {}
	for i = first, last do
		sliced[#sliced + 1] = tbl[i]
	end
	return sliced
end
