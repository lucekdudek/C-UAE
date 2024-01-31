local function generateAmmo(weaponCaliber, adjustedUnitLevel)
	Debug("-- getting suitable ammo for AdjustedLvl:", adjustedUnitLevel)

	if not AllAmmunition[weaponCaliber] then
		Debug("C-UAE Building", weaponCaliber, "ammunition table...")
		AllAmmunition[weaponCaliber] = GetAmmosWithCaliber(weaponCaliber)
		table.sort(AllAmmunition[weaponCaliber], function(a, b) return (a.Cost or 0) < (b.Cost or 0) end)
		for _, a in pairs(AllAmmunition[weaponCaliber]) do
			Debug(">>", a.id, "Cost:", a.Cost)
		end
		Debug("C-UAE Building", weaponCaliber, "ammunition table DONE")
	end

	local costRangeFrom, costRangeTo = CalculateCostRange(adjustedUnitLevel, 5, 9)

	local minIdx = Min(#AllAmmunition[weaponCaliber],
		Max(1, DivRound(#AllAmmunition[weaponCaliber] * costRangeFrom, 100)))
	local maxIdx = Min(#AllAmmunition[weaponCaliber], Max(1, DivRound(#AllAmmunition[weaponCaliber] * costRangeTo, 100)))

	local minCost = AllAmmunition[weaponCaliber][minIdx].Cost or 0
	local maxCost = AllAmmunition[weaponCaliber][maxIdx].Cost or 0
	local suitableAmmos = table.ifilter(AllAmmunition[weaponCaliber], function(i, a)
		return (a.Cost or 0) >= minCost and (a.Cost or 0) <= maxCost
	end)

	Debug("--> min:", suitableAmmos[1].id, suitableAmmos[1].Cost, "max:", suitableAmmos[#suitableAmmos].id,
		suitableAmmos[#suitableAmmos].Cost)

	local ammo = suitableAmmos[InteractionRandRange(1, #suitableAmmos, "LDCUAE")]
	Debug("-- picked:", weaponCaliber, ammo.id, ammo.Cost)
	return ammo
end

local function addAmmo(unit, ammo, magazineSize)
	local newAmmo = PlaceInventoryItem(ammo.id)
	newAmmo.drop_chance = newAmmo.base_drop_chance // 2
	if IsKindOf(newAmmo, "Ordnance") then
		newAmmo.Amount = Min(InteractionRandRange(2, 5, "LDCUAE"), newAmmo.MaxStacks)
	else
		newAmmo.Amount = Min(InteractionRandRange(Max(8, magazineSize), Max(12, magazineSize * 2), "LDCUAE"),
			newAmmo.MaxStacks)
	end
	unit:AddItem("Inventory", newAmmo)
end

local function keepOrginalWeapon(unit, orginalWeapon, _type, adjustedUnitLevel)
	Debug("- keeping(immunity):", _type, orginalWeapon.class, orginalWeapon.Cost, "Condition:", orginalWeapon.Condition)
	if not IsKindOf(orginalWeapon, "MeleeWeapon") and not IsKindOf(orginalWeapon, "Grenade") and IsKindOf(orginalWeapon, "BaseWeapon") then
		addAmmo(unit, generateAmmo(orginalWeapon.Caliber, adjustedUnitLevel), orginalWeapon.MagazineSize)
	end
end


local function replaceWeapon(unit, orginalWeapon, slot, _type, extraGrenadeQuantity)
	local unitLevel = Min(10, unit:GetLevel())
	local adjustedUnitLevel = CalculateAdjustedUnitLevel(unitLevel, unit.Affiliation)

	if orginalWeapon and ImmunityTable[orginalWeapon.class] then
		keepOrginalWeapon(unit, orginalWeapon, _type, adjustedUnitLevel)
		return
	end

	-- extraGrenadeQuantity(Options.ExtraGrenadesCount) is affected by Options.ExtraGrenadesChance
	if extraGrenadeQuantity ~= nil and InteractionRand(100, "LDCUAE") > LoadedModOptions.ExtraGrenadesChance then
		return
	end

	local orginalCost = orginalWeapon and orginalWeapon.Cost or DefaultCost[_type]
	local newCondition = orginalWeapon and orginalWeapon.Condition or InteractionRandRange(45, 95, "LDCUAE")

	local suitableWeapons = GetSuitableArnaments(unit.Affiliation, adjustedUnitLevel, _type, orginalCost)

	if #suitableWeapons == 0 then
		Debug("- skipping as no siutable weapons were found", _type, "for", unit.Affiliation)
		if orginalWeapon then
			keepOrginalWeapon(unit, orginalWeapon, _type, adjustedUnitLevel)
		end
		return
	end

	-- remove orginal weapon
	if orginalWeapon then
		Removeitem(unit, slot, orginalWeapon)
	end

	-- get and init final weapon from preset
	local weaponPreset = suitableWeapons[InteractionRandRange(1, #suitableWeapons, "LDCUAE")]
	local newWeapon = PlaceInventoryItem(weaponPreset.id)
	newWeapon.drop_chance = IsKindOf(newWeapon, "Grenade") and 5 or newWeapon.base_drop_chance
	Debug("- picked:", _type, weaponPreset.id, weaponPreset.Cost, "Condition:", newCondition)

	if IsKindOf(newWeapon, "MeleeWeapon") then
		newWeapon.Condition = newCondition
		unit:AddItem(slot, newWeapon)
	elseif IsKindOf(newWeapon, "Grenade") then
		newWeapon.Amount = Min(extraGrenadeQuantity or InteractionRandRange(1, 4, "LDCUAE"), newWeapon.MaxStacks)
		unit:AddItem(slot, newWeapon)
	elseif IsKindOf(newWeapon, "BaseWeapon") then
		newWeapon.Condition = newCondition
		AddRandomComponents(newWeapon, adjustedUnitLevel)

		local ammo = generateAmmo(newWeapon.Caliber, adjustedUnitLevel)
		-- load weapon
		unit:TryEquip({ newWeapon }, slot, "BaseWeapon")
		unit:TryLoadAmmo(slot, "BaseWeapon", ammo.id)

		addAmmo(unit, ammo, newWeapon.MagazineSize)
	end
end

local function AllowAlternativeWeaponType(_type)
	if not LoadedModOptions.AllowAlternativeWeaponType then
		return _type
	end
	local rand = InteractionRand(100, "LDCUAE")
	if _type == "Handgun" then
		return rand <= 20 and "SMG" or _type
	elseif _type == "SMG" then
		return rand <= 30 and "AssaultRifle" or _type
	elseif _type == "AssaultRifle" then
		return rand <= 5 and "Sniper" or rand <= 15 and "MachineGun" or _type
	else
		return _type
	end
end

function GenerateNewWeapons(unit, orginalHandheldsA, orginalHandheldsB)
	Debug("C-UAE Adding new weapons", unit.Affiliation)
	-- Night/Day cycle affects grenades
	local currentGrenadeType = GetGrenadeCurrentType()
	local _type1A, _type2A, _type1B, _type2B = nil, nil, nil, nil
	-- Handheld A
	if #orginalHandheldsA == 1 then
		_type1A = GetWeaponType(orginalHandheldsA[1])
		replaceWeapon(unit, orginalHandheldsA[1], "Handheld A", AllowAlternativeWeaponType(_type1A))
	elseif #orginalHandheldsA == 2 then
		_type1A = GetWeaponType(orginalHandheldsA[1])
		_type2A = GetWeaponType(orginalHandheldsA[2])
		replaceWeapon(unit, orginalHandheldsA[1], "Handheld A", _type1A)
		replaceWeapon(unit, orginalHandheldsA[2], "Handheld A", _type2A)
	end
	-- Handheld B
	if #orginalHandheldsB == 1 then
		_type1B = GetWeaponType(orginalHandheldsB[1])
		replaceWeapon(unit, orginalHandheldsB[1], "Handheld B", AllowAlternativeWeaponType(_type1B))
	elseif #orginalHandheldsB == 2 then
		_type1B = GetWeaponType(orginalHandheldsB[1])
		_type2B = GetWeaponType(orginalHandheldsB[2])
		replaceWeapon(unit, orginalHandheldsB[1], "Handheld B", _type1B)
		replaceWeapon(unit, orginalHandheldsB[2], "Handheld B", _type2B)
	elseif LoadedModOptions.ExtraHandgun and LoadedModOptions.ExtraGrenadesCount ~= 0 and _type1A ~= 'Handgun' and _type2A ~= 'Handgun' and _type1A ~= currentGrenadeType and _type2A ~= currentGrenadeType then
		replaceWeapon(unit, nil, "Handheld B", 'Handgun')
		replaceWeapon(unit, nil, "Handheld B", currentGrenadeType, LoadedModOptions.ExtraGrenadesCount)
	elseif LoadedModOptions.ExtraHandgun and _type1A ~= 'Handgun' and _type2A ~= 'Handgun' then
		replaceWeapon(unit, nil, "Handheld B", 'Handgun')
	elseif LoadedModOptions.ExtraGrenadesCount ~= 0 and _type1A ~= currentGrenadeType and _type2A ~= currentGrenadeType then
		replaceWeapon(unit, nil, "Handheld B", currentGrenadeType, LoadedModOptions.ExtraGrenadesCount)
	end
end
