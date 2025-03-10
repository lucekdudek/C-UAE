local function rollType(config)
	local rand = InteractionRandRange(1, 100, "LDCUAE")
	for _, typeChanceTuple in ipairs(config) do
		if rand <= typeChanceTuple[2] then
			return typeChanceTuple[1]
		end
	end
end

local function getNewType(loadoutTable, profile)
	if not loadoutTable.replacements[profile.ogType] then
		return profile.ogType
	end

	if loadoutTable.replacements[profile.ogType].discard then
		return nil
	end

	if not loadoutTable.replacements[profile.ogType].type then
		return profile.ogType
	end

	local randType = rollType(loadoutTable.replacements[profile.ogType].type)
	if randType then
		return randType
	end

	return profile.ogType
end

local function getNewSize(loadoutTable, profile)
	return loadoutTable.replacements[profile.ogType] and loadoutTable.replacements[profile.ogType].size or 2
end

local function getWeaponComponentsPriority(loadoutTable, _type)
	return loadoutTable.weaponComponentsPriorities and loadoutTable.weaponComponentsPriorities[_type] or nil
end

local function getReplacementPolicy(loadoutTable, replaceWeaponsSetting, originalWeaponsAndUtil)
	local replacements = {}
	for _, w in ipairs(originalWeaponsAndUtil.W) do
		local newType = getNewType(loadoutTable, w)
		w.newSize = getNewSize(loadoutTable, w)
		if Cuae_ImmunityTable[w.ogPresetId] or (newType == w.ogType and not replaceWeaponsSetting) then
			Cuae_L("D", " Og weapon will be kept", w.ogPresetId)
			w.keep = true
			w.newType = w.ogType
			w.weaponComponentsPriority = getWeaponComponentsPriority(loadoutTable, w.newType)
			table.insert(replacements, w)
		elseif not newType then
			Cuae_L("D", " Og weapon will be discarded", w.ogPresetId)
			w.discard = true
			table.insert(replacements, w)
		elseif not replaceWeaponsSetting then
			Cuae_L("D", " Og weapon will be replaced", w.ogPresetId, "with default", newType, "for affiliation")
			w.newType = newType
			w.useDefault = true
			w.weaponComponentsPriority = getWeaponComponentsPriority(loadoutTable, w.newType)
			table.insert(replacements, w)
		else
			Cuae_L("D", " Og weapon will be replaced", w.ogPresetId, "with", newType)
			w.newType = newType
			w.weaponComponentsPriority = getWeaponComponentsPriority(loadoutTable, w.newType)
			table.insert(replacements, w)
		end
	end
	for _, u in ipairs(originalWeaponsAndUtil.U) do
		local newType = getNewType(loadoutTable, u)
		if Cuae_ImmunityTable[u.ogPresetId] then
			Cuae_L("D", " Og utility will be kept", u.ogPresetId)
			u.keep = true
			u.newType = u.ogType
			table.insert(replacements, u)
		elseif not newType then
			Cuae_L("D", " Og utility will be discarded", u.ogPresetId)
			u.discard = true
			table.insert(replacements, u)
		else
			Cuae_L("D", " Og utility will be replaced", u.ogPresetId, "with", newType)
			u.newType = newType
			table.insert(replacements, u)
		end
	end
	return replacements
end

local function getReplacementTypes(replacements)
	local replacementTypes = {}
	for _, r in ipairs(replacements) do
		if not r.discard then
			replacementTypes[r.newType] = true
		end
	end
	return replacementTypes
end

local function getExtraWeaponsPolicy(loadoutTable, replacementTypes)
	local extraWeapons = {}
	for _, extraCfg in ipairs(loadoutTable.extraWeapons) do
		local ew = {}
		if not extraCfg.type then
			Cuae_L("W", " No extra weapon type property defined, ignoring")
		else
			ew.newType = rollType(extraCfg.type)
			if not ew.newType then
				Cuae_L("D", " Skipping extra weapon policy as it roll nil type")
			elseif replacementTypes[ew.newType] then
				Cuae_L("D", " Skipping extra weapon policy of type", ew.newType, "as type already in replacements")
			else
				Cuae_L("D", " Extra weapon of type", ew.newType, "will be added")
				replacementTypes[ew.newType] = true
				ew.isWeapon = true
				ew.newSize = extraCfg.size or 2
				ew.weaponComponentsPriority = getWeaponComponentsPriority(loadoutTable, ew.newType)
				table.insert(extraWeapons, ew)
			end
		end
	end
	return extraWeapons
end

local function getExtraUtilityPolicy(loadoutTable, replacementTypes)
	local extraUtility = {}
	for _, extraCfg in ipairs(loadoutTable.extraUtility) do
		local eu = {}
		if extraCfg.nightOnly and not (GameState.Night or GameState.Underground) then
			Cuae_L("D", " Skipping night-only utility policy")
		elseif not extraCfg.type then
			Cuae_L("W", " No extra utility type property defined, ignoring")
		else
			eu.newType = rollType(extraCfg.type)
			if not eu.newType then
				Cuae_L("D", " Skipping extra utility policy as it roll nil type")
			elseif replacementTypes[eu.newType] then
				Cuae_L("D", " Skipping extra utility policy of type", eu.newType, "as type already in replacements")
			else
				Cuae_L("D", " Extra utility of type", eu.newType, "will be added")
				replacementTypes[eu.newType] = true
				eu.amount = extraCfg.amount or 2
				table.insert(extraUtility, eu)
			end
		end
	end
	return extraUtility
end

function Cuae_GetChangePolicy(loadoutTable, replaceWeaponsSetting, originalWeaponsAndUtil)
	Cuae_L("D", "Getting replacements policy:")
	local replacements = getReplacementPolicy(loadoutTable, replaceWeaponsSetting, originalWeaponsAndUtil)
	local replacementTypes = getReplacementTypes(replacements)
	Cuae_L("D", "Getting extra weapons policy:")
	local extraWeapons = getExtraWeaponsPolicy(loadoutTable, replacementTypes)
	Cuae_L("D", "Getting extra utility policy:")
	local extraUtility = getExtraUtilityPolicy(loadoutTable, replacementTypes)
	return {
		weaponComponentsCurve = loadoutTable.weaponComponentsCurve,
		excludeAmmoRarity = loadoutTable.excludeAmmoRarity,
		replacements = replacements,
		extraWeapons = extraWeapons,
		extraUtility = extraUtility,
	}
end
