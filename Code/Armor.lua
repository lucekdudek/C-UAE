local function keepOrginalArmor(orginalArmor, slot)
	if orginalArmor then
		Cuae_Debug("- keeping(immunity):", slot, orginalArmor.class, orginalArmor.Cost, "Condition:", orginalArmor.Condition)
	end
end

local function replaceArmorPiece(unit, avgAllyLevel, orginalArmor, mainSlot, slot)
	if not Cuae_LoadedModOptions.ReplaceArmor or orginalArmor and Cuae_ImmunityTable[orginalArmor.class] then
		keepOrginalArmor(orginalArmor, slot)
		return
	end

	local unitLevel = Min(10, unit:GetLevel())
	local adjustedUnitLevel = Cuae_CalculateAdjustedUnitLevel(unitLevel, avgAllyLevel, Cuae_UnitAffiliation(unit))
	local orginalCost = orginalArmor and orginalArmor.Cost or 0

	if orginalCost == 0 and InteractionRandRange(1, 100, "LDCUAE") >= Cuae_UnitLevelToComponentChance[adjustedUnitLevel] then
		return
	end

	local newArmorPreset = Cuae_GetSuitableArnament(Cuae_UnitAffiliation(unit), adjustedUnitLevel, slot, orginalCost)

	if newArmorPreset == nil then
		Cuae_Debug("- skipping as no siutable armors were found", slot, "for", Cuae_UnitAffiliation(unit))
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


function Cuae_GeneratNewArmor(unit, avgAllyLevel, orginalHead, orginalTorso, orginalLegs)
	Cuae_Debug("C-UAE Adding new armor items", Cuae_UnitAffiliation(unit))
	if orginalHead then
		replaceArmorPiece(unit, avgAllyLevel, orginalHead, "Head", Cuae_GetHeadSubType(orginalHead))
	end
	if orginalTorso then
		replaceArmorPiece(unit, avgAllyLevel, orginalTorso, "Torso", Cuae_GetTorsoSubType(orginalTorso))
	end
	if orginalLegs then
		replaceArmorPiece(unit, avgAllyLevel, orginalLegs, "Legs", Cuae_GetLegsSubType(orginalLegs))
	end
end
