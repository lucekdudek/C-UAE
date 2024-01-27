local function generateAmmo(weaponCaliber, adjustedUnitLevel)
	Debug(">>-- getting suitable ammo for AdjustedLvl:", adjustedUnitLevel)

	local allAmmos = GetAmmosWithCaliber(weaponCaliber)
	table.sort(allAmmos, function(a, b) return (a.Cost or 0) < (b.Cost or 0) end)

	local costRangeFrom, costRangeTo = CalculateCostRange(adjustedUnitLevel, 5, 9)

	local minIdx = Max(1, DivRound(#allAmmos * costRangeFrom, 100))
	local maxIdx = Min(#allAmmos, DivRound(#allAmmos * costRangeTo, 100))

	local suitableAmmos = table.ifilter(allAmmos, function(i, a)
		return (a.Cost or 0) >= (allAmmos[minIdx].Cost or 0) and (a.Cost or 0) <= (allAmmos[maxIdx].Cost or 0)
	end)

	Debug(">>-->> from", suitableAmmos[1].id, suitableAmmos[1].Cost, "to", suitableAmmos[#suitableAmmos].id, suitableAmmos[#suitableAmmos].Cost)
	-- for _, a in ipairs(suitableAmmos) do
	-- 	Debug(">>>>", a.id, a.Cost)
	-- end

	local ammo = suitableAmmos[InteractionRandRange(1, #suitableAmmos, "LDCUAE")]
	Debug(">>>> picked", weaponCaliber, ammo.id, ammo.Cost)
	return ammo
end


local function generateWeapon(unit, slot, _type, orginalCost, grenadeQuantity)
	local unitLevel = Min(10, unit:GetLevel())
	local adjustedUnitLevel = CalculateAdjustedUnitLevel(unitLevel, unit.Affiliation)

	if _type == "Grenade" and orginalCost == 0 and InteractionRand(100, "LDCUAE") > LoadedModOptions.ExtraGrenadesChance then
		return
	end

	local suitableWeapons = GetSuitableArnaments(adjustedUnitLevel, _type, orginalCost)

	-- get and init final weapon from preset
	local weaponPreset = suitableWeapons[InteractionRandRange(1, #suitableWeapons, "LDCUAE")]
	local newWeapon = PlaceInventoryItem(weaponPreset.id)
	newWeapon.drop_chance = IsKindOf(newWeapon, "Grenade") and 5 or newWeapon.base_drop_chance
	Debug(">> picked", _type, weaponPreset.id, weaponPreset.Cost)

	if IsKindOf(newWeapon, "MeleeWeapon") then
		unit:AddItem(slot, newWeapon)
	elseif IsKindOf(newWeapon, "Grenade") then
		newWeapon.Amount = Min(grenadeQuantity or InteractionRandRange(1, 4, "LDCUAE"), newWeapon.MaxStacks)
		unit:AddItem(slot, newWeapon)
	elseif IsKindOf(newWeapon, "BaseWeapon") then
		AddRandomComponents(newWeapon, adjustedUnitLevel)

		local ammo = generateAmmo(newWeapon.Caliber, adjustedUnitLevel)

		-- load weapon
		unit:TryEquip({ newWeapon }, slot, "BaseWeapon")
		unit:TryLoadAmmo(slot, "BaseWeapon", ammo.id)

		-- add ammo
		local newAmmo = PlaceInventoryItem(ammo.id)
		newAmmo.drop_chance = newAmmo.base_drop_chance // 3
		if IsKindOf(newAmmo, "Ordnance") then
			newAmmo.Amount = Min(InteractionRandRange(1, 10, "LDCUAE"), newAmmo.MaxStacks)
		else
			newAmmo.Amount = Min(InteractionRandRange(50, 100, "LDCUAE"), newAmmo.MaxStacks)
		end
		unit:AddItem("Inventory", newAmmo)
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

local function getItemType(weapon)
	local _type = weapon.ItemType or weapon.WeaponType
	if _type == "GrenadeGas" or _type == "GrenadeFire" or _type == "Throwables" then
		return "Grenade"
	else
		return _type
	end
end

function GenerateNewWeapons(unit, orginalHandheldsA, orginalHandheldsB)
	Debug("C-UAE Adding new weapons", unit.Affiliation)

	local _type1A, _type2A, _type1B, _type2B = nil, nil, nil, nil
	-- Handheld A
	if #orginalHandheldsA == 1 then
		_type1A = getItemType(orginalHandheldsA[1])
		generateWeapon(unit, "Handheld A", AllowAlternativeWeaponType(_type1A), orginalHandheldsA[1].Cost)
	elseif #orginalHandheldsA == 2 then
		_type1A = getItemType(orginalHandheldsA[1])
		_type2A = getItemType(orginalHandheldsA[2])
		generateWeapon(unit, "Handheld A", _type1A, orginalHandheldsA[1].Cost)
		generateWeapon(unit, "Handheld A", _type2A, orginalHandheldsA[2].Cost)
	end
	-- Handheld B
	if #orginalHandheldsB == 1 then
		_type1B = getItemType(orginalHandheldsB[1])
		generateWeapon(unit, "Handheld B", AllowAlternativeWeaponType(_type1B), orginalHandheldsB[1].Cost)
	elseif #orginalHandheldsB == 2 then
		_type1B = getItemType(orginalHandheldsB[1])
		_type2B = getItemType(orginalHandheldsB[2])
		generateWeapon(unit, "Handheld B", _type1B, orginalHandheldsB[1].Cost)
		generateWeapon(unit, "Handheld B", _type2B, orginalHandheldsB[2].Cost)
	elseif LoadedModOptions.ExtraHandgun and LoadedModOptions.ExtraGrenadesCount ~= 0 and _type1A ~= 'Handgun' and _type2A ~= 'Handgun' and _type1A ~= 'Grenade' and _type2A ~= 'Grenade' then
		generateWeapon(unit, "Handheld B", 'Handgun')
		generateWeapon(unit, "Handheld B", 'Grenade', nil, LoadedModOptions.ExtraGrenadesCount)
	elseif LoadedModOptions.ExtraHandgun and _type1A ~= 'Handgun' and _type2A ~= 'Handgun' then
		generateWeapon(unit, "Handheld B", 'Handgun')
	elseif LoadedModOptions.ExtraGrenadesCount ~= 0 and _type1A ~= 'Grenade' and _type2A ~= 'Grenade' then
		generateWeapon(unit, "Handheld B", 'Grenade', nil, LoadedModOptions.ExtraGrenadesCount)
	end
end
