local function Cuae_ForcedOptionsOrCurrentModOptions(key)
	if Cuae_ForcedOptions[key] ~= nil then
		return Cuae_ForcedOptions[key]
	else
		return CurrentModOptions[key]
	end
end

function CUAE_ApplyModOptions()
	Cuae_LoadedModOptions.ReplaceWeapons = Cuae_ForcedOptionsOrCurrentModOptions("ReplaceWeapons")
	Cuae_LoadedModOptions.AddWeaponComponents = Cuae_ForcedOptionsOrCurrentModOptions("AddWeaponComponents")

	Cuae_LoadedModOptions.DisallowSilencers = Cuae_ForcedOptionsOrCurrentModOptions("DisallowSilencers")
	Cuae_ExcludeComponents_DisallowSilencers()

	Cuae_LoadedModOptions.ReplaceArmor = Cuae_ForcedOptionsOrCurrentModOptions("ReplaceArmor")
	Cuae_LoadedModOptions.ExtraHandgun = Cuae_ForcedOptionsOrCurrentModOptions("ExtraHandgun")
	Cuae_LoadedModOptions.ExtraGrenadesCount = Cuae_ForcedOptionsOrCurrentModOptions("ExtraGrenadesCount")
	Cuae_LoadedModOptions.ExtraGrenadesChance = Cuae_ForcedOptionsOrCurrentModOptions("ExtraGrenadesChance")
	Cuae_LoadedModOptions.AllowAlternativeWeaponType = Cuae_ForcedOptionsOrCurrentModOptions("AllowAlternativeWeaponType")
	Cuae_LoadedModOptions.ArmamentStrengthFactor = Cuae_ForcedOptionsOrCurrentModOptions("ArmamentStrengthFactor")
	Cuae_LoadedModOptions.ApplyChangesInSateliteView = Cuae_ForcedOptionsOrCurrentModOptions("ApplyChangesInSateliteView")
	Cuae_LoadedModOptions.Debug = Cuae_ForcedOptionsOrCurrentModOptions("Debug")
end

function OnMsg.ApplyModOptions(id)
	if id == "LDCUAE" then
		CUAE_ApplyModOptions()
	end
end
