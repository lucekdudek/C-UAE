local function generateAmmo(weaponCaliber, adjustedUnitLevel)
	Cuae_Debug("-- getting suitable ammo for AdjustedLvl:", adjustedUnitLevel)

	if not Cuae_AllAmmunition[weaponCaliber] then
		Cuae_Debug("C-UAE Building", weaponCaliber, "ammunition table...")
		Cuae_AllAmmunition[weaponCaliber] = GetAmmosWithCaliber(weaponCaliber)
		table.sort(Cuae_AllAmmunition[weaponCaliber], function(a, b) return (a.Cost or 0) < (b.Cost or 0) end)
		for _, a in pairs(Cuae_AllAmmunition[weaponCaliber]) do
			Cuae_Debug(">>", a.id, "Cost:", a.Cost)
		end
		Cuae_Debug("C-UAE Building", weaponCaliber, "ammunition table DONE")
	end

	local costRangeFrom, costRangeTo = Cuae_CalculateCostRange(adjustedUnitLevel, 5, 9)

	local minIdx = Min(#Cuae_AllAmmunition[weaponCaliber],
		Max(1, DivRound(#Cuae_AllAmmunition[weaponCaliber] * costRangeFrom, 100)))
	local maxIdx = Min(#Cuae_AllAmmunition[weaponCaliber],
		Max(1, DivRound(#Cuae_AllAmmunition[weaponCaliber] * costRangeTo, 100)))

	local minCost = Cuae_AllAmmunition[weaponCaliber][minIdx].Cost or 0
	local maxCost = Cuae_AllAmmunition[weaponCaliber][maxIdx].Cost or 0
	local suitableAmmos = table.ifilter(Cuae_AllAmmunition[weaponCaliber], function(i, a)
		return (a.Cost or 0) >= minCost and (a.Cost or 0) <= maxCost
	end)

	Cuae_Debug("--> min:", suitableAmmos[1].id, suitableAmmos[1].Cost, "max:", suitableAmmos[#suitableAmmos].id,
		suitableAmmos[#suitableAmmos].Cost)

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
		newAmmo.Amount = Min(InteractionRandRange(Max(8, magazineSize), Max(12, magazineSize * 2), "LDCUAE"),
			newAmmo.MaxStacks)
	end
	unit:AddItem("Inventory", newAmmo)
end

local function keepOrginalWeapon(unit, orginalWeapon, _type, adjustedUnitLevel)
	Cuae_Debug("- keeping(immunity):", _type, orginalWeapon.class, orginalWeapon.Cost, "Condition:",
		orginalWeapon.Condition)
	if not IsKindOf(orginalWeapon, "MeleeWeapon") and not IsKindOf(orginalWeapon, "Grenade") and IsKindOf(orginalWeapon, "BaseWeapon") then
		addAmmo(unit, generateAmmo(orginalWeapon.Caliber, adjustedUnitLevel), orginalWeapon.MagazineSize)
	end
end


local function replaceWeapon(unit, orginalWeapon, slot, _type, extraGrenadeQuantity)
	local unitLevel = Min(10, unit:GetLevel())
	local adjustedUnitLevel = Cuae_CalculateAdjustedUnitLevel(unitLevel, unit.Affiliation)

	if orginalWeapon and (Cuae_ImmunityTable[orginalWeapon.class] or not Cuae_LoadedModOptions.ReplaceWeapons) then
		keepOrginalWeapon(unit, orginalWeapon, _type, adjustedUnitLevel)
		return
	end

	-- extraGrenadeQuantity(Options.ExtraGrenadesCount) is affected by Options.ExtraGrenadesChance
	if extraGrenadeQuantity ~= nil and InteractionRand(100, "LDCUAE") > Cuae_LoadedModOptions.ExtraGrenadesChance then
		return
	end

	local orginalCost = orginalWeapon and orginalWeapon.Cost or Cuae_DefaultCost[_type]
	local newCondition = orginalWeapon and orginalWeapon.Condition or InteractionRandRange(45, 95, "LDCUAE")

	local suitableWeapons = Cuae_GetSuitableArnaments(unit.Affiliation, adjustedUnitLevel, _type, orginalCost)

	if #suitableWeapons == 0 then
		Cuae_Debug("- skipping as no siutable weapons were found", _type, "for", unit.Affiliation)
		if orginalWeapon then
			keepOrginalWeapon(unit, orginalWeapon, _type, adjustedUnitLevel)
		end
		return
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
		unit:AddItem(slot, newWeapon)
	elseif IsKindOf(newWeapon, "Grenade") then
		newWeapon.Amount = Min(extraGrenadeQuantity or InteractionRandRange(1, 4, "LDCUAE"), newWeapon.MaxStacks)
		unit:AddItem(slot, newWeapon)
	elseif IsKindOf(newWeapon, "BaseWeapon") then
		newWeapon.Condition = newCondition
		Cuae_AddRandomComponents(newWeapon, adjustedUnitLevel)

		local ammo = generateAmmo(newWeapon.Caliber, adjustedUnitLevel)
		-- load weapon
		unit:TryEquip({ newWeapon }, slot, "BaseWeapon")
		unit:TryLoadAmmo(slot, "BaseWeapon", ammo.id)

		addAmmo(unit, ammo, newWeapon.MagazineSize)
	end
end

local function allowAlternativeWeaponType(_type)
	if not Cuae_LoadedModOptions.AllowAlternativeWeaponType then
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

function Cuae_GenerateNewWeapons(unit, orginalHandheldsA, orginalHandheldsB)
	Cuae_Debug("C-UAE Adding new weapons", unit.Affiliation)
	-- Night/Day cycle affects grenades
	local currentGrenadeType = Cuae_GetGrenadeCurrentType()
	local _type1A, _type2A, _type1B, _type2B = nil, nil, nil, nil
	-- Handheld A
	if #orginalHandheldsA == 1 then
		_type1A = getWeaponType(orginalHandheldsA[1])
		replaceWeapon(unit, orginalHandheldsA[1], "Handheld A", allowAlternativeWeaponType(_type1A))
	elseif #orginalHandheldsA == 2 then
		_type1A = getWeaponType(orginalHandheldsA[1])
		_type2A = getWeaponType(orginalHandheldsA[2])
		replaceWeapon(unit, orginalHandheldsA[1], "Handheld A", _type1A)
		replaceWeapon(unit, orginalHandheldsA[2], "Handheld A", _type2A)
	end
	-- Handheld B
	if #orginalHandheldsB == 1 then
		_type1B = getWeaponType(orginalHandheldsB[1])
		replaceWeapon(unit, orginalHandheldsB[1], "Handheld B", allowAlternativeWeaponType(_type1B))
	elseif #orginalHandheldsB == 2 then
		_type1B = getWeaponType(orginalHandheldsB[1])
		_type2B = getWeaponType(orginalHandheldsB[2])
		replaceWeapon(unit, orginalHandheldsB[1], "Handheld B", _type1B)
		replaceWeapon(unit, orginalHandheldsB[2], "Handheld B", _type2B)
	elseif Cuae_LoadedModOptions.ExtraHandgun and Cuae_LoadedModOptions.ExtraGrenadesCount ~= 0 and _type1A ~= 'Handgun' and _type2A ~= 'Handgun' and _type1A ~= currentGrenadeType and _type2A ~= currentGrenadeType then
		replaceWeapon(unit, nil, "Handheld B", 'Handgun')
		replaceWeapon(unit, nil, "Handheld B", currentGrenadeType, Cuae_LoadedModOptions.ExtraGrenadesCount)
	elseif Cuae_LoadedModOptions.ExtraHandgun and _type1A ~= 'Handgun' and _type2A ~= 'Handgun' then
		replaceWeapon(unit, nil, "Handheld B", 'Handgun')
	elseif Cuae_LoadedModOptions.ExtraGrenadesCount ~= 0 and _type1A ~= currentGrenadeType and _type2A ~= currentGrenadeType then
		replaceWeapon(unit, nil, "Handheld B", currentGrenadeType, Cuae_LoadedModOptions.ExtraGrenadesCount)
	end
end
