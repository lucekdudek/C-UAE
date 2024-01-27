local function generateWeapon(unit, slot, _type, orginalCost, grenadeQuantity)
	local unitLevel = Min(10, unit:GetLevel())
	local adjustedUnitLevel = CalculateAdjustedUnitLevel(unitLevel, unit.Affiliation)

	if _type == "Grenade" and orginalCost == 0 and InteractionRand(100, "LDCUAE") > LoadedModOptions.ExtraGrenadesChance then
		return
	end

	local suitableWeapons = GetSuitableArnaments(adjustedUnitLevel, _type, orginalCost)

	-- -- print(">>suitableWeapons")
	-- for i, w in ipairs(suitableWeapons) do
	-- 	-- print(">>>>", w.id, w.Cost)
	-- end

	-- get and init final weapon from preset
	local weaponPreset = suitableWeapons[InteractionRandRange(1, #suitableWeapons, "LDCUAE")]
	local newWeapon = PlaceInventoryItem(weaponPreset.id)
	newWeapon.drop_chance = IsKindOf(newWeapon, "Grenade") and 5 or newWeapon.base_drop_chance
	-- print("ADD WEAPON", unit.Affiliation, "LVL:", unitLevel, _type, "Cost", suitableWeapons[1].Cost, "-", suitableWeapons[#suitableWeapons].Cost, weaponPreset.id, weaponPreset.Cost)

	if IsKindOf(newWeapon, "MeleeWeapon") then
		unit:AddItem(slot, newWeapon)
	elseif IsKindOf(newWeapon, "Grenade") then
		newWeapon.Amount = Min(grenadeQuantity or InteractionRandRange(1, 4, "LDCUAE"), newWeapon.MaxStacks)
		unit:AddItem(slot, newWeapon)
	elseif IsKindOf(newWeapon, "BaseWeapon") then
		AddRandomComponents(newWeapon, adjustedUnitLevel)

		-- create ammo
		local ammos = GetAmmosWithCaliber(newWeapon.Caliber, "sort")
		local unitLevelTier = UnitLevelToLvlTier[unitLevel]
		local newAmmoTier = RollNewTier(Max(1, unitLevelTier - 1), unitLevelTier)
		-- exclude
		local suitableAmmos = table.ifilter(ammos, function(i, a)
			return (a.Tier or 1) == newAmmoTier and not table.find(ExcludeAmmos, a.id)
		end)
		-- Use all Tiers if no matches were found
		if #suitableAmmos == 0 then
			suitableAmmos = table.ifilter(ammos, function(i, a)
				return not table.find(ExcludeAmmos, a.id)
			end)
		end
		local ammo = suitableAmmos[InteractionRandRange(1, #suitableAmmos, "LDCUAE")]

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
		-- print("--ADD AMMO", unit.Affiliation, "LVL:", unitLevel, newWeapon.Caliber, "Tier", newAmmoTier, ammo.id)
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
