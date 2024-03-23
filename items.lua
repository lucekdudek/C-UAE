return {
	PlaceObj('ModItemCode', {
		'name', "Armor",
		'CodeFileName', "Code/Armor.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "Compatibility",
		'CodeFileName', "Code/Compatibility.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "Cfg",
		'CodeFileName', "Code/Cfg.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "Main",
		'CodeFileName', "Code/Main.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "Settings",
		'CodeFileName', "Code/Settings.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "Utils",
		'CodeFileName', "Code/Utils.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "Weapon",
		'CodeFileName', "Code/Weapon.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "WeaponComponents",
		'CodeFileName', "Code/WeaponComponents.lua",
	}),
	PlaceObj('ModItemOptionToggle', {
		'name', "ReplaceWeapons",
		'DisplayName', "Replace Weapons",
		'Help', "When enabled, replaces orginal enemy weapons with new ones",
		'DefaultValue', true,
	}),
	PlaceObj('ModItemOptionToggle', {
		'name', "ReplaceArmor",
		'DisplayName', "Replace Armor",
		'Help', "When enabled, replaces orginal enemy armor with new ones",
		'DefaultValue', true,
	}),
	PlaceObj('ModItemOptionChoice', {
		'name', "ExtraGrenadesChance",
		'DisplayName', "Extra Grenades Chance",
		'Help', "Percentage chance to give enemies extra granades",
		'DefaultValue', "50",
		'ChoiceList', {
			"0",
			"10",
			"20",
			"30",
			"40",
			"50",
			"60",
			"70",
			"80",
			"90",
			"100",
		},
	}),
	PlaceObj('ModItemOptionChoice', {
		'name', "ArmamentStrengthFactor",
		'DisplayName', "Armament Strength Factor",
		'Help', "Alters strength of distributed Armament. It is recomended to keep it at 0",
		'DefaultValue', "0",
		'ChoiceList', {
			"-5",
			"-4",
			"-3",
			"-2",
			"-1",
			"0",
			"1",
			"2",
			"3",
			"4",
			"5",
		},
	}),
}