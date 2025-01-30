local function keepOriginalArmor(originalArmor, slot)
	if originalArmor then
		Cuae_L("D", " keeping:", slot, originalArmor.class, originalArmor.Cost, "Condition:", originalArmor.Condition)
	end
end

local function replaceArmorPiece(settings, unit, avgAllyLevel, originalArmor, mainSlot, slot)
	if not settings.ReplaceArmor or originalArmor and Cuae_ImmunityTable[originalArmor.class] then
		keepOriginalArmor(originalArmor, slot)
		return
	end

	local unitLevel = Min(10, unit:GetLevel())
	local adjustedUnitLevel = Cuae_CalculateAdjustedUnitLevel(settings, unitLevel, avgAllyLevel, Cuae_UnitAffiliation(settings, unit))
	local originalCost = originalArmor and originalArmor.Cost or 0

	if not settings.AlwaysAddArmor and originalCost == 0 and InteractionRandRange(1, 100, "LDCUAE") >= Cuae_UnitLevelToComponentChance[adjustedUnitLevel] then
		return
	end

	local newArmorPreset = Cuae_GetSuitableArmament(Cuae_UnitAffiliation(settings, unit), adjustedUnitLevel, slot, originalCost)

	if newArmorPreset == nil then
		Cuae_L("D", " skipping as no suitable armors were found", slot, "for", Cuae_UnitAffiliation(settings, unit))
		if originalArmor then
			keepOriginalArmor(originalArmor, slot)
		end
		return
	end

	-- remove original armor
	if originalArmor then
		Cuae_RemoveItem(unit, mainSlot, originalArmor)
	end

	local newCondition = originalArmor and originalArmor.Condition or InteractionRandRange(45, 95, "LDCUAE")

	-- get and init final armor from preset
	local newArmor = nil
	newArmor = PlaceInventoryItem(newArmorPreset.id)
	newArmor.drop_chance = newArmor.base_drop_chance
	newArmor.Condition = newCondition

	unit:AddItem(mainSlot, newArmor)
	Cuae_L("D", " picked:", slot, newArmorPreset.id, Cuae_Cost(newArmorPreset), "Condition:", newArmor.Condition)
end

local typesHelpTable = {
	LV = {"LHead","LVest","LLegs"},
	LP = {"LHead","LPlate","LLegs"},
	MV = {"MHead","MVest","MLegs"},
	MP = {"MHead","MPlate","MLegs"},
	HV = {"HHead","HVest","HLegs"},
	HP = {"HHead","HPlate","HLegs"},
}

local function getRandomArmorTypeSet(settings)
	local types = {"LV", "LP", "LP", "MV", "MP","MV", "MP", "HV", "HP"}
	local t = types[InteractionRandRange(1, #types, "CombatTasks")]
	if settings.AlwaysAddArmor then
		return typesHelpTable[t][1], typesHelpTable[t][2], typesHelpTable[t][3]
	else
		return nil, nil, nil
	end
end

function Cuae_GenerateNewArmor(settings, unit, avgAllyLevel, originalHead, originalTorso, originalLegs)
	Cuae_L("D", "Adding new armor items for", Cuae_UnitAffiliation(settings, unit), "lvl", avgAllyLevel)

	local forcedHeadSlot, forcedTorsoSlot, forcedLegsSlot = getRandomArmorTypeSet(settings)

	if originalHead or settings.AlwaysAddArmor then
		replaceArmorPiece(settings, unit, avgAllyLevel, originalHead, "Head", forcedHeadSlot or Cuae_GetHeadSubType(originalHead))
	end
	if originalTorso or settings.AlwaysAddArmor then
		replaceArmorPiece(settings, unit, avgAllyLevel, originalTorso, "Torso", forcedTorsoSlot or Cuae_GetTorsoSubType(originalTorso))
	end
	if originalLegs or settings.AlwaysAddArmor then
		replaceArmorPiece(settings, unit, avgAllyLevel, originalLegs, "Legs", forcedLegsSlot or Cuae_GetLegsSubType(originalLegs))
	end
end

