local function keepOrginalArmor(orginalArmor, slot)
	if orginalArmor then
		Cuae_Debug("- keeping(immunity):", slot, orginalArmor.class, orginalArmor.Cost, "Condition:",
			orginalArmor.Condition)
	end
end

local function replaceArmorPiece(unit, avgAllyLevel, orginalArmor, slot)
	if not Cuae_LoadedModOptions.ReplaceArmor or orginalArmor and Cuae_ImmunityTable[orginalArmor.class] then
		keepOrginalArmor(orginalArmor, slot)
		return
	end

	local unitLevel = Min(10, unit:GetLevel())
	local adjustedUnitLevel = Cuae_CalculateAdjustedUnitLevel(unitLevel, avgAllyLevel, unit.Affiliation)
	local orginalCost = orginalArmor and orginalArmor.Cost or 0

	if orginalCost == 0 and InteractionRandRange(1, 100, "LDCUAE") >= Cuae_UnitLevelToComponentChance[adjustedUnitLevel] then
		return
	end

	local suitableArmors = Cuae_GetSuitableArnaments(unit.Affiliation, adjustedUnitLevel, slot, orginalCost)

	if #suitableArmors == 0 then
		Cuae_Debug("- skipping as no siutable armors were found", slot, "for", unit.Affiliation)
		if orginalArmor then
			keepOrginalArmor(orginalArmor, slot)
		end
		return
	end

	-- remove orginal armor
	if orginalArmor then
		Cuae_Removeitem(unit, slot, orginalArmor)
	end

	local newCondition = orginalArmor and orginalArmor.Condition or InteractionRandRange(45, 95, "LDCUAE")

	-- get and init final armor from preset
	local armorPreset = suitableArmors[InteractionRandRange(1, #suitableArmors, "LDCUAE")]
	local newArmor = nil
	newArmor = PlaceInventoryItem(armorPreset.id)
	newArmor.drop_chance = newArmor.base_drop_chance
	newArmor.Condition = newCondition

	unit:AddItem(slot, newArmor)
	Cuae_Debug("- picked:", slot, armorPreset.id, armorPreset.Cost, "Condition:", newArmor.Condition)
end

function Cuae_GeneratNewArmor(unit, avgAllyLevel, orginalHead, orginalTorso, orginalLegs)
	Cuae_Debug("C-UAE Adding new armor items", unit.Affiliation)
	replaceArmorPiece(unit, avgAllyLevel, orginalHead, "Head")
	replaceArmorPiece(unit, avgAllyLevel, orginalTorso, "Torso")
	replaceArmorPiece(unit, avgAllyLevel, orginalLegs, "Legs")
end
