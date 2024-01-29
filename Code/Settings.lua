function OnMsg.ApplyModOptions(id)
	if id == "LDCUAE" then
		LoadedModOptions.ExtraHandgun = CurrentModOptions['ExtraHandgun']
		LoadedModOptions.ExtraGrenadesCount = tonumber(CurrentModOptions['ExtraGrenadesCount'])
		LoadedModOptions.ExtraGrenadesChance = tonumber(CurrentModOptions['ExtraGrenadesChance'])
		LoadedModOptions.AllowAlternativeWeaponType = CurrentModOptions['AllowAlternativeWeaponType']
		LoadedModOptions.AllowGlowAndFlareSticks = CurrentModOptions['AllowGlowAndFlareSticks']
		LoadedModOptions.ArmamentStrengthFactor = tonumber(CurrentModOptions['ArmamentStrengthFactor'])
		LoadedModOptions.Debug = CurrentModOptions['Debug']
		Debug("C-UAE Refreshing tables on ApplyModOptions")
		BuildWeaponTables()
	end
end
