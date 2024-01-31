local function checkForSlotType(slots, _type)
	for _, slot in pairs(slots) do
		if slot.SlotType == _type then
			return true
		end
	end
	return false
end

local function isRailMount(scope)
	return table.find(Cuae_RailMounts, scope)
end

local function handleRailMountScope(weapon, slots)
	local availableScopes = table.find_value(slots, "SlotType", "Scope").AvailableComponents
	if #availableScopes > 0 then
		local randomScope = table.rand(availableScopes)
		weapon:SetWeaponComponent("Scope", randomScope)
		Cuae_Debug("--> Added Scope", randomScope)
	end

	-- check if the added Scope is a RailMount and add a scope a top of it
	if isRailMount(weapon.components.Scope) then
		local availableRailScopes = table.find_value(slots, "SlotType", "Rail_Mount").AvailableComponents
		local randomRailScope = table.rand(availableRailScopes)
		weapon:SetWeaponComponent("Rail_Mount", randomRailScope)
		Cuae_Debug("--> Added Rail Scope", randomRailScope)
	end
end

local function isNotBlocked(_type, components)
	--check if slot is blocked by any curently attached comp.
	for _, rawComponent in pairs(components) do
		if rawComponent ~= "" then
			local component = WeaponComponents[rawComponent]
			if component and component.BlockSlots and next(component.BlockSlots) then
				if table.find(component.BlockSlots, _type) then
					Cuae_Debug("-->", _type, "is blocked by", rawComponent)
					return false
				end
			end
		end
	end
	return true
end

local function handleSlot(chance, slotType, weapon, slots)
	if InteractionRand(100, "LDCUAE") <= chance then
		local availableComponents = table.find_value(slots, "SlotType", slotType).AvailableComponents
		if availableComponents then
			local randComponent = table.rand(availableComponents)
			local blocksAny, _ = GetComponentBlocksAnyOfAttachedSlots(weapon, WeaponComponents[randComponent])
			if not blocksAny then
				weapon:SetWeaponComponent(slotType, randComponent)
				Cuae_Debug("--> Added", slotType, randComponent)
			end
		end
	end
end

function Cuae_AddRandomComponents(weapon, unitLevel)
	local chance = Cuae_UnitLevelToComponentChance[unitLevel]
	Cuae_Debug("-- adding components AdjustedLvl:", unitLevel, "Chance:", chance, "%")

	-- Get all available ComponentsSlot
	local availableComponentsSlots = weapon.ComponentSlots
	-- Shuffle for various isNotBlocked results
	table.shuffle(availableComponentsSlots, InteractionRand(nil, "LDCUAE"))

	-- Scope before RailMount -> as RailMount are potential scopes.
	local hasRailMount = checkForSlotType(availableComponentsSlots, "Rail_Mount")

	-- if does not have Rail Mount then we will add a scope the normal way
	if hasRailMount and InteractionRand(100, "LDCUAE") <= chance then
		handleRailMountScope(weapon, availableComponentsSlots)
	end

	-- handle Mount and Barrel first as it enables other items in Master of War
	if checkForSlotType(availableComponentsSlots, "Mount") and isNotBlocked("Mount", weapon.components) then
		handleSlot(chance, "Mount", weapon, availableComponentsSlots)
	end
	if checkForSlotType(availableComponentsSlots, "Barrel") and isNotBlocked("Barrel", weapon.components) then
		handleSlot(chance, "Barrel", weapon, availableComponentsSlots)
	end

	-- now go through all remaning slots
	for _, slot in pairs(availableComponentsSlots) do
		local _type = slot.SlotType

		--skip Scope if it was already handled above in hasRailMount section
		if not (_type == "Mount" or _type == "Barrel") and not (hasRailMount and (_type == "Rail_Mount" or _type == "Scope")) and isNotBlocked(_type, weapon.components) then
			handleSlot(chance, _type, weapon, availableComponentsSlots)
		end
	end
end
