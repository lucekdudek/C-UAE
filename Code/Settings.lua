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
	Cuae_LoadedModOptions.ExtraGrenadesChance = tonumber(Cuae_ForcedOptionsOrCurrentModOptions("ExtraGrenadesChance"))
	Cuae_LoadedModOptions.ArmamentStrengthFactor = tonumber(Cuae_ForcedOptionsOrCurrentModOptions("ArmamentStrengthFactor"))
	Cuae_LoadedModOptions.Debug = Cuae_ForcedOptionsOrCurrentModOptions("Debug")
	-- hidden options
	Cuae_LoadedModOptions.ApplyChangesInSateliteView = Cuae_ForcedOptionsOrCurrentModOptions("ApplyChangesInSateliteView", "HIDDEN")
	Cuae_LoadedModOptions.AlternativeWeaponTypeTables = Cuae_ForcedOptionsOrCurrentModOptions("AlternativeWeaponTypeTables", "HIDDEN")
	Cuae_LoadedModOptions.ExtraHandgun = Cuae_ForcedOptionsOrCurrentModOptions("ExtraHandgun", "HIDDEN")
	Cuae_LoadedModOptions.ExtraGrenadesCount = tonumber(Cuae_ForcedOptionsOrCurrentModOptions("ExtraGrenadesCount", "HIDDEN"))
	Cuae_LoadedModOptions.DisallowSilencers = Cuae_ForcedOptionsOrCurrentModOptions("DisallowSilencers", "HIDDEN")
	Cuae_ExcludeComponents_DisallowSilencers()
end

function OnMsg.ApplyModOptions(id)
	if id == "LDCUAE" then
		CUAE_ApplyModOptions()
	end
end
