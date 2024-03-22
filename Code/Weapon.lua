local function generateAmmo(weaponCaliber, affiliation, adjustedUnitLevel)
	Cuae_Debug("-- getting suitable ammo for AdjustedLvl:", adjustedUnitLevel)

	local allAmmunitionOfCaliber = Cuae_GetAllAmmunitionOfCaliber(weaponCaliber, affiliation)

	local costRangeFrom, costRangeTo = Cuae_CalculateCostRange(adjustedUnitLevel, 5, 9)

	local minIdx = Min(#allAmmunitionOfCaliber, Max(1, DivRound(#allAmmunitionOfCaliber * costRangeFrom, 100)))
	local maxIdx = Min(#allAmmunitionOfCaliber, Max(1, DivRound(#allAmmunitionOfCaliber * costRangeTo, 100)))

	local minCost = allAmmunitionOfCaliber[minIdx].Cost or 0
	local maxCost = allAmmunitionOfCaliber[maxIdx].Cost or 0
	local suitableAmmos = table.ifilter(allAmmunitionOfCaliber, function(i, a)
		return (a.Cost or 0) >= minCost and (a.Cost or 0) <= maxCost
	end)

	Cuae_Debug("--> min:", suitableAmmos[1].id, suitableAmmos[1].Cost, "max:", suitableAmmos[#suitableAmmos].id, suitableAmmos[#suitableAmmos].Cost)

	local ammo = suitableAmmos[InteractionRandRange(1, #suitableAmmos, "LDCUAE")]
	Cuae_Debug("-- picked:", weaponCaliber, ammo.id, ammo.Cost)
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
		newAmmo.Amount = Min(InteractionRandRange(Min(30, Max(10, magazineSize)), Min(65, Max(24, magazineSize * 2)), "LDCUAE"), newAmmo.MaxStacks)
	end
	unit:AddItem("Inventory", newAmmo)
end

local function tryAddComponentsAndAmmo(unit, adjustedUnitLevel, orginalWeapon)
	if not IsKindOf(orginalWeapon, "MeleeWeapon") and not IsKindOf(orginalWeapon, "Grenade") and IsKindOf(orginalWeapon, "BaseWeapon") then
		Cuae_AddRandomComponents(orginalWeapon, adjustedUnitLevel)
		addAmmo(unit, generateAmmo(orginalWeapon.Caliber, Cuae_UnitAffiliation(unit), adjustedUnitLevel), orginalWeapon.MagazineSize)
	end
end

local function replaceWeapon(unit, adjustedUnitLevel, orginalWeapon, slot, _type, extraGrenadeQuantity)
	local itemAdded, reason = false, ""
	-- extraGrenadeQuantity(Options.ExtraGrenadesCount) is affected by Options.ExtraGrenadesChance
	if extraGrenadeQuantity ~= nil and InteractionRandRange(1, 100, "LDCUAE") > Cuae_LoadedModOptions.ExtraGrenadesChance then
		return itemAdded, reason
	end

	local orginalCost = orginalWeapon and orginalWeapon.Cost or Cuae_DefaultCost[_type]
	local newCondition = orginalWeapon and orginalWeapon.Condition or InteractionRandRange(45, 95, "LDCUAE")

	local suitableWeapons = Cuae_GetSuitableArnaments(Cuae_UnitAffiliation(unit), adjustedUnitLevel, _type, orginalCost)

	local keepOrginal = orginalWeapon and InteractionRandRange(1, 100, "LDCUAE") <= 12
	if #suitableWeapons == 0 or keepOrginal then
		Cuae_Debug("- skipping as no siutable weapons were found", _type, "keepOrginal", keepOrginal, "for", Cuae_UnitAffiliation(unit))
		if orginalWeapon then
			Cuae_Debug("- keeping(no siutable):", _type, orginalWeapon.class, orginalWeapon.Cost, "Condition:", orginalWeapon.Condition)
			tryAddComponentsAndAmmo(unit, adjustedUnitLevel, orginalWeapon)
		end
		return itemAdded, reason
	end

	-- remove orginal weapon
	if orginalWeapon then
		Cuae_Removeitem(unit, slot, orginalWeapon)
	end

	-- get and init final weapon from preset
	local weaponPreset = suitableWeapons[InteractionRandRange(1, #suitableWeapons, "LDCUAE")]
	local newWeapon = PlaceInventoryItem(weaponPreset.id)
	newWeapon.drop_chance = g_Classes[weaponPreset.id].base_drop_chance
	Cuae_Debug("- picked:", _type, weaponPreset.id, weaponPreset.Cost, "Condition:", newCondition)

	if IsKindOf(newWeapon, "MeleeWeapon") then
		newWeapon.Condition = newCondition
		-- TODO handle weaponPreset.CanThrow
		itemAdded, reason = unit:AddItem(slot, newWeapon)
	elseif IsKindOf(newWeapon, "Grenade") then
		 -- TODO use extraGrenadeQuantity
		newWeapon.Amount = Min(extraGrenadeQuantity or InteractionRandRange(1, 4, "LDCUAE"), newWeapon.MaxStacks)
		itemAdded, reason = unit:AddItem(slot, newWeapon)
	elseif IsKindOf(newWeapon, "BaseWeapon") then
		newWeapon.Condition = newCondition
		Cuae_AddRandomComponents(newWeapon, adjustedUnitLevel)

		local ammo = generateAmmo(newWeapon.Caliber, Cuae_UnitAffiliation(unit), adjustedUnitLevel)
		-- load weapon
		itemAdded = unit:TryEquip({ newWeapon }, slot, "BaseWeapon")
		unit:TryLoadAmmo(slot, "BaseWeapon", ammo.id)

		addAmmo(unit, ammo, newWeapon.MagazineSize)
	end
	return not not itemAdded, reason
end

local function allowAlternativeWeaponType(_type)
	if not Cuae_LoadedModOptions.AllowAlternativeWeaponType then
		return _type
	end
	local rand = InteractionRandRange(1, 100, "LDCUAE")
	if _type == "Handgun" then
		return rand <= 50 and "SMG" or rand <= 80 and "Shotgun" or rand <= 100 and "AssaultRifle" or _type
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

local function canReplaceOrAddAmmo(unit, adjustedUnitLevel, orginalWeapon1, orginalWeapon2)
	if not Cuae_LoadedModOptions.ReplaceWeapons or Cuae_ImmunityTable[orginalWeapon1.class] or (orginalWeapon2 and Cuae_ImmunityTable[orginalWeapon2.class]) then
		Cuae_Debug("- keeping(immunity):", orginalWeapon1.class, orginalWeapon1.Cost, "Condition:", orginalWeapon1.Condition)
		tryAddComponentsAndAmmo(unit, adjustedUnitLevel, orginalWeapon1)
		if orginalWeapon2 then
			Cuae_Debug("- keeping(immunity):", orginalWeapon2.class, orginalWeapon2.Cost, "Condition:", orginalWeapon2.Condition)
			tryAddComponentsAndAmmo(unit, adjustedUnitLevel, orginalWeapon2)
		end
		return false
	else
		return true
	end
end

function Cuae_GenerateNewWeapons(unit, avgLevel, orginalHandheldsA, orginalHandheldsB)
	local level = Min(10, unit:GetLevel())
	local adjLevel = Cuae_CalculateAdjustedUnitLevel(level, avgLevel, Cuae_UnitAffiliation(unit))
	Cuae_Debug("C-UAE Adding new weapons", Cuae_UnitAffiliation(unit), adjLevel)
	-- Night/Day cycle affects grenades
	local currentGrenadeType = Cuae_GetGrenadeCurrentType()
	local _type1A, _type2A, _type1B, _type2B = nil, nil, nil, nil
	local orginalHandheldsA2ItemAdded, reason = true, ""
	-- Handheld A
	if #orginalHandheldsA == 1 then
		_type1A = allowAlternativeWeaponType(getWeaponType(orginalHandheldsA[1]))
		if canReplaceOrAddAmmo(unit, adjLevel, orginalHandheldsA[1]) then
			replaceWeapon(unit, adjLevel, orginalHandheldsA[1], "Handheld A", _type1A)
		end
	elseif #orginalHandheldsA == 2 then
		_type1A = allowAlternativeWeaponType(getWeaponType(orginalHandheldsA[1]))
		_type2A = getWeaponType(orginalHandheldsA[2])
		if canReplaceOrAddAmmo(unit, adjLevel, orginalHandheldsA[1], orginalHandheldsA[2]) then
			-- TODO fix #suitableWeapons == 0: move suitableWeapons logic out of replaceWeapon function
			Cuae_Removeitem(unit, "Handheld A", orginalHandheldsA[2])
			replaceWeapon(unit, adjLevel, orginalHandheldsA[1], "Handheld A", _type1A)
			orginalHandheldsA2ItemAdded, reason = replaceWeapon(unit, adjLevel, orginalHandheldsA[2], "Handheld A", _type2A)
		end
	end
	-- Handheld B
	if #orginalHandheldsB == 1 then
		_type1B = allowAlternativeWeaponType(getWeaponType(orginalHandheldsB[1]))
		if canReplaceOrAddAmmo(unit, adjLevel, orginalHandheldsB[1]) then
			replaceWeapon(unit, adjLevel, orginalHandheldsB[1], "Handheld B", _type1B)
		end
	elseif #orginalHandheldsB == 2 then
		_type1B = allowAlternativeWeaponType(getWeaponType(orginalHandheldsB[1]))
		_type2B = getWeaponType(orginalHandheldsB[2])
		if canReplaceOrAddAmmo(unit, adjLevel, orginalHandheldsB[1], orginalHandheldsB[2]) then
			Cuae_Removeitem(unit, "Handheld B", orginalHandheldsB[2])
			replaceWeapon(unit, adjLevel, orginalHandheldsB[1], "Handheld B", _type1B)
			replaceWeapon(unit, adjLevel, orginalHandheldsB[2], "Handheld B", _type2B)
		end
	elseif orginalHandheldsA2ItemAdded == false then
		Cuae_Debug("-- there was no sapce for", _type2A, "in Handheld A, but there is in Handheld B")
		replaceWeapon(unit, adjLevel, orginalHandheldsA[2], "Handheld B", _type2A)
		_type1B = _type2A
	end
	-- extra Handgun
	if _type1B == nil and Cuae_LoadedModOptions.ExtraHandgun and _type1A ~= 'Handgun' and _type2A ~= 'Handgun' then
		replaceWeapon(unit, adjLevel, nil, "Handheld B", 'Handgun')
	end
	-- extra Grenades
	if _type1B == nil and Cuae_LoadedModOptions.ExtraGrenadesCount ~= 0 and _type1A ~= currentGrenadeType and _type2A ~= currentGrenadeType then
		replaceWeapon(unit, adjLevel, nil, "Handheld B", currentGrenadeType, Cuae_LoadedModOptions.ExtraGrenadesCount)
	end
end
