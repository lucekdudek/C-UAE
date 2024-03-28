local function generateAmmo(weaponCaliber, affiliation, adjustedUnitLevel)
	local allAmmunitionOfCaliber = Cuae_GetAllAmmunitionOfCaliber(weaponCaliber, affiliation)

	local costRangeFrom, costRangeTo = Cuae_CalculateCostRange(adjustedUnitLevel, 5, 9)

	local minIdx = Min(#allAmmunitionOfCaliber, Max(1, DivRound(#allAmmunitionOfCaliber * costRangeFrom, 100)))
	local maxIdx = Min(#allAmmunitionOfCaliber, Max(1, DivRound(#allAmmunitionOfCaliber * costRangeTo, 100)))

	local minCost = allAmmunitionOfCaliber[minIdx].Cost or 0
	local maxCost = allAmmunitionOfCaliber[maxIdx].Cost or 0
	local suitableAmmos = table.ifilter(allAmmunitionOfCaliber, function(i, a)
		return (a.Cost or 0) >= minCost and (a.Cost or 0) <= maxCost
	end)

	local ammo = suitableAmmos[InteractionRandRange(1, #suitableAmmos, "LDCUAE")]
	Cuae_Debug("-- picked suitable ammo:", weaponCaliber, ammo.id, ammo.Cost)
	return ammo
end

local function addAmmo(unit, ammo, magazineSize)
	local newAmmo = PlaceInventoryItem(ammo.id)
	newAmmo.drop_chance = newAmmo.base_drop_chance * 3 // 4
	if IsKindOf(newAmmo, "Ordnance") then
		newAmmo.Amount = Min(InteractionRandRange(2, 5, "LDCUAE"), newAmmo.MaxStacks)
	else
		-- mininium range 10-24
		-- maximum range 30-65
		newAmmo.Amount = Min(
			InteractionRandRange(Min(30, Max(10, magazineSize)), Min(65, Max(24, magazineSize * 2)), "LDCUAE"),
			newAmmo.MaxStacks)
	end
	unit:AddItem("Inventory", newAmmo)
end

local function tryAddComponentsAndAmmo(unit, adjustedUnitLevel, orginalWeapon, slot)
	if orginalWeapon and not IsKindOf(orginalWeapon, "MeleeWeapon") and not IsKindOf(orginalWeapon, "Grenade") and IsKindOf(orginalWeapon, "BaseWeapon") then
		orginalWeapon.ammo = nil
		Cuae_AddRandomComponents(orginalWeapon, adjustedUnitLevel)
		local ammo = generateAmmo(orginalWeapon.Caliber, Cuae_UnitAffiliation(unit), adjustedUnitLevel)
		unit:TryLoadAmmo(slot, "BaseWeapon", ammo.id)
		addAmmo(unit, ammo, orginalWeapon.MagazineSize)
	end
end

local function replaceWeapon(unit, adjustedUnitLevel, orginalWeapon, slot, _type, maxSize)
	local itemAdded, _ = false, nil

	local newCondition = orginalWeapon and orginalWeapon.Condition or InteractionRandRange(45, 95, "LDCUAE")

	local orginalCost = orginalWeapon and orginalWeapon.Cost or Cuae_DefaultCost[_type]
	local suitableWeapons = Cuae_GetSuitableArnaments(Cuae_UnitAffiliation(unit), adjustedUnitLevel, _type, orginalCost, maxSize)
	if #suitableWeapons < 1 then
		return false, 0, false
	end

	-- get and init final weapon from preset
	local weaponPreset = suitableWeapons[InteractionRandRange(1, #suitableWeapons, "LDCUAE")]
	local dropChance = g_Classes[weaponPreset.id].base_drop_chance
	local newWeapon = PlaceInventoryItem(weaponPreset.id)
	Cuae_Debug("- picked:", _type, weaponPreset.id, weaponPreset.Cost, "Condition:", newCondition)

	if IsKindOf(newWeapon, "MeleeWeapon") then
		newWeapon.drop_chance = dropChance
		newWeapon.Condition = newCondition
		-- TODO handle weaponPreset.CanThrow
		itemAdded, _ = unit:AddItem(slot, newWeapon)
	elseif IsKindOf(newWeapon, "Grenade") then
		newWeapon.Amount = Min(Max(Cuae_LoadedModOptions.ExtraGrenadesCount, InteractionRandRange(1, 4, "LDCUAE")), newWeapon.MaxStacks)
		itemAdded, _ = unit:AddItem(slot, newWeapon)
		-- separated stack of grenade that cna be droped (so enemy cna have stack of 10 to throw but wont drop that big of a stick to the player)
		local greadnesToDrop = PlaceInventoryItem(weaponPreset.id)
		greadnesToDrop.Amount = Min(InteractionRandRange(1, 3, "LDCUAE"), newWeapon.MaxStacks)
		-- base_chance // (100% + ExtraGrenadesChance%*2) e.g. 5 // 100% + 40%*2 => 5 // 180% => 2.777(7) => 3
		greadnesToDrop.drop_chance = DivRound(dropChance, DivRound(100 + 2 * Cuae_LoadedModOptions.ExtraGrenadesChance, 100))
		unit:AddItem("Inventory", greadnesToDrop)
	elseif IsKindOf(newWeapon, "BaseWeapon") then
		newWeapon.drop_chance = dropChance
		newWeapon.Condition = newCondition
		Cuae_AddRandomComponents(newWeapon, adjustedUnitLevel)

		local ammo = generateAmmo(newWeapon.Caliber, Cuae_UnitAffiliation(unit), adjustedUnitLevel)
		-- load weapon
		itemAdded = unit:TryEquip({ newWeapon }, slot, "BaseWeapon")
		unit:TryLoadAmmo(slot, "BaseWeapon", ammo.id)

		addAmmo(unit, ammo, newWeapon.MagazineSize)
	end
	return not not itemAdded, newWeapon:GetUIWidth(), newWeapon:IsWeapon()
end

local function allowAlternativeWeaponType(_type)
	if not Cuae_LoadedModOptions.AllowAlternativeWeaponType then
		return _type
	end
	local rand = InteractionRandRange(1, 100, "LDCUAE")
	if _type == "Handgun" then
		return rand <= 50 and "SMG" or rand <= 80 and "Shotgun" or "AssaultRifle"
	elseif _type == "SMG" then
		return rand <= 25 and "AssaultRifle" or _type
	elseif _type == "Shotgun" then
		return rand <= 15 and "AssaultRifle" or _type
	elseif _type == "AssaultRifle" then
		return rand <= 12 and "Sniper" or rand <= 20 and "MachineGun" or _type
	else
		return _type
	end
end

local function getWeaponType(weapon)
	local _type = weapon.ItemType or weapon.WeaponType
	if _type == "Grenade" or _type == "GrenadeGas" or _type == "GrenadeFire" or _type == "Throwables" then
		return Cuae_GetGrenadeCurrentType()
	elseif _type == "HeavyWeapon" then
		for heavyWeaponType, heavyWeaponCaliber in pairs(Cuae_HeavyWeaponTypeToCaliber) do
			if weapon.Caliber == heavyWeaponCaliber then
				return heavyWeaponType
			end
		end
	else
		return _type
	end
end

local function canBeReplaced(unit, adjustedUnitLevel, item, _type, allowRandom)
	local orginalCost = item and item.Cost or Cuae_DefaultCost[_type]
	local suitableReplacements = Cuae_GetSuitableArnaments(Cuae_UnitAffiliation(unit), adjustedUnitLevel, _type, orginalCost)
	return Cuae_LoadedModOptions.ReplaceWeapons and not Cuae_ImmunityTable[item.class] and #suitableReplacements > 0 and
		not (not Cuae_LoadedModOptions.AllowAlternativeWeaponType and allowRandom and InteractionRandRange(1, 100, "LDCUAE") <= 12)
end

local function isEmptyKeepOrRemove(unit, adjustedUnitLevel, handheld, orginalHandhelds, T1, T1Type, T2, T2Type)
	local T1IsEmpty, T2IsEmpty = nil, nil
	if not orginalHandhelds[T2] then
		T2IsEmpty = true
	elseif canBeReplaced(unit, adjustedUnitLevel, orginalHandhelds[T2], T2Type) then
		Cuae_Removeitem(unit, handheld, orginalHandhelds[T2])
		T2IsEmpty = true
	else
		tryAddComponentsAndAmmo(unit, adjustedUnitLevel, orginalHandhelds[T2], handheld)
		T2IsEmpty = false
		-- keep T1 as T2 cannot be removed
		tryAddComponentsAndAmmo(unit, adjustedUnitLevel, orginalHandhelds[T1], handheld)
		T1IsEmpty = false
	end
	if T1IsEmpty == nil then
		if not orginalHandhelds[T1] then
			T1IsEmpty = true
		elseif canBeReplaced(unit, adjustedUnitLevel, orginalHandhelds[T1], T1Type, "allowRandom") then
			Cuae_Removeitem(unit, handheld, orginalHandhelds[T1])
			T1IsEmpty = true
		else
			tryAddComponentsAndAmmo(unit, adjustedUnitLevel, orginalHandhelds[T1], handheld)
			T1IsEmpty = false
			if orginalHandhelds[T1]:GetUIWidth() > 1 then
				T2IsEmpty = false
			end
		end
	end
	return T1IsEmpty, T2IsEmpty
end

function Cuae_GenerateNewWeapons(unit, avgLevel, orginalHandhelds)
	local itemAdded, _ = false, nil
	local itemSize = {}
	local isWeapon = {}
	local _type1A = orginalHandhelds.A1 and allowAlternativeWeaponType(getWeaponType(orginalHandhelds.A1)) or nil
	local _type2A = orginalHandhelds.A2 and getWeaponType(orginalHandhelds.A2) or nil
	local _type1B = orginalHandhelds.B1 and allowAlternativeWeaponType(getWeaponType(orginalHandhelds.B1)) or nil
	local _type2B = orginalHandhelds.B2 and getWeaponType(orginalHandhelds.B2) or nil
	local level = Min(10, unit:GetLevel())
	local adjLevel = Cuae_CalculateAdjustedUnitLevel(level, avgLevel, Cuae_UnitAffiliation(unit))
	Cuae_Debug("C-UAE Adding new weapons", Cuae_UnitAffiliation(unit), adjLevel)
	-- unequpe | keep immunes
	local A1IsEmpty, A2IsEmpty = isEmptyKeepOrRemove(unit, adjLevel, "Handheld A", orginalHandhelds, "A1", _type1A, "A2", _type2A)
	local B1IsEmpty, B2IsEmpty = isEmptyKeepOrRemove(unit, adjLevel, "Handheld B", orginalHandhelds, "B1", _type1B, "B2", _type2B)
	-- spawn HandA1 -> HandB1 -> HandA2 -> HandB2 -> Extra Handgun -> Extra Grenade
	Cuae_Debug("- [1/6] orginal A1 (type/isEmpty)", "A:", _type1A, A1IsEmpty, _type2A, A2IsEmpty, "B:", _type1B, B1IsEmpty, _type2B, B2IsEmpty)
	local currentGrenadeType = Cuae_GetGrenadeCurrentType()
	if orginalHandhelds.A1 and A1IsEmpty then
		itemAdded, itemSize.A1, isWeapon.A1 = replaceWeapon(unit, adjLevel, orginalHandhelds.A1, "Handheld A", _type1A, 2)
		A1IsEmpty = not itemAdded
		if itemSize.A1 > 1 then
			A2IsEmpty = false
			isWeapon.A2 = isWeapon.A1
		end
	end
	Cuae_Debug("- [2/6] orginal B1 (type/isEmpty)", "A:", _type1A, A1IsEmpty, _type2A, A2IsEmpty, "B:", _type1B, B1IsEmpty, _type2B, B2IsEmpty)
	if orginalHandhelds.B1 and B1IsEmpty then
		itemAdded, itemSize.B1, isWeapon.B1 = replaceWeapon(unit, adjLevel, orginalHandhelds.B1, "Handheld B", _type1B, 2)
		B1IsEmpty = not itemAdded
		if itemSize.B1 > 1 then
			B2IsEmpty = false
			isWeapon.B2 = isWeapon.B1
		end
	end
	Cuae_Debug("- [3/6] orginal A2 (type/isEmpty)", "A:", _type1A, A1IsEmpty, _type2A, A2IsEmpty, "B:", _type1B, B1IsEmpty, _type2B, B2IsEmpty)
	if orginalHandhelds.A2 then
		if A2IsEmpty then
			itemAdded, _, isWeapon.A2 = replaceWeapon(unit, adjLevel, orginalHandhelds.A2, "Handheld A", _type2A, 1)
			A2IsEmpty = not itemAdded
		elseif B1IsEmpty then
			itemAdded, itemSize.B1, isWeapon.B1 = replaceWeapon(unit, adjLevel, orginalHandhelds.A2, "Handheld B", _type2A, 2)
			B1IsEmpty = not itemAdded
			if itemSize.B1 > 1 then
				B2IsEmpty = false
				isWeapon.B2 = isWeapon.B1
			end
		elseif B2IsEmpty then
			itemAdded, _, isWeapon.B2 = replaceWeapon(unit, adjLevel, orginalHandhelds.A2, "Handheld B", _type2A, 1)
			B2IsEmpty = not itemAdded
		end
	end
	Cuae_Debug("- [4/6] orginal B2 (type/isEmpty)", "A:", _type1A, A1IsEmpty, _type2A, A2IsEmpty, "B:", _type1B, B1IsEmpty, _type2B, B2IsEmpty)
	if orginalHandhelds.B2 then
		if B2IsEmpty then
			itemAdded, _, isWeapon.B2 = replaceWeapon(unit, adjLevel, orginalHandhelds.B2, "Handheld B", _type2B, 1)
			B2IsEmpty = not itemAdded
		elseif A2IsEmpty then
			itemAdded, _, isWeapon.A2 = replaceWeapon(unit, adjLevel, orginalHandhelds.B2, "Handheld A", _type2B, 1)
			A2IsEmpty = not itemAdded
		end
	end
	-- extra Handgun
	Cuae_Debug("- [5/6] extra Handgun (type/isEmpty)", "A:", _type1A, A1IsEmpty, _type2A, A2IsEmpty, "B:", _type1B, B1IsEmpty, _type2B, B2IsEmpty)
	if Cuae_LoadedModOptions.ExtraHandgun and _type1A ~= 'Handgun' and _type2A ~= 'Handgun' and _type1B ~= 'Handgun' and _type2B ~= 'Handgun' then
		if not isWeapon.A1 and not isWeapon.A2 then
			if A1IsEmpty then
				itemAdded, _, isWeapon.A1 = replaceWeapon(unit, adjLevel, nil, "Handheld A", 'Handgun', 1)
				A1IsEmpty = not itemAdded
			elseif A2IsEmpty then
				itemAdded, _, isWeapon.A2 = replaceWeapon(unit, adjLevel, nil, "Handheld A", 'Handgun', 1)
				A2IsEmpty = not itemAdded
			end
		elseif not isWeapon.B1 and not isWeapon.B2 then
			if B1IsEmpty then
				itemAdded, _, isWeapon.B1 = replaceWeapon(unit, adjLevel, nil, "Handheld B", 'Handgun', 1)
				B1IsEmpty = not itemAdded
			elseif B2IsEmpty then
				itemAdded, _, isWeapon.B2 = replaceWeapon(unit, adjLevel, nil, "Handheld B", 'Handgun', 1)
				B2IsEmpty = not itemAdded
			end
		end
	end
	-- extra Grenades
	Cuae_Debug("- [6/6] extra Grenades (type/isEmpty)", "A:", _type1A, A1IsEmpty, _type2A, A2IsEmpty, "B:", _type1B, B1IsEmpty, _type2B, B2IsEmpty)
	if InteractionRandRange(1, 100, "LDCUAE") <= Cuae_LoadedModOptions.ExtraGrenadesChance and Cuae_LoadedModOptions.ExtraGrenadesCount ~= 0 and _type1A ~= currentGrenadeType and _type2A ~= currentGrenadeType and _type1B ~= currentGrenadeType and _type2B ~= currentGrenadeType then
		local handheld = nil
		if A1IsEmpty or A2IsEmpty then
			handheld = "Handheld A"
		elseif B1IsEmpty or B2IsEmpty then
			handheld = "Handheld B"
		end
		if handheld then
			replaceWeapon(unit, adjLevel, nil, handheld, currentGrenadeType, 1)
		end
	end
end
