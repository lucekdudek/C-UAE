local function GeneratArmorInSlot(unit, slot, orginalCost)
	local unitLevel = Min(10, unit:GetLevel())
	local adjustedUnitLevel = CalculateAdjustedUnitLevel(unitLevel, unit.Affiliation)

	if orginalCost == 0 and InteractionRand(100, "LDCUAE") >= UnitLevelToComponentChance[adjustedUnitLevel] then
		return
	end

	local suitableArmors = GetSuitableArnaments(adjustedUnitLevel, slot, orginalCost)

	-- get and init final armor from preset
	local armorPreset = suitableArmors[InteractionRandRange(1, #suitableArmors, "LDCUAE")]
	local newArmor = nil
	newArmor = PlaceInventoryItem(armorPreset.id)
	newArmor.drop_chance = newArmor.base_drop_chance

	unit:AddItem(slot, newArmor)
	Debug(">> picked", slot, armorPreset.id, armorPreset.Cost)
end

function GeneratNewArmor(unit, orginalHead, orginalTorso, orginalLegs)
	Debug("C-UAE Adding new armor items", unit.Affiliation)
	GeneratArmorInSlot(unit, "Head", orginalHead and orginalHead.Cost or 0)
	GeneratArmorInSlot(unit, "Torso", orginalTorso and orginalTorso.Cost or 0)
	GeneratArmorInSlot(unit, "Legs", orginalLegs and orginalLegs.Cost or 0)
end
