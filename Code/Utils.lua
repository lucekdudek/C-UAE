function Cuae_Cost(preset)
	return preset.id and g_Classes[preset.id] and g_Classes[preset.id].Cost or 0
end

function Cuae_ComparePresets(presetA, presetB)
	local costA, CostB = Cuae_Cost(presetA), Cuae_Cost(presetB)
	if costA == CostB then
		return presetA.id < presetB.id
	else
		return costA < CostB
	end
end

function Cuae_UnitAffiliation(settings, unit)
	return settings.AffectMilitia and unit.militia and "Militia" or unit.Affiliation
end

function Cuae_GetHeadSubType(ogHead)
	if ogHead.CategoryPair == "Heavy" then
		return "HHead"
	elseif ogHead.CategoryPair == "Medium" then
		return "MHead"
	else
		return "LHead"
	end
end

function Cuae_GetTorsoSubType(ogTorso)
	if ogTorso.CategoryPair == "Heavy" and ogTorso.ProtectedBodyParts and ogTorso.ProtectedBodyParts["Arms"] then
		return "HPlate"
	elseif ogTorso.CategoryPair == "Heavy" then
		return "HVest"
	elseif ogTorso.CategoryPair == "Medium" and ogTorso.ProtectedBodyParts and ogTorso.ProtectedBodyParts["Arms"] then
		return "MPlate"
	elseif ogTorso.CategoryPair == "Medium" then
		return "MVest"
	elseif ogTorso.CategoryPair == "Light" and ogTorso.ProtectedBodyParts and ogTorso.ProtectedBodyParts["Arms"] then
		return "LPlate"
	else
		return "LVest"
	end
end

function Cuae_GetLegsSubType(ogLegs)
	if ogLegs.CategoryPair == "Heavy" then
		return "HLegs"
	elseif ogLegs.CategoryPair == "Medium" then
		return "MLegs"
	else
		return "LLegs"
	end
end

local function getHeadArmorOfSubtype(allArmor, subType)
	if next(Cuae_AllArmor.Head) == nil then
		Cuae_L("D", "Building Head sub tables...")

		Cuae_AllArmor.Head.LHead = {}
		Cuae_AllArmor.Head.MHead = {}
		Cuae_AllArmor.Head.HHead = {}

		for _, a in ipairs(allArmor) do
			table.insert(Cuae_AllArmor.Head[Cuae_GetHeadSubType(g_Classes[a.id])], a)
		end

		for _, t in pairs(Cuae_AllArmor.Head) do
			table.sort(t, function(a, b)
				return Cuae_ComparePresets(a, b)
			end)
		end

		Cuae_L("D", "Building Head sub tables DONE")
	end

	return Cuae_AllArmor.Head[subType]
end

local function getTorsoArmorOfSubtype(allArmor, subType)
	if next(Cuae_AllArmor.Torso) == nil then
		Cuae_L("D", "Building Torso sub tables...")

		Cuae_AllArmor.Torso.LVest = {}
		Cuae_AllArmor.Torso.MVest = {}
		Cuae_AllArmor.Torso.HVest = {}
		Cuae_AllArmor.Torso.LPlate = {}
		Cuae_AllArmor.Torso.MPlate = {}
		Cuae_AllArmor.Torso.HPlate = {}

		for _, a in ipairs(allArmor) do
			table.insert(Cuae_AllArmor.Torso[Cuae_GetTorsoSubType(g_Classes[a.id])], a)
		end

		for _, t in pairs(Cuae_AllArmor.Torso) do
			table.sort(t, function(a, b)
				return Cuae_ComparePresets(a, b)
			end)
		end

		Cuae_L("D", "Building Torso sub tables DONE")
	end

	return Cuae_AllArmor.Torso[subType]
end

local function getLegsArmorOfSubtype(allArmor, subType)
	if next(Cuae_AllArmor.Legs) == nil then
		Cuae_L("D", "Building Legs sub tables...")

		Cuae_AllArmor.Legs.LLegs = {}
		Cuae_AllArmor.Legs.MLegs = {}
		Cuae_AllArmor.Legs.HLegs = {}

		for _, a in ipairs(allArmor) do
			table.insert(Cuae_AllArmor.Legs[Cuae_GetLegsSubType(g_Classes[a.id])], a)
		end

		for _, t in pairs(Cuae_AllArmor.Legs) do
			table.sort(t, function(a, b)
				return Cuae_ComparePresets(a, b)
			end)
		end

		Cuae_L("D", "Building Legs sub tables DONE")
	end

	return Cuae_AllArmor.Legs[subType]
end

local function getAllWeaponsOfType(_type, affiliation, maxSize)
	maxSize = maxSize or 2
	local tempType = table.find(Cuae_HeadTypes, _type) and "Head" or table.find(Cuae_TorsoTypes, _type) and "Torso" or table.find(Cuae_LegsTypes, _type) and "Legs" or _type

	local allWeapons = Cuae_AllArmaments[tempType] or {}
	local exclusionTable = Cuae_AffiliationExclusionTable[affiliation] or {}
	local weapons = table.ifilter(allWeapons, function(_, w)
		return not exclusionTable[w.id] and g_Classes[w.id].LargeItem + 1 <= maxSize
	end)

	if table.find(Cuae_HeadTypes, _type) then
		weapons = getHeadArmorOfSubtype(weapons, _type)
	elseif table.find(Cuae_TorsoTypes, _type) then
		weapons = getTorsoArmorOfSubtype(weapons, _type)
	elseif table.find(Cuae_LegsTypes, _type) then
		weapons = getLegsArmorOfSubtype(weapons, _type)
	end
	return weapons
end

function Cuae_CalculateAdjustedUnitLevel(settings, level, avgAllyLevel, affiliation)
	local minimum = Max(1, avgAllyLevel + settings.ArmamentStrengthFactor)
	local adjusted = level + (Cuae_AffiliationWeight[affiliation] or 0) + settings.ArmamentStrengthFactor
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

function Cuae_GetSuitableArmaments(affiliation, level, _type, originalCost, useOriginalCost, maxSize)
	local allWeaponsOfTyp = getAllWeaponsOfType(_type, affiliation, maxSize)
	if #allWeaponsOfTyp <= 1 then
		return allWeaponsOfTyp, nil
	end

	local costRangeFrom, costRangeTo = Cuae_CalculateCostRange(level, 3, 10)

	local minIdx = Min(#allWeaponsOfTyp, Max(1, DivRound(#allWeaponsOfTyp * costRangeFrom, 100)))
	local maxIdx = Max(1, Min(#allWeaponsOfTyp, DivRound(#allWeaponsOfTyp * costRangeTo, 100)))

	local originalCostIdx = nil
	if useOriginalCost and originalCost then
		originalCostIdx = getCostIdx(originalCost, allWeaponsOfTyp)
		minIdx = Min(originalCostIdx, minIdx)
		maxIdx = Max(originalCostIdx, maxIdx)
	end

	local minCost = Cuae_Cost(allWeaponsOfTyp[minIdx])
	local maxCost = Cuae_Cost(allWeaponsOfTyp[maxIdx])
	local suitableArmament = table.ifilter(allWeaponsOfTyp, function(i, a)
		return Cuae_Cost(a) >= minCost and Cuae_Cost(a) <= maxCost
	end)

	return suitableArmament, originalCostIdx
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

function Cuae_GetDefaultArmament(affiliation, _type, maxSize)
	local defaultWeapons = Cuae_DefaultWeapons[affiliation] or Cuae_DefaultWeapons.Militia
	local _id = defaultWeapons[_type]
	if _id == nil then
		return nil
	end

	if g_Classes[_id].LargeItem + 1 > maxSize then
		_id = Cuae_DefaultSmallWeapons[_type]
		if _id == nil then
			return nil
		end
	end

	Cuae_L("D", "- suitable default armament", _type, _id)
	return {
		id = _id,
	}
end

function Cuae_GetSuitableArmament(affiliation, level, _type, originalCost, useOriginalCost, maxSize)
	local suitableArmaments, originalCostIdx = Cuae_GetSuitableArmaments(affiliation, level, _type, originalCost, useOriginalCost, maxSize)
	if #suitableArmaments < 1 then
		return nil
	end
	Cuae_L("D", "- suitable armaments for AdjustedLvl:", level, _type, "Original Cost", originalCost, "min:", suitableArmaments[1].id, Cuae_Cost(suitableArmaments[1]), "max:",
	       suitableArmaments[#suitableArmaments].id, Cuae_Cost(suitableArmaments[#suitableArmaments]))

	originalCostIdx = originalCostIdx or Max(1, Min(#suitableArmaments, DivRound(#suitableArmaments, 2)))
	originalCost = useOriginalCost and originalCost or Cuae_Cost(suitableArmaments[originalCostIdx])

	local distance = {}
	local max = 0
	for _, a in ipairs(suitableArmaments) do
		distance[#distance + 1] = abs(originalCost - Cuae_Cost(a))
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
	if oddsFactorsSum == 0 then
		oddsFactorsSum = 1
	end

	local singularOdds
	local culOdds = {}
	for _, of in ipairs(oddsFactor) do
		singularOdds = DivRound(of * 1000, oddsFactorsSum)
		culOdds[#culOdds + 1] = (culOdds[#culOdds] or 0) + singularOdds
	end

	local random = InteractionRandRange(1, 1000, "LDCUAE")
	for idx, odds in ipairs(culOdds) do
		if random <= odds then
			return suitableArmaments[idx]
		end
	end

	return suitableArmaments[InteractionRandRange(1, #suitableArmaments, "LDCUAE")]
end

function Cuae_RemoveItem(unit, slot, item)
	Cuae_L("D", "- Removing original item", "Type:", item.ItemType or item.WeaponType or "", item.class, "Cost:", item.Cost)
	unit:RemoveItem(slot, item)
	DoneObject(item)
end

local aoeTypes = {
	fire = "Fire",
	smoke = "Smoke",
	teargas = "Tear",
	toxicgas = "Toxic",
}

local function getUtilityType(item)
	if IsKindOf(item, "ThrowableTrapItem") then
		return item.TriggerType
	elseif IsKindOf(item, "Flare") then
		return "Flare"
	elseif item.aoeType and aoeTypes[item.aoeType] then
		return aoeTypes[item.aoeType]
	elseif item.ItemType == "Grenade" and item.DeathType == "BlowUp" then
		return "Explosive"
	elseif IsKindOfClasses(item, "ConcussiveGrenade", "ConcussiveGrenade_IED") then
		return "Flash"
	else
		Cuae_L("E", "Unknown utility type", item.class)
		return nil
	end
end

local function handheldToWeaponProfile(handheld, hPos)
	local w = {
		ogInstance = handheld,
		isWeapon = true,
		slot = CUAE_SLOT[hPos],
		ogPresetId = handheld.class,
		ogDropChance = handheld.guarantee_drop and 100 or handheld.drop_chance,
		ogCaliber = handheld.Caliber,
		ogCondition = handheld.Condition,
		ogSize = handheld.LargeItem + 1,
		ogCost = handheld.Cost,
		ogType = handheld.WeaponType,
	}
	Cuae_L("D", "created weapon profile", w.ogPresetId, w.ogType, w.ogCaliber, "size:", w.ogSize, "Cost:", w.ogCost, "Drop chance:", w.ogDropChance)
	return w
end

local function handheldToUtilityProfile(handheld, hPos)
	local u = {
		ogInstance = handheld,
		slot = CUAE_SLOT[hPos],
		ogPresetId = handheld.class,
		ogCost = handheld.Cost,
		ogDropChance = handheld.guarantee_drop and 100 or handheld.drop_chance,
		ogType = getUtilityType(handheld),
		amount = handheld.Amount,
	}
	Cuae_L("D", "created utility profile", u.ogPresetId, u.ogType, "Amount:", u.amount, "Cost:", u.ogCost, "Drop chance:", u.ogDropChance)
	return u
end

function Cuae_GetOriginalEq(unit)
	local originalWeapons = {}
	local originalUtility = {}
	local handhelds = {
		unit:GetItemAtPos("Handheld A", 1, 1) or false,
		unit:GetItemAtPos("Handheld A", 2, 1) or false,
		unit:GetItemAtPos("Handheld B", 1, 1) or false,
		unit:GetItemAtPos("Handheld B", 2, 1) or false,
	}
	for hPos, handheld in ipairs(handhelds) do
		if handheld then
			if handheld:IsWeapon() then
				table.insert(originalWeapons, handheldToWeaponProfile(handheld, hPos))
			else
				table.insert(originalUtility, handheldToUtilityProfile(handheld, hPos))
			end
		end
	end

	local originalHead = unit:GetItemAtPos("Head", 1, 1)
	local originalTorso = unit:GetItemAtPos("Torso", 1, 1)
	local originalLegs = unit:GetItemAtPos("Legs", 1, 1)
	return {
		W = originalWeapons,
		U = originalUtility,
	}, originalHead, originalTorso, originalLegs
end

function Cuae_TableSlice(tbl, first, last)
	local sliced = {}
	for i = first, last do
		sliced[#sliced + 1] = tbl[i]
	end
	return sliced
end
