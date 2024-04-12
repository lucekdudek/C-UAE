local function isBlocked(slotType, components)
	--check if slot is blocked by any curently attached comp.
	for _, rawComponent in pairs(components) do
		if rawComponent ~= "" then
			local component = WeaponComponents[rawComponent]
			if component and component.BlockSlots and next(component.BlockSlots) then
				if table.find(component.BlockSlots, slotType) then
					Cuae_Debug("--> Skipping", slotType, "is blocked by", rawComponent)
					return true
				end
			end
		end
	end
	return false
end

local function addComponentInSlot(adjustedUnitLevel, slotType, slotDefault, weapon, slots)
	local availableComponents = table.find_value(slots, "SlotType", slotType).AvailableComponents
	availableComponents = table.ifilter(availableComponents, function(_, c) return c ~= slotDefault and not Cuae_ExcludeComponents[c] end)
	if #availableComponents == 0 then
		Cuae_Debug("--> Skipping", slotDefault, "from", slotType, "as it is the only one(default)")
		return false
	end
	table.sort(availableComponents, function(a, b)
		local componentA, componentB = WeaponComponents[a], WeaponComponents[b]
		return (componentA.Cost or 0) + componentA.ModificationDifficulty < (componentB.Cost or 0) + componentB.ModificationDifficulty
	end)

	local rangeFrom, rangeTo = Cuae_CalculateCostRange(adjustedUnitLevel, 1, 8)
	local minIdx = Min(#availableComponents, Max(1, DivRound(#availableComponents * rangeFrom, 100)))
	local maxIdx = Min(#availableComponents, Max(1, DivRound(#availableComponents * rangeTo, 100)))
	local suitableComponents = Cuae_TableSlice(availableComponents, minIdx, maxIdx)
	local randComponent = suitableComponents[InteractionRandRange(1, #suitableComponents, "LDCUAE")]

	local blocksAny, blocked = GetComponentBlocksAnyOfAttachedSlots(weapon, WeaponComponents[randComponent])
	if blocksAny then
		Cuae_Debug("--> Skipping", randComponent, "from", slotType, "it would block", blocked)
		return false
	else
		weapon:SetWeaponComponent(slotType, randComponent)
		Cuae_Debug("--> Added", slotType, randComponent)
		return true
	end
end

local function addComponentsInSlots(level, weapon, weaponComponentSlots, remaningComponentsCount, startIdx, endIdx)
	local handledSlots = {}
	local unhandledSlots = {}
	local slotTypeToSlotDefault = {}
	for pointerIdx = startIdx, endIdx do
		local slot = weaponComponentSlots[pointerIdx]
		local slotType = slot.SlotType
		local slotDefault = slot.DefaultComponent
		if not isBlocked(slotType, weapon.components) and addComponentInSlot(level, slotType, slotDefault, weapon, weaponComponentSlots) then
			remaningComponentsCount = remaningComponentsCount - 1
			handledSlots[slotType] = true
		else
			table.insert(unhandledSlots, slotType)
			slotTypeToSlotDefault[slotType] = slotDefault
		end
	end
	for _, slotType in ipairs(unhandledSlots) do
		if not isBlocked(slotType, weapon.components) and addComponentInSlot(level, slotType, slotTypeToSlotDefault[slotType], weapon, weaponComponentSlots) then
			remaningComponentsCount = remaningComponentsCount - 1
			handledSlots[slotType] = true
		end
	end
	return handledSlots, remaningComponentsCount
end

function Cuae_AddRandomComponents(weapon, adjustedUnitLevel)
	if not Cuae_LoadedModOptions.AddWeaponComponents then
		return
	end

	local chance = Cuae_UnitLevelToComponentChance[adjustedUnitLevel]

	-- Get all available ComponentsSlot
	local availableComponentsSlots = weapon.ComponentSlots
	-- Shuffle to decided which slot is the most lucky
	table.shuffle(availableComponentsSlots, InteractionRand(nil, "LDCUAE"))

	local remaningComponentsCount = Min(#availableComponentsSlots,
		Max(1, DivRound(#availableComponentsSlots * chance, 100)))
	Cuae_Debug("-- adding components", remaningComponentsCount, "/", #availableComponentsSlots, "AdjustedLvl:", adjustedUnitLevel)

	local handledSlots = {}
	for _ = 1, 2 do
		local startIdx, endIdx, temp = 0, 0, 0
		while remaningComponentsCount > 0 and endIdx < #availableComponentsSlots do
			startIdx = endIdx + 1
			endIdx = Min(endIdx + remaningComponentsCount, #availableComponentsSlots)
			-- add component to slots
			handledSlots, remaningComponentsCount = addComponentsInSlots(adjustedUnitLevel, weapon,
				availableComponentsSlots,
				remaningComponentsCount, startIdx, endIdx)
			-- remove used slots from list and adjust endIdx to new length
			temp = #availableComponentsSlots
			availableComponentsSlots = table.ifilter(availableComponentsSlots, function(_, component)
				return not handledSlots[component.SlotType]
			end)
			endIdx = endIdx - (temp - #availableComponentsSlots)
		end
	end
end
