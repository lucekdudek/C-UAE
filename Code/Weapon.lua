local function tryAddComponentsAndAmmo(settings, unit, adjustedUnitLevel, replacementPolicy, policySettings)
	if replacementPolicy.ogInstance and replacementPolicy.isWeapon and not replacementPolicy.ogType == "MeleeWeapon" then
		replacementPolicy.ogInstance.ammo = nil
		Cuae_AddRandomComponents(settings, replacementPolicy.ogInstance, adjustedUnitLevel, policySettings.weaponComponentsCurve, replacementPolicy.weaponComponentsPriority)
		Cuae_GenerateNewAmmo(settings, unit, adjustedUnitLevel, replacementPolicy.ogInstance, replacementPolicy.slot, policySettings.excludeAmmoRarity)
	end
end

local handheldTypes = {
	Utility = "Utility",
	Weapon = "Weapon",
	-- weapons with allowed dual wielding
	Handgun = "Handgun",
	SMG = "SMG",
}
local function canAddItemIn(unit, item, itemHandheldType, slot)
	if not unit:CanAddItem(slot, item) then
		return false
	elseif itemHandheldType == handheldTypes.Utility then
		return true
	elseif itemHandheldType == handheldTypes.Handgun and (unit:GetItemInSlot(slot, "Pistol") or unit:GetItemInSlot(slot, "Revolver")) then
		return true
	elseif itemHandheldType == handheldTypes.SMG and unit:GetItemInSlot(slot, "SubmachineGun") then
		return true
	elseif unit:GetItemInSlot(slot, "Firearm") or unit:GetItemInSlot(slot, "MeleeWeapon") then
		return false
	else
		return true
	end
end

local function addItemInFirstSlot(unit, item, itemHandheldType)
	local slot = nil
	local itemAdded, _ = false, nil
	if canAddItemIn(unit, item, itemHandheldType, "Handheld A") then
		slot = "Handheld A"
	elseif canAddItemIn(unit, item, itemHandheldType, "Handheld B") then
		slot = "Handheld B"
	end
	if slot then
		itemAdded, _ = unit:AddItem(slot, item)
	end
	return itemAdded, slot
end

local function placeArmament(settings, unit, adjustedUnitLevel, policy, policySettings)
	local itemAdded, slot = false, nil

	local newCondition = policy.ogCondition or InteractionRandRange(45, 95, "LDCUAE")
	local useOriginalCost = policy.newType == policy.ogType

	local newArmamentPreset = nil
	if policy.useDefault then
		newArmamentPreset = Cuae_GetDefaultArmament(Cuae_UnitAffiliation(settings, unit), policy.newType, policy.newSize)
	else
		newArmamentPreset = Cuae_GetSuitableArmament(Cuae_UnitAffiliation(settings, unit), adjustedUnitLevel, policy.newType, policy.ogCost, useOriginalCost, policy.newSize)
	end
	if newArmamentPreset == nil then
		return false
	end

	-- get and init final armament from preset
	local dropChance = policy.ogDropChance or g_Classes[newArmamentPreset.id].base_drop_chance
	local newArmament = PlaceInventoryItem(newArmamentPreset.id)
	Cuae_L("D", "  picked:", policy.newType, newArmamentPreset.id, "Condition:", newCondition, "Drop Chance:", dropChance)

	if IsKindOf(newArmament, "MeleeWeapon") then
		newArmament.drop_chance = dropChance
		newArmament.Condition = newCondition
		-- TODO handle newArmamentPreset.CanThrow
		itemAdded, slot = addItemInFirstSlot(unit, newArmament, handheldTypes.Weapon)
	elseif not policy.isWeapon then
		newArmament.Amount = policy.amount
		newArmament.drop_chance = dropChance
		itemAdded, slot = addItemInFirstSlot(unit, newArmament, handheldTypes.Utility)
	elseif IsKindOf(newArmament, "BaseWeapon") then
		newArmament.drop_chance = dropChance
		newArmament.Condition = newCondition
		Cuae_AddRandomComponents(settings, newArmament, adjustedUnitLevel, policySettings.weaponComponentsCurve, policy.weaponComponentsPriority)
		itemAdded, slot = addItemInFirstSlot(unit, newArmament, policy.newType == "Handgun" and handheldTypes.Handgun or policy.newType == "SMG" and handheldTypes.SMG or handheldTypes.Weapon)
		-- load weapon
		if itemAdded then
			Cuae_GenerateNewAmmo(settings, unit, adjustedUnitLevel, newArmament, slot, policySettings.excludeAmmoRarity)
		end
	end

	if not itemAdded then
		DoneObject(newArmament)
	end

	return not not itemAdded
end

local function canBeReplaced(affiliation, adjustedUnitLevel, policy)
	return policy.newType ~= policy.ogType or #Cuae_GetSuitableArmaments(affiliation, adjustedUnitLevel, policy.newType, policy.ogCost, policy.newType == policy.ogType) > 0
end

function Cuae_ApplyChangePolicy(settings, unit, avgLevel, changePolicy)
	local affiliation = Cuae_UnitAffiliation(settings, unit)
	local level = Min(10, unit:GetLevel())
	local adjLevel = Cuae_CalculateAdjustedUnitLevel(settings, level, avgLevel, affiliation)
	Cuae_L("D", "Applying change policy")
	-- 1. Remove all that can be removed
	local replacementsToPlace = {}
	for _, replacementPolicy in ipairs(changePolicy.replacements) do
		if replacementPolicy.keep then
			Cuae_L("D", " Keeping", replacementPolicy.ogPresetId)
			tryAddComponentsAndAmmo(settings, unit, adjLevel, replacementPolicy, changePolicy)
		elseif replacementPolicy.discard then
			Cuae_L("D", " Discarding", replacementPolicy.ogPresetId)
			Cuae_RemoveItem(unit, replacementPolicy.slot, replacementPolicy.ogInstance)
		elseif canBeReplaced(affiliation, adjLevel, replacementPolicy) then
			Cuae_L("D", " Removing for replacement", replacementPolicy.ogPresetId)
			Cuae_RemoveItem(unit, replacementPolicy.slot, replacementPolicy.ogInstance)
			table.insert(replacementsToPlace, replacementPolicy)
		else
			Cuae_L("D", " Keeping due to no suitable replacement", replacementPolicy.ogPresetId)
			tryAddComponentsAndAmmo(settings, unit, adjLevel, replacementPolicy, changePolicy)
		end
	end
	-- 2. Place replacement items
	local itemAdded = nil
	for _, replacementPolicy in ipairs(replacementsToPlace) do
		Cuae_L("D", " Placing replacement for", replacementPolicy.ogPresetId)
		itemAdded = placeArmament(settings, unit, adjLevel, replacementPolicy, changePolicy)
		if not itemAdded then
			Cuae_L("E", "  Placing replacement for", replacementPolicy.ogPresetId, "failed, og item is now gone")
		end
	end
	-- 3. Place extra items
	for _, extraWeaponPolicy in ipairs(changePolicy.extraWeapons) do
		Cuae_L("D", " Placing extra weapon", extraWeaponPolicy.newType)
		itemAdded = placeArmament(settings, unit, adjLevel, extraWeaponPolicy, changePolicy)
		if not itemAdded then
			Cuae_L("D", "  unable to place extra", extraWeaponPolicy.newType, "due to no space left")
		end
	end
	for _, extraUtilityPolicy in ipairs(changePolicy.extraUtility) do
		Cuae_L("D", " Placing extra utility", extraUtilityPolicy.newType)
		itemAdded = placeArmament(settings, unit, adjLevel, extraUtilityPolicy, changePolicy)
		if not itemAdded then
			Cuae_L("D", "  unable to place extra", extraUtilityPolicy.newType, "due to no space left")
			return
		end
	end
end
