function OnMsg.ApplyModOptions(id)
	if id == "LDCUAE" then
		Cuae_LoadedModOptions.ReplaceWeapons = CurrentModOptions.ReplaceWeapons
		Cuae_LoadedModOptions.ReplaceArmor = CurrentModOptions.ReplaceArmor
		Cuae_LoadedModOptions.ExtraHandgun = CurrentModOptions.ExtraHandgun
		Cuae_LoadedModOptions.ExtraGrenadesCount = tonumber(CurrentModOptions.ExtraGrenadesCount)
		Cuae_LoadedModOptions.ExtraGrenadesChance = tonumber(CurrentModOptions.ExtraGrenadesChance)
		Cuae_LoadedModOptions.AllowAlternativeWeaponType = CurrentModOptions.AllowAlternativeWeaponType
		Cuae_LoadedModOptions.ArmamentStrengthFactor = tonumber(CurrentModOptions.ArmamentStrengthFactor)
		Cuae_LoadedModOptions.GrenadesDropChance = tonumber(CurrentModOptions.GrenadesDropChance)
		Cuae_LoadedModOptions.Debug = CurrentModOptions.Debug
	end
end
