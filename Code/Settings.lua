function OnMsg.ApplyModOptions(id)
	if id == "LDCUAE" then
		LoadedModOptions.ExtraHandgun = CurrentModOptions['ExtraHandgun']
		LoadedModOptions.ExtraGrenadesCount = tonumber(CurrentModOptions['ExtraGrenadesCount'])
		LoadedModOptions.ExtraGrenadesChance = tonumber(CurrentModOptions['ExtraGrenadesChance'])
		LoadedModOptions.AllowAlternativeWeaponType = CurrentModOptions['AllowAlternativeWeaponType']
		LoadedModOptions.ArmamentStrengthFactor = tonumber(CurrentModOptions['ArmamentStrengthFactor'])
		LoadedModOptions.Debug = CurrentModOptions['Debug']
	end
end
