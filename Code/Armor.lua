local function keepOrginalArmor(orginalArmor, slot)
	if orginalArmor then
		Cuae_Debug("- keeping(immunity):", slot, orginalArmor.class, orginalArmor.Cost, "Condition:", orginalArmor.Condition)
	end
end

local function replaceArmorPiece(settings, unit, avgAllyLevel, orginalArmor, mainSlot, slot)
	if not settings.ReplaceArmor or orginalArmor and Cuae_ImmunityTable[orginalArmor.class] then
		keepOrginalArmor(orginalArmor, slot)
		return
	end

	local unitLevel = Min(10, unit:GetLevel())
	local adjustedUnitLevel = Cuae_CalculateAdjustedUnitLevel(settings, unitLevel, avgAllyLevel, Cuae_UnitAffiliation(settings, unit))
	local orginalCost = orginalArmor and orginalArmor.Cost or 0

	if not settings.AlwaysAddArmor and orginalCost == 0 and InteractionRandRange(1, 100, "LDCUAE") >= Cuae_UnitLevelToComponentChance[adjustedUnitLevel] then
		return
	end

	local newArmorPreset = Cuae_GetSuitableArnament(Cuae_UnitAffiliation(settings, unit), adjustedUnitLevel, slot, orginalCost)

	if newArmorPreset == nil then
		Cuae_Debug("- skipping as no siutable armors were found", slot, "for", Cuae_UnitAffiliation(settings, unit))
		if orginalArmor then
			keepOrginalArmor(orginalArmor, slot)
		end
		return
	end

	-- remove orginal armor
	if orginalArmor then
		Cuae_Removeitem(unit, mainSlot, orginalArmor)
	end

	local newCondition = orginalArmor and orginalArmor.Condition or InteractionRandRange(45, 95, "LDCUAE")

	-- get and init final armor from preset
	local newArmor = nil
	newArmor = PlaceInventoryItem(newArmorPreset.id)
	newArmor.drop_chance = newArmor.base_drop_chance
	newArmor.Condition = newCondition

	unit:AddItem(mainSlot, newArmor)
	Cuae_Debug("- picked:", slot, newArmorPreset.id, Cuae_Cost(newArmorPreset), "Condition:", newArmor.Condition)
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

function Cuae_GeneratNewArmor(settings, unit, avgAllyLevel, orginalHead, orginalTorso, orginalLegs)
	Cuae_Debug("C-UAE Adding new armor items", Cuae_UnitAffiliation(settings, unit))

	local forcedHeadSlot, forcedTorsoSlot, forcedLegsSlot = getRandomArmorTypeSet(settings)

	if orginalHead or settings.AlwaysAddArmor then
		replaceArmorPiece(settings, unit, avgAllyLevel, orginalHead, "Head", forcedHeadSlot or Cuae_GetHeadSubType(orginalHead))
	end
	if orginalTorso or settings.AlwaysAddArmor then
		replaceArmorPiece(settings, unit, avgAllyLevel, orginalTorso, "Torso", forcedTorsoSlot or Cuae_GetTorsoSubType(orginalTorso))
	end
	if orginalLegs or settings.AlwaysAddArmor then
		replaceArmorPiece(settings, unit, avgAllyLevel, orginalLegs, "Legs", forcedLegsSlot or Cuae_GetLegsSubType(orginalLegs))
	end
end

