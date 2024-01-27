function OnMsg.ApplyModOptions(id)
	if id == "LDCUAE" then
		LoadedModOptions.ExtraHandgun = CurrentModOptions['ExtraHandgun']
		LoadedModOptions.ExtraGrenadesCount = tonumber(CurrentModOptions['ExtraGrenadesCount'])
		LoadedModOptions.ExtraGrenadesChance = tonumber(CurrentModOptions['ExtraGrenadesChance'])
		LoadedModOptions.AllowAlternativeWeaponType = CurrentModOptions['AllowAlternativeWeaponType']
		LoadedModOptions.ArmoryStrengthFactor = tonumber(CurrentModOptions['ArmoryStrengthFactor'])
		LoadedModOptions.Debug = CurrentModOptions['Debug']
	end
end
