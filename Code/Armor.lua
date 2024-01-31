local function keepOrginalArmor(orginalArmor, slot)
	Debug("- keeping(immunity):", slot, orginalArmor.class, orginalArmor.Cost, "Condition:", orginalArmor.Condition)
end

local function replaceArmorPiece(unit, orginalArmor, slot)
	if orginalArmor and ImmunityTable[orginalArmor.class] then
		keepOrginalArmor(orginalArmor, slot)
		return
	end

	local unitLevel = Min(10, unit:GetLevel())
	local adjustedUnitLevel = CalculateAdjustedUnitLevel(unitLevel, unit.Affiliation)
	local orginalCost = orginalArmor and orginalArmor.Cost or 0

	if orginalCost == 0 and InteractionRand(100, "LDCUAE") >= UnitLevelToComponentChance[adjustedUnitLevel] then
		return
	end

	local suitableArmors = GetSuitableArnaments(unit.Affiliation, adjustedUnitLevel, slot, orginalCost)

	if #suitableArmors == 0 then
		Debug("- skipping as no siutable armors were found", slot, "for", unit.Affiliation)
		if orginalArmor then
			keepOrginalArmor(orginalArmor, slot)
		end
		return
	end

	-- remove orginal armor
	if orginalArmor then
		Removeitem(unit, slot, orginalArmor)
	end

	local newCondition = orginalArmor and orginalArmor.Condition or InteractionRandRange(45, 95, "LDCUAE")

	-- get and init final armor from preset
	local armorPreset = suitableArmors[InteractionRandRange(1, #suitableArmors, "LDCUAE")]
	local newArmor = nil
	newArmor = PlaceInventoryItem(armorPreset.id)
	newArmor.drop_chance = newArmor.base_drop_chance
	newArmor.Condition = newCondition

	unit:AddItem(slot, newArmor)
	Debug("- picked:", slot, armorPreset.id, armorPreset.Cost, "Condition:", newArmor.Condition)
end

function GeneratNewArmor(unit, orginalHead, orginalTorso, orginalLegs)
	Debug("C-UAE Adding new armor items", unit.Affiliation)
	replaceArmorPiece(unit, orginalHead, "Head")
	replaceArmorPiece(unit, orginalTorso, "Torso")
	replaceArmorPiece(unit, orginalLegs, "Legs")
end
