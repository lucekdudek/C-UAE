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

local function addComponentInSlot(slotType, weapon, slots)
	local availableComponents = table.find_value(slots, "SlotType", slotType).AvailableComponents
	table.shuffle(availableComponents, InteractionRand(nil, "LDCUAE"))
	local randComponent = table.rand(availableComponents, InteractionRand(nil, "LDCUAE"))
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

local function addComponentsInSlots(weapon, weaponComponentSlots, remaningComponentsCount, startIdx, endIdx)
	local handledSlots = {}
	local unhandledSlots = {}
	for pointerIdx = startIdx, endIdx do
		local slotType = weaponComponentSlots[pointerIdx].SlotType
		if not isBlocked(slotType, weapon.components) and addComponentInSlot(slotType, weapon, weaponComponentSlots) then
			remaningComponentsCount = remaningComponentsCount - 1
			handledSlots[slotType] = true
		else
			table.insert(unhandledSlots, slotType)
		end
	end
	for _, slotType in ipairs(unhandledSlots) do
		if not isBlocked(slotType, weapon.components) and addComponentInSlot(slotType, weapon, weaponComponentSlots) then
			remaningComponentsCount = remaningComponentsCount - 1
			handledSlots[slotType] = true
		end
	end
	return handledSlots, remaningComponentsCount
end

function Cuae_AddRandomComponents(weapon, unitLevel)
	local chance = Cuae_UnitLevelToComponentChance[unitLevel]

	-- Get all available ComponentsSlot
	local availableComponentsSlots = weapon.ComponentSlots
	-- Shuffle to decided which slot is the most lucky
	table.shuffle(availableComponentsSlots, InteractionRand(nil, "LDCUAE"))

	local remaningComponentsCount = Min(#availableComponentsSlots,
		Max(1, DivRound(#availableComponentsSlots * chance, 100)))
	Cuae_Debug("-- adding components", remaningComponentsCount, "/", #availableComponentsSlots, "AdjustedLvl:", unitLevel)

	local handledSlots = {}
	for _ = 1, 2 do
		local startIdx, endIdx, temp = 0, 0, 0
		while remaningComponentsCount > 0 and endIdx < #availableComponentsSlots do
			startIdx = endIdx + 1
			endIdx = Min(endIdx + remaningComponentsCount, #availableComponentsSlots)
			-- add component to slots
			handledSlots, remaningComponentsCount = addComponentsInSlots(weapon, availableComponentsSlots,
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
