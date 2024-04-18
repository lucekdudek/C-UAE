return {
	PlaceObj('ModItemCode', {
		'name', "Ammo",
		'CodeFileName', "Code/Ammo.lua",
	}),
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
		'name', "AddWeaponComponents",
		'DisplayName', "Add Weapon Components",
		'Help', "When enabled, weapons are strengthened with attachments. Better attachments are given to higher-level enemies. This also causes the dropped weapons to have attachments.",
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
		'DisplayName', "Armament Progression Speed Factor",
		'Help', "Default: 0. Alters how fast better armaments and better weapons attachments will start appearing on enemies. It is not a difficulty option. Higher values are meant for players who want to gear up faster.",
		'DefaultValue', "0",
		'ChoiceList', {
			"-3",
			"-2",
			"-1",
			"0",
			"2",
			"4",
			"6",
			"8",
		},
	}),
}