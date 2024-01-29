local function checkForRailMount(slots)
	for _, slot in pairs(slots) do
		if slot.SlotType == "Rail_Mount" then
			return true
		end
	end
	return false
end

local function isRailMount(scope)
	return scope == "AWP_rail_1" or scope == "G11_Rail_1" or scope == "ToG_Rail_1" or scope == "Picatinny_Rail_1"
end


function AddRandomComponents(weapon, unitLevel)
	local chance = UnitLevelToComponentChance[unitLevel]
	Debug("-- adding components AdjustedLvl:", unitLevel, "Chance:", chance)

	-- Get all available ComponentsSlot and the options
	local availableComponentsSlot = weapon.ComponentSlots

	-- Scope before Railmount -> as Railmount are potential scopes.
	--- Check if there's a Rail_Mount
	local hasRailMount = checkForRailMount(availableComponentsSlot)
	Debug("--> has Rail Mount:", hasRailMount)

	--- Found Rail Mount, let's get a random component for the scope slot e.g. a Picatinny_Rail_1 and if it's a rail, also attach a scope.
	if hasRailMount then
		if InteractionRand(100, "LDCUAE") <= chance then
			local availableScopes = table.find_value(availableComponentsSlot, "SlotType", "Scope").AvailableComponents
			if #availableScopes > 0 then
				local randomScope = table.rand(availableScopes)
				weapon:SetWeaponComponent("Scope", randomScope)
			end
			local attachedScope = weapon.components.Scope

			-- check if the added Scope is a RailMount and add a scope a top of it
			if isRailMount(attachedScope) then
				local availableRailScopes = table.find_value(availableComponentsSlot, "SlotType", "Rail_Mount")
				.AvailableComponents
				local randomRailScope = table.rand(availableRailScopes)
				weapon:SetWeaponComponent("Rail_Mount", randomRailScope)
			end
		end
	end

	-- now go through all slots and randomize
	for i, slot in pairs(availableComponentsSlot) do
		local _type = slot.SlotType -- getting the slot, as we use it over and over.

		--check if we're looking at an already handled scope/RailMount
		if hasRailMount and (_type == "Rail_Mount" or _type == "Scope") then
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
						if table.find(def.BlockSlots, _type) then
							blocked = _type
							break
						end
					end
					if blocked then
						goto continue
					end
				end
			end

			-- roll for random then check if we'd block something
			local avComponents = table.find_value(availableComponentsSlot, "SlotType", _type).AvailableComponents
			--if table.find_value(avComps, "SlotType", slot).AvailableComponents then
			if avComponents then
				--local avComponents = table.find_value(avComps, "SlotType", slot).AvailableComponents
				local randComponent = table.rand(avComponents)
				local randDef = WeaponComponents[randComponent]
				local blocksAny, blockedId = GetComponentBlocksAnyOfAttachedSlots(weapon, randDef)
				if blocksAny then
					goto continue
				end
				weapon:SetWeaponComponent(_type.SlotType, randComponent)
			end
		end
		::continue::
	end
end
