function CalculateAdjustedUnitLevel(level, affiliation)
	return Min(20, Max(1, level + AffiliationWeight[affiliation] + LoadedModOptions.ArmoryStrengthFactor))
end

function Slice(t, from, to)
	local sliced = {}

	for i = from or 1, to or #t, 1 do
		sliced[#sliced + 1] = t[i]
	end

	return sliced
end

function CalculateCostRange(level)
	local lowEnd = Max(0, (level - 1) * 5)
	local highEnd = Min(100, level * 15)
	return lowEnd, highEnd
end

function GetCostIdx(cost, weapons)
	for i, w in ipairs(weapons) do
		if (w.Cost or 0) >= cost then
			return i
		end
	end
	return #weapons
end

function GetSuitableArnaments(level, _type, orginalCost)
	local normalizedOrginalCost = orginalCost or DefaultCost[_type]

	local orginalCostIdx = GetCostIdx(normalizedOrginalCost, AllWeapons[_type])
	local costRangeFrom, costRangeTo = CalculateCostRange(level)

	local minIdx = Min(orginalCostIdx, Max(1, DivRound(#AllWeapons[_type] * costRangeFrom, 100)))
	local maxIdx = Max(orginalCostIdx, Min(#AllWeapons[_type], DivRound(#AllWeapons[_type] * costRangeTo, 100)))

	return Slice(AllWeapons[_type], minIdx, maxIdx)
end

function CheckItemsForQuestItems(items)
	for _, h in ipairs(items) do
		if QuestItemsIcons[h.Icon] then
			return true
		end
	end
	return false
end

function RemoveWeaponsAndAmmo(unit)
	unit:ForEachItem(function(item, slot_name)
		-- Ordnance is Ammo for heavy weapons
		if slot_name == "Inventory" and (IsKindOf(item, "Ammo") or IsKindOf(item, "Ordnance")) then
			unit:RemoveItem(slot_name, item)
			DoneObject(item)
		elseif slot_name ~= "Inventory" then
			-- print("REMOVE", unit.Affiliation, slot_name, item.ItemType or item.WeaponType or "", "Tier", item.Tier, "Cost", item.Cost)
			unit:RemoveItem(slot_name, item)
			DoneObject(item)
		end
	end)
end

function GetOrginalEq(unit)
	local orginalHandheldsA = { unit:GetItemAtPos("Handheld A", 1, 1), unit:GetItemAtPos("Handheld A", 2, 1) }
	local orginalHandheldsB = { unit:GetItemAtPos("Handheld B", 1, 1), unit:GetItemAtPos("Handheld B", 2, 1) }
	local orginalHead = unit:GetItemAtPos("Head", 1, 1)
	local orginalTorso = unit:GetItemAtPos("Torso", 1, 1)
	local orginalLegs = unit:GetItemAtPos("Legs", 1, 1)
	return orginalHandheldsA, orginalHandheldsB, orginalHead, orginalTorso, orginalLegs
end

function AddRandomComponents(weapon, unitLevel)
	local chance = UnitLevelToComponentChance[unitLevel]
	-- Get all available ComponentsSlot and the options
	local avComps = weapon.ComponentSlots

	-- Scope before Railmount -> as Railmount are potential scopes.
	--- Check if there's a Rail_Mount
	local hasRail_Mount = false
	for i, data in pairs(avComps) do
		if data.SlotType == "Rail_Mount" then
			hasRail_Mount = true
			break
		end
	end
	--- Found Rail Mount, let's get a random component for the scope slot e.g. a Picatinny_Rail_1 and if it's a rail, also attach a scope.
	if hasRail_Mount then
		if InteractionRand(100, "LDCUAE") <= chance then
			local avScopes = table.find_value(avComps, "SlotType", "Scope").AvailableComponents
			if #avScopes > 0 then
				local randScope = table.rand(avScopes)
				weapon:SetWeaponComponent("Scope", randScope)
			end
			local attachedScope = weapon.components.Scope
			if attachedScope == "AWP_rail_1" or attachedScope == "G11_Rail_1" or attachedScope == "ToG_Rail_1" or attachedScope == "Picatinny_Rail_1" then
				local avMounts = table.find_value(avComps, "SlotType", "Rail_Mount").AvailableComponents
				local randMounts = table.rand(avMounts)
				weapon:SetWeaponComponent("Rail_Mount", randMounts)
			end
		end
	end

	-- now go through all slots and randomize
	for i, data in pairs(avComps) do
		local slot = data.SlotType -- getting the slot, as we use it over and over.

		--check if we're looking at an already handled scope/RailMount
		if hasRail_Mount and (slot == "Rail_Mount" or slot == "Scope") then
			goto continue
		end

		-- Let's roll and be lucky!
		if InteractionRand(100, "LDCUAE") <= chance then
			--check if slot is blocked by any curently attached comp.
			for _, attach in pairs(weapon.components) do
				if attach ~= "" then
					local def = WeaponComponents[attach]
					local blocked = false
					if def and def.BlockSlots and next(def.BlockSlots) then
						if table.find(def.BlockSlots, slot) then
							blocked = slot
							break
						end
					end
					if blocked then
						goto continue
					end
				end
			end

			-- roll for random then check if we'd block something
			local avComponents = table.find_value(avComps, "SlotType", slot).AvailableComponents
			--if table.find_value(avComps, "SlotType", slot).AvailableComponents then
			if avComponents then
				--local avComponents = table.find_value(avComps, "SlotType", slot).AvailableComponents
				local randComponent = table.rand(avComponents)
				local randDef = WeaponComponents[randComponent]
				local blocksAny, blockedId = GetComponentBlocksAnyOfAttachedSlots(weapon, randDef)
				if blocksAny then
					goto continue
				end
				weapon:SetWeaponComponent(slot.SlotType, randComponent)
			end
		end -- Dice Roll
		::continue::
	end
end

function RollNewTier(orginalTier, unitLevelTier)
	return InteractionRandRange(orginalTier, Max(orginalTier, unitLevelTier), "LDCUAE")
end
