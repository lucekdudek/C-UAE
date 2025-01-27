local function Cuae_ForcedOptionsOrCurrentModOptions(key, hidden)
	if Cuae_ForcedOptions[key] ~= nil then
		return Cuae_ForcedOptions[key]
	elseif hidden then
		return Cuae_LoadedModOptions[key]
	else
		return CurrentModOptions[key]
	end
end

function CUAE_ApplyModOptions()
	-- visible options
	Cuae_LoadedModOptions.ReplaceWeapons = Cuae_ForcedOptionsOrCurrentModOptions("ReplaceWeapons")
	Cuae_LoadedModOptions.AddWeaponComponents = Cuae_ForcedOptionsOrCurrentModOptions("AddWeaponComponents")
	Cuae_LoadedModOptions.ReplaceArmor = Cuae_ForcedOptionsOrCurrentModOptions("ReplaceArmor")
	Cuae_LoadedModOptions.AffectMilitia = Cuae_ForcedOptionsOrCurrentModOptions("AffectMilitia")
	Cuae_LoadedModOptions.ArmamentStrengthFactor = tonumber(Cuae_ForcedOptionsOrCurrentModOptions("ArmamentStrengthFactor"))
	-- hidden options
	Cuae_LoadedModOptions.ApplyChangesInSateliteView = Cuae_ForcedOptionsOrCurrentModOptions("ApplyChangesInSateliteView", "HIDDEN")
	Cuae_LoadedModOptions.DisallowSilencers = Cuae_ForcedOptionsOrCurrentModOptions("DisallowSilencers", "HIDDEN")
	Cuae_LoadedModOptions.LoadoutTables = Cuae_ForcedOptionsOrCurrentModOptions("LoadoutTables", "HIDDEN")
	-- legacy options for Tactical AI Project
	Cuae_LoadedModOptions.ExtraGrenadesChance = tonumber(Cuae_ForcedOptionsOrCurrentModOptions("ExtraGrenadesChance", "HIDDEN"))
	Cuae_LoadedModOptions.ExtraGrenadesCount = tonumber(Cuae_ForcedOptionsOrCurrentModOptions("ExtraGrenadesCount", "HIDDEN"))
	Cuae_LoadedModOptions.ExtraHandgun = Cuae_ForcedOptionsOrCurrentModOptions("ExtraHandgun", "HIDDEN")
	Cuae_LoadedModOptions.AlternativeWeaponTypeTables = Cuae_ForcedOptionsOrCurrentModOptions("AlternativeWeaponTypeTables", "HIDDEN")
	-- build LoadoutTables from legacy options
	Cuae_LoadedModOptions.LegacyLoadoutTable = {}
	local default = {}
	default.weaponComponentsCurve = Cuae_UnitLevelToComponentChance
	default.excludeAmmoRarity = {}
	default.replacements = {}
	if Cuae_LoadedModOptions.AlternativeWeaponTypeTables then
		for _type, odds in pairs(Cuae_LoadedModOptions.AlternativeWeaponTypeTables) do
			default.replacements[_type] = {type=odds}
		end
	end
	if Cuae_LoadedModOptions.ExtraHandgun then 
		default.extraWeapons = {
			{type={{"Handgun",40}, {"MeleeWeapon",70}, {"SMG",85}, {"Shotgun",100}}},
			{type={{"Handgun",60}, {"MeleeWeapon",100}}, size=1}
		}
	else
		default.extraWeapons = {}
	end
	if Cuae_LoadedModOptions.ExtraGrenadesCount and Cuae_LoadedModOptions.ExtraGrenadesCount > 0 then
		local amount = Min(4, Cuae_LoadedModOptions.ExtraGrenadesCount)
		default.extraUtility = {
			{type={{"Flare", Cuae_LoadedModOptions.ExtraGrenadesChance}}, nightOnly=true, amount=amount},
			{type={{"Smoke", Cuae_LoadedModOptions.ExtraGrenadesChance}}, amount=amount},
			{type={{"Explosive", 25},{"Fire", 45},{"Tear", 75},{"Timed", 100}}, amount=amount},
		}
	else
		default.extraUtility = {}
	end
	Cuae_LoadedModOptions.LegacyLoadoutTable = default

	Cuae_ExcludeComponents_DisallowSilencers()
end

function OnMsg.ApplyModOptions(id)
	if id == "LDCUAE" then
		CUAE_ApplyModOptions()
	end
end

local function combineReplacements(role, default)
	local t = {}
	for _type, _ in pairs(Cuae_AllArmaments) do
		t[_type] = role[_type] or default[_type] or nil
	end
	return t
end

local function combineExtras(role, default)
	local t = {}
	for _, extra in ipairs(role) do
		table.insert(t, extra)
	end
	for _, extra in ipairs(default) do
		table.insert(t, extra)
	end
	return t
end

function Cuae_GetLoadoutTable(settings, unitAffiliation, unitRole)
	if not settings.LoadoutTables or next(settings.LoadoutTables) == nil then
		Cuae_L("D", "Using LegacyLoadoutTable:", settings.LegacyLoadoutTable)
		-- return {
		-- 	weaponComponentsCurve = Cuae_UnitLevelToComponentChance,
		-- 	excludeAmmoRarity = {},
		-- 	replacements = {},
		-- 	extraWeapons = {},
		-- 	extraUtility = {},
		-- }
		return settings.LegacyLoadoutTable
	end

	Cuae_L("D", "Building LoadoutTable for", unitAffiliation, "from", settings.LoadoutTables[unitAffiliation])
	local settingsT = settings.LoadoutTables[unitAffiliation] or {}
	local roleT = settingsT[unitRole] or {}
	local defaultT = settingsT["_default"] or {}
	local loadoutTable = {
		weaponComponentsCurve = roleT.weaponComponentsCurve or defaultT.weaponComponentsCurve or Cuae_UnitLevelToComponentChance,
		excludeAmmoRarity = roleT.excludeAmmoRarity or defaultT.excludeAmmoRarity or {},
		replacements = combineReplacements(roleT.replacements or {}, defaultT.replacements or {}),
		extraWeapons = combineExtras(roleT.extraWeapons or {}, defaultT.extraWeapons or {}),
		extraUtility = combineExtras(roleT.extraUtility or {}, defaultT.extraUtility or {}),
	}
	return loadoutTable
end
