function Cuae_Debug(...)
	if Cuae_LoadedModOptions.Debug then
		print(...)
	end
end

function Cuae_UnitAffiliation(unit)
	return unit.militia and "Militia" or unit.Affiliation
end

function Cuae_GetAllWeaponsOfType(_type, affiliation, maxSize)
	maxSize = maxSize or 2
	local allWeapons = Cuae_AllWeapons[_type] or {}
	local exclusionTable = Cuae_AffiliationExclusionTable[affiliation] or {}
	local weapons = table.ifilter(allWeapons, function(_, w) return not exclusionTable[w.id] and g_Classes[w.id].LargeItem + 1 <= maxSize end)
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

function Cuae_CalculateAdjustedUnitLevel(level, avgAllyLevel, affiliation)
	local minimum = Max(1, avgAllyLevel + Cuae_LoadedModOptions.ArmamentStrengthFactor)
	local adjusted = level + Cuae_AffiliationWeight[affiliation] + Cuae_LoadedModOptions.ArmamentStrengthFactor
	return Min(20, Max(minimum, adjusted))
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

function Cuae_GetSuitableArnaments(affiliation, level, _type, orginalCost, maxSize)
	local allWeaponsOfTyp = Cuae_GetAllWeaponsOfType(_type, affiliation, maxSize)
	if #allWeaponsOfTyp <= 1 then
		return allWeaponsOfTyp, nil
	end

	local costRangeFrom, costRangeTo = Cuae_CalculateCostRange(level, 3, 10)

	local minIdx = Max(1, DivRound(#allWeaponsOfTyp * costRangeFrom, 100))
	local maxIdx = Min(#allWeaponsOfTyp, DivRound(#allWeaponsOfTyp * costRangeTo, 100))

	local orginalCostIdx = nil
	if orginalCost then
		local orginalCostIdx = getCostIdx(orginalCost, allWeaponsOfTyp)
		minIdx = Min(orginalCostIdx, minIdx)
		maxIdx = Max(orginalCostIdx, maxIdx)
	end

	local minCost = allWeaponsOfTyp[minIdx].Cost or 0
	local maxCost = allWeaponsOfTyp[maxIdx].Cost or 0
	local suitableArnament = table.ifilter(allWeaponsOfTyp, function(i, a)
		return (a.Cost or 0) >= minCost and (a.Cost or 0) <= maxCost
	end)

	return suitableArnament, orginalCostIdx
end

function DiceInteractionRandRange(_from, _to, _mid, dice_count, interaction)
	local dist = DivRound(Max(_to - _mid, _mid - _from), dice_count)
	local dice_from = DivRound(_mid, dice_count) - dist
	local dice_to = DivRound(_mid, dice_count) + dist
	local rand
	for _ = 1, 10 do
		rand = 0
		for __ = 1, dice_count do
			rand = rand + InteractionRandRange(dice_from, dice_to, interaction)
		end
		if rand >= _from and rand <= _to then
			return rand
		end
	end
	return _mid
end

function Cuae_GetSuitableArnament(affiliation, level, _type, orginalCost, maxSize)
	local suitableArnaments, orginalCostIdx = Cuae_GetSuitableArnaments(affiliation, level, _type, orginalCost, maxSize)
	if #suitableArnaments < 1 then
		return nil
	end
	Cuae_Debug(
		"- suitable arnaments for AdjustedLvl:", level, _type, "Orginal Cost", orginalCost,
		"min:", suitableArnaments[1].id, suitableArnaments[1].Cost,
		"max:", suitableArnaments[#suitableArnaments].id, suitableArnaments[#suitableArnaments].Cost
	)

	orginalCostIdx = orginalCostIdx or Max(1, Min(#suitableArnaments, DivRound(#suitableArnaments, 2)))
	orginalCost = orginalCost or suitableArnaments[orginalCostIdx].Cost

	local distance = {}
	local max = 0
	for _, a in ipairs(suitableArnaments) do
		distance[#distance + 1] = abs(orginalCost - a.Cost)
		if distance[#distance] > max then
			max = distance[#distance]
		end
	end
	local powerFactor = 100 - DivRound(100, #distance)

	local oddsFactor = {}
	local oddsFactorsSum = 0
	for _, d in ipairs(distance) do
		local temp = max - d * powerFactor
		oddsFactor[#oddsFactor + 1] = temp * temp
		oddsFactorsSum = oddsFactorsSum + oddsFactor[#oddsFactor]
	end

	local singularOdds
	local culOdds = {}
	for _, of in ipairs(oddsFactor) do
		singularOdds = DivRound(of * 100000, oddsFactorsSum)
		culOdds[#culOdds + 1] = (culOdds[#culOdds] or 0) + singularOdds
	end

	local random = DiceInteractionRandRange(1, 100000, DivRound(culOdds[orginalCostIdx], 1), 2, "LDCUAE")
	for idx, odds in ipairs(culOdds) do
		if random <= odds then return suitableArnaments[idx] end
	end

	return suitableArnaments[#suitableArnaments]
end

function Cuae_GetGrenadeCurrentType()
	if GameState.Night or GameState.Underground then
		return "GrenadeNight"
	else
		return "GrenadeDay"
	end
end

function Cuae_RemoveAmmo(unit)
	Cuae_Debug("C-UAE Removing orginal ammo from", Cuae_UnitAffiliation(unit))
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
	Cuae_Debug("- Removing orginal item", "Type:", item.ItemType or item.WeaponType or "", item.class, "Cost:", item.Cost)
	unit:RemoveItem(slot, item)
	DoneObject(item)
end

function Cuae_GetOrginalEq(unit)
	local orginalHandhelds = {
		A1 = unit:GetItemAtPos("Handheld A", 1, 1),
		A2 = unit:GetItemAtPos("Handheld A", 2, 1),
		B1 = unit:GetItemAtPos("Handheld B", 1, 1),
		B2 = unit:GetItemAtPos("Handheld B", 2, 1),
	}
	local orginalHead = unit:GetItemAtPos("Head", 1, 1)
	local orginalTorso = unit:GetItemAtPos("Torso", 1, 1)
	local orginalLegs = unit:GetItemAtPos("Legs", 1, 1)
	return orginalHandhelds, orginalHead, orginalTorso, orginalLegs
end

function Cuae_TableSlice(tbl, first, last)
	local sliced = {}
	for i = first, last do
		sliced[#sliced + 1] = tbl[i]
	end
	return sliced
end
