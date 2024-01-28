return {
	PlaceObj('ModItemCharacterEffectCompositeDef', {
		'Id', "CUAE",
		'object_class', "StatusEffect",
		'DisplayName', T(442647548138, --[[ModItemCharacterEffectCompositeDef CUAE DisplayName]] "CUAE"),
		'type', "Buff",
	}),
	PlaceObj('ModItemCode', {
		'name', "Armor",
		'CodeFileName', "Code/Armor.lua",
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
	PlaceObj('ModItemOptionToggle', {
		'name', "ExtraHandgun",
		'DisplayName', "Extra Handgun",
		'Help', "When enabled, gives enemies a handgun in an empty weapon slot",
		'DefaultValue', true,
	}),
	PlaceObj('ModItemOptionChoice', {
		'name', "ExtraGrenadesCount",
		'DisplayName', "Extra Grenades Count",
		'Help', "When enabled, gives enemies a grenades in an empty weapon slot",
		'DefaultValue', "2",
		'ChoiceList', {
			"0",
			"1",
			"2",
			"3",
			"4",
			"5",
			"6",
			"7",
			"8",
			"9",
			"10",
		},
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
		'Help', "Alters strength of distributed Armament",
		'DefaultValue', "0",
		'ChoiceList', {
			"-10",
			"-9",
			"-8",
			"-7",
			"-6",
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
			"6",
			"7",
			"8",
			"9",
			"10",
		},
	}),
	PlaceObj('ModItemOptionToggle', {
		'name', "AllowAlternativeWeaponType",
		'DisplayName', "Allow Alternative Weapon Type",
		'Help', "When enabled, gives enemies chance of upgrading Handguns to SMGs and SMGs to ARs",
		'DefaultValue', true,
	}),
	PlaceObj('ModItemOptionToggle', {
		'name', "Debug",
		'DisplayName', "Enable debug messages",
		'Help', "When enabled, prints debug logs in the game log file",
	}),
}