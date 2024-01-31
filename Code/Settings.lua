function OnMsg.ApplyModOptions(id)
	if id == "LDCUAE" then
		Cuae_LoadedModOptions.ExtraHandgun = CurrentModOptions.ExtraHandgun
		Cuae_LoadedModOptions.ExtraGrenadesCount = tonumber(CurrentModOptions.ExtraGrenadesCount)
		Cuae_LoadedModOptions.ExtraGrenadesChance = tonumber(CurrentModOptions.ExtraGrenadesChance)
		Cuae_LoadedModOptions.AllowAlternativeWeaponType = CurrentModOptions.AllowAlternativeWeaponType
		Cuae_LoadedModOptions.ArmamentStrengthFactor = tonumber(CurrentModOptions.ArmamentStrengthFactor)
		Cuae_LoadedModOptions.Debug = CurrentModOptions.Debug
	end
end
