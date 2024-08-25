function Cuae_Debug(...)
	if Cuae_LoadedModOptions.Debug then
		print(...)
	end
end

function Cuae_Cost(preset)
	return preset.id and g_Classes[preset.id] and g_Classes[preset.id].Cost or 0
end

function Cuae_CoparePresets(presetA, presetB)
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
		Cuae_Debug("C-UAE Building Head sub tables...")

		Cuae_AllArmor.Head.LHead = {}
		Cuae_AllArmor.Head.MHead = {}
		Cuae_AllArmor.Head.HHead = {}

		for _, a in ipairs(allArmor) do
			table.insert(Cuae_AllArmor.Head[Cuae_GetHeadSubType(g_Classes[a.id])], a)
		end

		for _, t in pairs(Cuae_AllArmor.Head) do
			table.sort(t, function(a, b)
				return Cuae_CoparePresets(a, b)
			end)
		end

		Cuae_Debug("C-UAE Building Head sub tables DONE")
	end

	return Cuae_AllArmor.Head[subType]
end

local function getTorsoArmorOfSubtype(allArmor, subType)
	if next(Cuae_AllArmor.Torso) == nil then
		Cuae_Debug("C-UAE Building Torso sub tables...")

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
				return Cuae_CoparePresets(a, b)
			end)
		end

		Cuae_Debug("C-UAE Building Torso sub tables DONE")
	end

	return Cuae_AllArmor.Torso[subType]
end

local function getLegsArmorOfSubtype(allArmor, subType)
	if next(Cuae_AllArmor.Legs) == nil then
		Cuae_Debug("C-UAE Building Legs sub tables...")

		Cuae_AllArmor.Legs.LLegs = {}
		Cuae_AllArmor.Legs.MLegs = {}
		Cuae_AllArmor.Legs.HLegs = {}

		for _, a in ipairs(allArmor) do
			table.insert(Cuae_AllArmor.Legs[Cuae_GetLegsSubType(g_Classes[a.id])], a)
		end

		for _, t in pairs(Cuae_AllArmor.Legs) do
			table.sort(t, function(a, b)
				return Cuae_CoparePresets(a, b)
			end)
		end

		Cuae_Debug("C-UAE Building Legs sub tables DONE")
	end

	return Cuae_AllArmor.Legs[subType]
end

local function getGrenadesOfSubtype(allGrenades, subType)
	if next(Cuae_AllGrenade) == nil then
		Cuae_Debug("C-UAE Building Grenade sub tables...")

		Cuae_AllGrenade.GrenadeSmoke = {}
		Cuae_AllGrenade.GrenadeTrap = {}
		Cuae_AllGrenade.GrenadeNight = {}
		Cuae_AllGrenade.GrenadeHe = {}
		Cuae_AllGrenade.GrenadeUtil = {}

		for _, g in ipairs(allGrenades) do
			local gCls = g_Classes[g.id]
			if IsKindOf(gCls, "ThrowableTrapItem") then
				table.insert(Cuae_AllGrenade.GrenadeTrap, g)
				print("- ThrowableTrapItem", g.id)
			elseif IsKindOf(gCls, "Flare") then
				table.insert(Cuae_AllGrenade.GrenadeNight, g)
				print("- GrenadeNight", g.id)
			elseif gCls.aoeType == "smoke" or gCls.aoeType == "teargas" or gCls.aoeType == "toxicgas" then
				table.insert(Cuae_AllGrenade.GrenadeSmoke, g)
				print("- GrenadeSmoke", g.id)
			elseif gCls.DeathType == "BlowUp" then
				table.insert(Cuae_AllGrenade.GrenadeHe, g)
				print("- GrenadeHe", g.id)
			else
				table.insert(Cuae_AllGrenade.GrenadeUtil, g)
				print("- GrenadeUtil", g.id)
			end
		end

		for _, t in pairs(Cuae_AllGrenade) do
			table.sort(t, function(a, b)
				return Cuae_CoparePresets(a, b)
			end)
		end

		Cuae_Debug("C-UAE Building Grenade sub tables DONE")
	end

	Cuae_Debug("-- picking Grenade subType", subType)
	if subType == "Grenade" then
		local subTypes = table.copy(Cuae_GrenadeSubTypes)
		if (GameState.Night or GameState.Underground) then
			table.insert(subTypes, Cuae_GrenadeNightSubType)
		end

		table.sort(subTypes, function(a, b)
			return a < b
		end)

		for i, t in ipairs(subTypes) do
			Cuae_Debug("--- sorted subTypes:", i, t)
		end

		subType = subTypes[InteractionRandRange(1, #subTypes, "LDCUAE")]
	end
	Cuae_Debug("-- picked Grenade subType:", subType)

	if #Cuae_AllGrenade[subType] >= 1 then
		return Cuae_AllGrenade[subType]
	else
		Cuae_Debug("--- picked Grenade subType:", subType, "is empty. Using all grenades instead")
		return allGrenades
	end
end

function Cuae_GetAllWeaponsOfType(_type, affiliation, maxSize)
	maxSize = maxSize or 2
	local tempType = table.find(Cuae_GrenadeTypes, _type) and "Grenade" or table.find(Cuae_HeadTypes, _type) and "Head" or table.find(Cuae_TorsoTypes, _type) and "Torso"
					                 or table.find(Cuae_LegsTypes, _type) and "Legs" or _type

	local allWeapons = Cuae_AllWeapons[tempType] or {}
	local exclusionTable = Cuae_AffiliationExclusionTable[affiliation] or {}
	local weapons = table.ifilter(allWeapons, function(_, w)
		return not exclusionTable[w.id] and g_Classes[w.id].LargeItem + 1 <= maxSize
	end)

	if table.find(Cuae_GrenadeTypes, _type) then
		weapons = getGrenadesOfSubtype(weapons, _type)
	elseif table.find(Cuae_HeadTypes, _type) then
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
function Cuae_GetSuitableArnaments(affiliation, level, _type, orginalCost, useOrginalCost, maxSize)
	local allWeaponsOfTyp = Cuae_GetAllWeaponsOfType(_type, affiliation, maxSize)
	if #allWeaponsOfTyp <= 1 then
		return allWeaponsOfTyp, nil
	end

	local costRangeFrom, costRangeTo = Cuae_CalculateCostRange(level, 3, 10)

	local minIdx = Min(#allWeaponsOfTyp, Max(1, DivRound(#allWeaponsOfTyp * costRangeFrom, 100)))
	local maxIdx = Max(1, Min(#allWeaponsOfTyp, DivRound(#allWeaponsOfTyp * costRangeTo, 100)))

	local orginalCostIdx = nil
	if useOrginalCost and orginalCost then
		orginalCostIdx = getCostIdx(orginalCost, allWeaponsOfTyp)
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
	if _id == nil then
		return nil
	end

	if g_Classes[_id].LargeItem + 1 > maxSize then
		_id = Cuae_DefaultSmallWeapons[_type]
		if _id == nil then
			return nil
		end
	end

	Cuae_Debug("- suitable default arnament", _type, _id)
	return {
		id = _id,
	}
end

function Cuae_GetSuitableArnament(affiliation, level, _type, orginalCost, useOrginalCost, maxSize)
	local suitableArnaments, orginalCostIdx = Cuae_GetSuitableArnaments(affiliation, level, _type, orginalCost, useOrginalCost, maxSize)
	if #suitableArnaments < 1 then
		return nil
	end
	Cuae_Debug("- suitable arnaments for AdjustedLvl:", level, _type, "Orginal Cost", orginalCost, "min:", suitableArnaments[1].id, Cuae_Cost(suitableArnaments[1]), "max:",
					suitableArnaments[#suitableArnaments].id, Cuae_Cost(suitableArnaments[#suitableArnaments]))

	orginalCostIdx = orginalCostIdx or Max(1, Min(#suitableArnaments, DivRound(#suitableArnaments, 2)))
	orginalCost = useOrginalCost and orginalCost or Cuae_Cost(suitableArnaments[orginalCostIdx])

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
			return suitableArnaments[idx]
		end
	end

	return suitableArnaments[InteractionRandRange(1, #suitableArnaments, "LDCUAE")]
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
