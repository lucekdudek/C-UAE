function Cuae_Debug(...)
	if Cuae_LoadedModOptions.Debug then
		print(...)
	end
end

function Cuae_Cost(preset)
	return preset.id and g_Classes[preset.id] and g_Classes[preset.id].Cost or 0
end

function Cuae_UnitAffiliation(unit)
	return Cuae_LoadedModOptions.AffectMilitia and unit.militia and "Militia" or unit.Affiliation
end

function Cuae_GetAllWeaponsOfType(_type, affiliation, maxSize)
	maxSize = maxSize or 2
	local allWeapons = Cuae_AllWeapons[_type] or {}
	local exclusionTable = Cuae_AffiliationExclusionTable[affiliation] or {}
	local weapons = table.ifilter(allWeapons, function(_, w) return not exclusionTable[w.id] and g_Classes[w.id].LargeItem + 1 <= maxSize end)
	return weapons
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
		if Cuae_Cost(w) >= cost then
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

	local minCost = Cuae_Cost(allWeaponsOfTyp[minIdx])
	local maxCost = Cuae_Cost(allWeaponsOfTyp[maxIdx])
	local suitableArnament = table.ifilter(allWeaponsOfTyp, function(i, a)
		return Cuae_Cost(a) >= minCost and Cuae_Cost(a) <= maxCost
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

function Cuae_GetDefaultArnament(affiliation, _type, maxSize)
	local _id = Cuae_DefaultWeapons[affiliation][_type]
	if _id == nil then return nil end

	if g_Classes[_id].LargeItem + 1 > maxSize then
		_id = Cuae_DefaultSmallWeapons[_type]
		if _id == nil then return nil end
	end

	Cuae_Debug(
		"- suitable default arnament", _type, _id
	)
	return { id = _id }
end

function Cuae_GetSuitableArnament(affiliation, level, _type, orginalCost, maxSize)
	local suitableArnaments, orginalCostIdx = Cuae_GetSuitableArnaments(affiliation, level, _type, orginalCost, maxSize)
	if #suitableArnaments < 1 then
		return nil
	end
	Cuae_Debug(
		"- suitable arnaments for AdjustedLvl:", level, _type, "Orginal Cost", orginalCost,
		"min:", suitableArnaments[1].id, Cuae_Cost(suitableArnaments[1]),
		"max:", suitableArnaments[#suitableArnaments].id, Cuae_Cost(suitableArnaments[#suitableArnaments])
	)

	orginalCostIdx = orginalCostIdx or Max(1, Min(#suitableArnaments, DivRound(#suitableArnaments, 2)))
	orginalCost = orginalCost or Cuae_Cost(suitableArnaments[orginalCostIdx])

	local distance = {}
	local max = 0
	for _, a in ipairs(suitableArnaments) do
		distance[#distance + 1] = abs(orginalCost - Cuae_Cost(a))
		if distance[#distance] > max then
			max = distance[#distance]
		end
	end
	local powerFactor = 100 - DivRound(100, #distance)

	local oddsFactor = {}
	local oddsFactorsSum = 0
	for _, d in ipairs(distance) do
		oddsFactor[#oddsFactor + 1] = max - DivRound(d * powerFactor, 100)
		oddsFactorsSum = oddsFactorsSum + oddsFactor[#oddsFactor]
	end

	-- MulDiv: division by zero
	if oddsFactorsSum == 0 then oddsFactorsSum = 1 end

	local singularOdds
	local culOdds = {}
	for _, of in ipairs(oddsFactor) do
		singularOdds = DivRound(of * 1000, oddsFactorsSum)
		culOdds[#culOdds + 1] = (culOdds[#culOdds] or 0) + singularOdds
	end

	local random = InteractionRandRange(1, 1000, "LDCUAE")
	for idx, odds in ipairs(culOdds) do
		if random <= odds then return suitableArnaments[idx] end
	end

	return suitableArnaments[InteractionRandRange(1, #suitableArnaments, "LDCUAE")]
end

function Cuae_GetGrenadeCurrentType()
	if GameState.Night or GameState.Underground then
		return "GrenadeNight"
	else
		return "GrenadeDay"
	end
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
