function Cuae_RemoveAmmo(settings, unit)
	Cuae_Debug("C-UAE Removing orginal ammo from", Cuae_UnitAffiliation(settings, unit))
	unit:ForEachItem(function(item, slot_name)
		-- Ordnance is Ammo for heavy weapons
		if slot_name == "Inventory" and (IsKindOf(item, "Ammo") or IsKindOf(item, "Ordnance")) then
			Cuae_Debug("-", "Caliber:", item.Caliber, item.class, "Cost:", item.Cost, "Amount", item.Amount)
			unit:RemoveItem(slot_name, item)
			DoneObject(item)
		end
	end)
end

local AMMO_RARITY = {
	AmmoBasicColor = 0,
	AmmoAPColor = 1,
	AmmoHPColor = 2,
	AmmoMatchColor = 3,
	AmmoTracerColor = 4,
}
local function ammoRarity(preset)
	return preset and preset.colorStyle and AMMO_RARITY[preset.colorStyle] or 100
end

local function getAllAmmunitionOfCaliber(weaponCaliber, affiliation)
	if not Cuae_AllAmmunition[weaponCaliber] then
		Cuae_Debug("C-UAE Building", weaponCaliber, "ammunition table...")
		Cuae_AllAmmunition[weaponCaliber] = GetAmmosWithCaliber(weaponCaliber, "sort")
		for _, a in ipairs(Cuae_AllAmmunition[weaponCaliber]) do
			Cuae_Debug(">>", a.id, "Color:", a.colorStyle, "Rarity", ammoRarity(a))
		end
		Cuae_Debug("C-UAE Building", weaponCaliber, "ammunition table DONE")
	end
	local allAmmunition = Cuae_AllAmmunition[weaponCaliber] or {}
	local exclusionTable = Cuae_AffiliationExclusionTable[affiliation]
	local ammunition = exclusionTable and table.ifilter(allAmmunition, function(_, w)
		return not exclusionTable[w.id]
	end) or allAmmunition
	return ammunition
end

local function generateAmmo(weaponCaliber, affiliation, adjustedUnitLevel)
	local allAmmunitionOfCaliber = getAllAmmunitionOfCaliber(weaponCaliber, affiliation)

	local costRangeFrom, costRangeTo = Cuae_CalculateCostRange(adjustedUnitLevel, 1, 8)

	local minIdx = Min(#allAmmunitionOfCaliber, Max(1, DivRound(#allAmmunitionOfCaliber * costRangeFrom, 100)))
	local maxIdx = Min(#allAmmunitionOfCaliber, Max(1, DivRound(#allAmmunitionOfCaliber * costRangeTo, 100)))

	local minRarity = ammoRarity(allAmmunitionOfCaliber[minIdx])
	local maxRarity = ammoRarity(allAmmunitionOfCaliber[maxIdx])
	local suitableAmmos = table.ifilter(allAmmunitionOfCaliber, function(i, a)
		return ammoRarity(a) >= minRarity and ammoRarity(a) <= maxRarity
	end)

	local ammo = suitableAmmos[InteractionRandRange(1, #suitableAmmos, "LDCUAE")]
	Cuae_Debug("-- picked suitable ammo:", weaponCaliber, ammo.id, "Color:", ammo.colorStyle, "Rarity", ammoRarity(ammo))
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
	return newAmmo
end

function Cuae_GenerateNewAmmo(settings, unit, adjustedUnitLevel, weapon, slot)
	local ammo = generateAmmo(weapon.Caliber, Cuae_UnitAffiliation(settings, unit), adjustedUnitLevel)
	unit:TryLoadAmmo(slot, "BaseWeapon", ammo.id)
	addAmmo(unit, ammo, weapon.MagazineSize)
	for _, subWeapon in pairs(weapon.subweapons) do
		if IsKindOf(subWeapon, "Firearm") then
			local subAmmo = generateAmmo(subWeapon.Caliber, Cuae_UnitAffiliation(settings, unit), adjustedUnitLevel)
			local inventorySubAmmo = addAmmo(unit, subAmmo, subWeapon.MagazineSize)
			subWeapon:Reload(inventorySubAmmo, "suspend_fx")
		end
	end
end
