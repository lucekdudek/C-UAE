local function tryAddComponentsAndAmmo(settings, unit, adjustedUnitLevel, orginalWeapon, slot)
	if orginalWeapon and not IsKindOf(orginalWeapon, "MeleeWeapon") and not IsKindOf(orginalWeapon, "Grenade") and IsKindOf(orginalWeapon, "BaseWeapon") then
		orginalWeapon.ammo = nil
		Cuae_AddRandomComponents(settings, orginalWeapon, adjustedUnitLevel)
		Cuae_GenerateNewAmmo(settings, unit, adjustedUnitLevel, orginalWeapon, slot)
	end
end

local function replaceWeapon(settings, unit, adjustedUnitLevel, orginalWeapon, slot, _type, useOrginalCost, maxSize)
	local itemAdded, _ = false, nil

	local newCondition = orginalWeapon and orginalWeapon.Condition or InteractionRandRange(45, 95, "LDCUAE")

	local newWeaponPreset = nil
	if settings.ReplaceWeapons or table.find(Cuae_GrenadeTypes, _type) then
		newWeaponPreset = Cuae_GetSuitableArnament(Cuae_UnitAffiliation(settings, unit), adjustedUnitLevel, _type, orginalWeapon and orginalWeapon.Cost, useOrginalCost, maxSize)
	else
		newWeaponPreset = Cuae_GetDefaultArnament(Cuae_UnitAffiliation(settings, unit), _type, maxSize)
	end
	if newWeaponPreset == nil then
		return false, 0, false
	end

	-- get and init final weapon from preset
	local dropChance = g_Classes[newWeaponPreset.id].base_drop_chance
	local newWeapon = PlaceInventoryItem(newWeaponPreset.id)
	Cuae_Debug("- picked:", _type, newWeaponPreset.id, Cuae_Cost(newWeaponPreset), "Condition:", newCondition, "Drop Chnace:", dropChance)

	if IsKindOf(newWeapon, "MeleeWeapon") then
		newWeapon.drop_chance = dropChance
		newWeapon.Condition = newCondition
		-- TODO handle weaponPreset.CanThrow
		itemAdded, _ = unit:AddItem(slot, newWeapon)
	elseif IsKindOf(newWeapon, "Grenade") then
		newWeapon.Amount = Min(Max(settings.ExtraGrenadesCount, InteractionRandRange(1, 4, "LDCUAE")), newWeapon.MaxStacks)
		itemAdded, _ = unit:AddItem(slot, newWeapon)
		-- separated stack of grenades that can be dropped (so the enemy can have a stack of 10 to throw but won't drop that big of a stick to the player)
		if settings.DropGrenades then
			local greadnesToDrop = PlaceInventoryItem(newWeaponPreset.id)
			greadnesToDrop.Amount = Min(InteractionRandRange(1, 3, "LDCUAE"), newWeapon.MaxStacks)
			greadnesToDrop.drop_chance = dropChance
			unit:AddItem("Inventory", greadnesToDrop)
		end
	elseif IsKindOf(newWeapon, "BaseWeapon") then
		newWeapon.drop_chance = dropChance
		newWeapon.Condition = newCondition
		Cuae_AddRandomComponents(settings, newWeapon, adjustedUnitLevel)
		-- load weapon
		itemAdded = unit:TryEquip({
			newWeapon,
		}, slot, "BaseWeapon")
		Cuae_GenerateNewAmmo(settings, unit, adjustedUnitLevel, newWeapon, slot)
	end
	return not not itemAdded, newWeapon:GetUIWidth(), newWeapon:IsWeapon()
end

local function allowAlternativeWeaponType(settings, _type)
	if settings.AlternativeWeaponTypeTables then
		local typeAlternativeWeaponTable = settings.AlternativeWeaponTypeTables[_type] or {}
		local rand = InteractionRandRange(1, 100, "LDCUAE")
		for _, tuple in ipairs(typeAlternativeWeaponTable) do
			if rand <= tuple[2] then
				local newType = tuple[1]
				return newType, newType ~= _type
			end
		end
	end
	return _type, false
end

local function getWeaponType(weapon)
	local _type = weapon.ItemType or weapon.WeaponType
	if _type == "Grenade" or _type == "GrenadeGas" or _type == "GrenadeFire" or _type == "Throwables" then
		return "Grenade"
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

local function canBeReplaced(settings, unit, adjustedUnitLevel, item, _type, typeChanged)
	local suitableReplacements, _ = Cuae_GetSuitableArnaments(Cuae_UnitAffiliation(settings, unit), adjustedUnitLevel, _type, item and item.Cost, not typeChanged)
	return not Cuae_ImmunityTable[item.class] and ((settings.ReplaceWeapons and #suitableReplacements > 0) or typeChanged)
end

local function isEmptyKeepOrRemove(settings, unit, adjustedUnitLevel, handheld, orginalHandhelds, T1, T1Type, T1TypeChanged, T2, T2Type)
	local T1IsEmpty, T1IsWeapon, T2IsEmpty, T2IsWeapon = nil, nil, nil, nil
	if not orginalHandhelds[T2] then
		T2IsEmpty = true
		T2IsWeapon = false
	elseif canBeReplaced(settings, unit, adjustedUnitLevel, orginalHandhelds[T2], T2Type, T1TypeChanged) then
		Cuae_Removeitem(unit, handheld, orginalHandhelds[T2])
		T2IsEmpty = true
		T2IsWeapon = false
	else
		tryAddComponentsAndAmmo(settings, unit, adjustedUnitLevel, orginalHandhelds[T2], handheld)
		T2IsEmpty = false
		T2IsWeapon = orginalHandhelds[T2]:IsWeapon()
		-- keep T1 as T2 cannot be removed
		tryAddComponentsAndAmmo(settings, unit, adjustedUnitLevel, orginalHandhelds[T1], handheld)
		T1IsEmpty = false
		T1IsWeapon = orginalHandhelds[T1] and orginalHandhelds[T1]:IsWeapon()
	end
	if T1IsEmpty == nil then
		if not orginalHandhelds[T1] then
			T1IsEmpty = true
			T1IsWeapon = false
		elseif canBeReplaced(settings, unit, adjustedUnitLevel, orginalHandhelds[T1], T1Type, T1TypeChanged) then
			Cuae_Removeitem(unit, handheld, orginalHandhelds[T1])
			T1IsEmpty = true
			T1IsWeapon = false
		else
			tryAddComponentsAndAmmo(settings, unit, adjustedUnitLevel, orginalHandhelds[T1], handheld)
			T1IsEmpty = false
			T1IsWeapon = orginalHandhelds[T1]:IsWeapon()
			if orginalHandhelds[T1]:GetUIWidth() > 1 then
				T2IsEmpty = T1IsEmpty
				T2IsWeapon = T1IsWeapon
			end
		end
	end
	return T1IsEmpty, T1IsWeapon, T2IsEmpty, T2IsWeapon
end

function Cuae_GenerateNewWeapons(settings, unit, avgLevel, orginalHandhelds)
	local itemAdded, _ = false, nil
	local itemSize = {}
	local isWeapon = {}
	local A1IsEmpty, A2IsEmpty, B1IsEmpty, B2IsEmpty = nil, nil, nil, nil
	local _type1A, _type1AChanged = nil, false
	if orginalHandhelds.A1 then
		_type1A, _type1AChanged = allowAlternativeWeaponType(settings, getWeaponType(orginalHandhelds.A1))
	end
	local _type2A = orginalHandhelds.A2 and getWeaponType(orginalHandhelds.A2) or nil
	local _type1B = orginalHandhelds.B1 and getWeaponType(orginalHandhelds.B1) or nil
	local _type2B = orginalHandhelds.B2 and getWeaponType(orginalHandhelds.B2) or nil
	local level = Min(10, unit:GetLevel())
	local adjLevel = Cuae_CalculateAdjustedUnitLevel(settings, level, avgLevel, Cuae_UnitAffiliation(settings, unit))
	Cuae_Debug("C-UAE Adding new weapons", Cuae_UnitAffiliation(settings, unit), adjLevel)
	-- unequpe | keep immunes
	A1IsEmpty, isWeapon.A1, A2IsEmpty, isWeapon.A2 = isEmptyKeepOrRemove(settings, unit, adjLevel, "Handheld A", orginalHandhelds, "A1", _type1A, _type1AChanged, "A2", _type2A)
	B1IsEmpty, isWeapon.B1, B2IsEmpty, isWeapon.B1 = isEmptyKeepOrRemove(settings, unit, adjLevel, "Handheld B", orginalHandhelds, "B1", _type1B, false, "B2", _type2B)
	-- spawn HandA1 -> HandB1 -> HandA2 -> HandB2 -> Extra Handgun -> Extra Grenade
	Cuae_Debug("- [1/6] orginal A1 (type/isEmpty)", "A:", _type1A, A1IsEmpty, _type2A, A2IsEmpty, "B:", _type1B, B1IsEmpty, _type2B, B2IsEmpty)
	if orginalHandhelds.A1 and A1IsEmpty then
		itemAdded, itemSize.A1, isWeapon.A1 = replaceWeapon(settings, unit, adjLevel, orginalHandhelds.A1, "Handheld A", _type1A, not _type1AChanged, 2)
		A1IsEmpty = not itemAdded
		if itemSize.A1 > 1 then
			A2IsEmpty = false
			isWeapon.A2 = isWeapon.A1
		end
	end
	Cuae_Debug("- [2/6] orginal B1 (type/isEmpty)", "A:", _type1A, A1IsEmpty, _type2A, A2IsEmpty, "B:", _type1B, B1IsEmpty, _type2B, B2IsEmpty)
	if orginalHandhelds.B1 and B1IsEmpty then
		itemAdded, itemSize.B1, isWeapon.B1 = replaceWeapon(settings, unit, adjLevel, orginalHandhelds.B1, "Handheld B", _type1B, true, 2)
		B1IsEmpty = not itemAdded
		if itemSize.B1 > 1 then
			B2IsEmpty = false
			isWeapon.B2 = isWeapon.B1
		end
	end
	Cuae_Debug("- [3/6] orginal A2 (type/isEmpty)", "A:", _type1A, A1IsEmpty, _type2A, A2IsEmpty, "B:", _type1B, B1IsEmpty, _type2B, B2IsEmpty)
	if orginalHandhelds.A2 then
		if A2IsEmpty then
			itemAdded, _, isWeapon.A2 = replaceWeapon(settings, unit, adjLevel, orginalHandhelds.A2, "Handheld A", _type2A, true, 1)
			A2IsEmpty = not itemAdded
		elseif B1IsEmpty then
			itemAdded, itemSize.B1, isWeapon.B1 = replaceWeapon(settings, unit, adjLevel, orginalHandhelds.A2, "Handheld B", _type2A, true, 2)
			B1IsEmpty = not itemAdded
			if itemSize.B1 > 1 then
				B2IsEmpty = false
				isWeapon.B2 = isWeapon.B1
			end
		elseif B2IsEmpty then
			itemAdded, _, isWeapon.B2 = replaceWeapon(settings, unit, adjLevel, orginalHandhelds.A2, "Handheld B", _type2A, true, 1)
			B2IsEmpty = not itemAdded
		end
	end
	Cuae_Debug("- [4/6] orginal B2 (type/isEmpty)", "A:", _type1A, A1IsEmpty, _type2A, A2IsEmpty, "B:", _type1B, B1IsEmpty, _type2B, B2IsEmpty)
	if orginalHandhelds.B2 then
		if B2IsEmpty then
			itemAdded, _, isWeapon.B2 = replaceWeapon(settings, unit, adjLevel, orginalHandhelds.B2, "Handheld B", _type2B, true, 1)
			B2IsEmpty = not itemAdded
		elseif A2IsEmpty then
			itemAdded, _, isWeapon.A2 = replaceWeapon(settings, unit, adjLevel, orginalHandhelds.B2, "Handheld A", _type2B, true, 1)
			A2IsEmpty = not itemAdded
		end
	end
	-- extra Handgun|Melee|Smoke
	local extraType, extraIsWeapon = nil, true
	if table.find(Cuae_CQBTypes, _type1A) or table.find(Cuae_CQBTypes, _type2A) then
		extraType = settings.UseRandomGrenadeAsCqb and "Grenade" or "GrenadeSmoke"
		extraIsWeapon = false
	elseif InteractionRandRange(1, 100, "LDCUAE") <= 50 then
		extraType = "Handgun"
	else
		extraType = "MeleeWeapon"
	end
	Cuae_Debug("- [5/6] extra", extraType, "(type/isEmpty)", "A:", _type1A, A1IsEmpty, _type2A, A2IsEmpty, "B:", _type1B, B1IsEmpty, _type2B, B2IsEmpty)
	if settings.ExtraHandgun and _type1A ~= extraType and _type2A ~= extraType and _type1B ~= extraType and _type2B ~= extraType then
		local willFitInA = (not isWeapon.A1 and not isWeapon.A2) or not extraIsWeapon
		local willFitInB = (not isWeapon.B1 and not isWeapon.B2) or not extraIsWeapon
		if willFitInA and A1IsEmpty then
			itemAdded, _, isWeapon.A1 = replaceWeapon(settings, unit, adjLevel, nil, "Handheld A", extraType, false, 1)
			A1IsEmpty = not itemAdded
		elseif willFitInA and A2IsEmpty then
			itemAdded, _, isWeapon.A2 = replaceWeapon(settings, unit, adjLevel, nil, "Handheld A", extraType, false, 1)
			A2IsEmpty = not itemAdded
		elseif willFitInB and B1IsEmpty then
			itemAdded, _, isWeapon.B1 = replaceWeapon(settings, unit, adjLevel, nil, "Handheld B", extraType, false, 1)
			B1IsEmpty = not itemAdded
		elseif willFitInB and B2IsEmpty then
			itemAdded, _, isWeapon.B2 = replaceWeapon(settings, unit, adjLevel, nil, "Handheld B", extraType, false, 1)
			B2IsEmpty = not itemAdded
		end
	end
	-- extra Grenades
	Cuae_Debug("- [6/6] extra Grenades (type/isEmpty)", "A:", _type1A, A1IsEmpty, _type2A, A2IsEmpty, "B:", _type1B, B1IsEmpty, _type2B, B2IsEmpty)
	if InteractionRandRange(1, 100, "LDCUAE") <= settings.ExtraGrenadesChance and settings.ExtraGrenadesCount ~= 0 and _type1A ~= "Grenade" and _type2A ~= "Grenade" and _type1B
					~= "Grenade" and _type2B ~= "Grenade" then
		local handheld = nil
		if A1IsEmpty or A2IsEmpty then
			handheld = "Handheld A"
		elseif B1IsEmpty or B2IsEmpty then
			handheld = "Handheld B"
		end
		if handheld then
			replaceWeapon(settings, unit, adjLevel, nil, handheld, settings.ExtraHandgun and extraType == "GrenadeSmoke" and "GrenadeHe" or "Grenade", false, 1)
		end
	end
end
