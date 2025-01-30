local function isBlocked(slotType, components)
	-- check if slot is blocked by any curently attached comp.
	-- TODO: consider table.find_value(campaign.Sectors, "Id", campaign.InitialSector)
	for _, rawComponent in pairs(components) do
		if rawComponent ~= "" then
			local component = WeaponComponents[rawComponent]
			if component and component.BlockSlots and next(component.BlockSlots) then
				if table.find(component.BlockSlots, slotType) then
					Cuae_L("D", "    Skipping", slotType, "is blocked by", rawComponent)
					return true
				end
			end
		end
	end
	return false
end

local ITEM_COST = {
	FineSteelPipe = 1500, -- lv>3
	OpticalLens = 2000, -- lv>4
	Microchip = 3500, -- lv>7
	-- deafult 2000 in case someone add new crafing item
}
local function getComponentRarity(componentId)
	local component = WeaponComponents[componentId]
	if not component then
		return 0
	end
	local difficulty = component.ModificationDifficulty or 0
	local partsCost = component.Cost or 0
	local itemsCost = 0
	for _, additionalCost in ipairs(component.AdditionalCosts) do
		itemsCost = itemsCost + (ITEM_COST[additionalCost.Type] or 2000) * (additionalCost.Amount or 0)
	end
	return difficulty + partsCost + itemsCost
end

local function addComponentInSlot(adjustedUnitLevel, slotType, slotDefault, weapon, slots)
	local availableComponents = table.find_value(slots, "SlotType", slotType).AvailableComponents
	local maxRarity = adjustedUnitLevel * 500
	availableComponents = table.ifilter(availableComponents, function(_, c)
		return c ~= slotDefault and WeaponComponents[c] and not Cuae_ExcludeComponents[c] and getComponentRarity(c) < maxRarity
	end)
	if #availableComponents == 0 then
		Cuae_L("D", "    Skipping", slotDefault, "from", slotType, "as it is the only one available")
		return false
	end
	table.sort(availableComponents, function(a, b)
		return getComponentRarity(a) < getComponentRarity(b)
	end)

	local rangeFrom, rangeTo = Cuae_CalculateCostRange(adjustedUnitLevel, 6, 24)
	local minIdx = Min(#availableComponents, Max(1, DivRound(#availableComponents * rangeFrom, 100)))
	local maxIdx = Min(#availableComponents, Max(1, DivRound(#availableComponents * rangeTo, 100)))
	local suitableComponents = Cuae_TableSlice(availableComponents, minIdx, maxIdx)
	local randComponent = suitableComponents[InteractionRandRange(1, #suitableComponents, "LDCUAE")]

	local blocksAny, blocked = GetComponentBlocksAnyOfAttachedSlots(weapon, WeaponComponents[randComponent])
	if blocksAny then
		Cuae_L("D", "    Skipping", randComponent, "from", slotType, "it would block", blocked)
		return false
	else
		weapon:SetWeaponComponent(slotType, randComponent)
		Cuae_L("D", "    Added", slotType, randComponent, "Rarity", getComponentRarity(randComponent), "/", maxRarity)
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

function Cuae_AddRandomComponents(settings, weapon, adjustedUnitLevel, weaponComponentsCurve)
	if not settings.AddWeaponComponents then
		return
	end

	local chance = weaponComponentsCurve and weaponComponentsCurve[adjustedUnitLevel] or Cuae_UnitLevelToComponentChance[adjustedUnitLevel]

	-- Get all available ComponentsSlot
	local availableComponentsSlots = weapon.ComponentSlots
	-- Shuffle to decided which slot is the most lucky
	table.shuffle(availableComponentsSlots, InteractionRand(nil, "LDCUAE"))

	local remaningComponentsCount = Min(#availableComponentsSlots, Max(1, DivRound(#availableComponentsSlots * chance, 100)))
	Cuae_L("D", "   adding components", remaningComponentsCount, "/", #availableComponentsSlots)

	local handledSlots = {}
	for _ = 1, 2 do
		local startIdx, endIdx, temp = 0, 0, 0
		while remaningComponentsCount > 0 and endIdx < #availableComponentsSlots do
			startIdx = endIdx + 1
			endIdx = Min(endIdx + remaningComponentsCount, #availableComponentsSlots)
			-- add component to slots
			handledSlots, remaningComponentsCount = addComponentsInSlots(adjustedUnitLevel, weapon, availableComponentsSlots, remaningComponentsCount, startIdx, endIdx)
			-- remove used slots from list and adjust endIdx to new length
			temp = #availableComponentsSlots
			availableComponentsSlots = table.ifilter(availableComponentsSlots, function(_, component)
				return not handledSlots[component.SlotType]
			end)
			endIdx = endIdx - (temp - #availableComponentsSlots)
		end
	end
end
