return PlaceObj('ModDef', {
	'title', "Cross-Mod Universal Armament Expansion",
	'description', "[h1]Cross-Mod Universal Armament  Expansion (C-UAE)[/h1]\n\n---------------\n\n[h2]What does it do[/h2]\n\nIncrease the variety of [b]Weapons[/b] and [b]Armor[/b] of all enemies you meet.\n\nThe goal of this modification is to be [b]compatible[/b] with other modifications out of the box without the requirement of compatibility patches. So mods like ToG, Rato's Gameplay Balance and Overhaul, or Tactical AI can be used with no issues.\n\n---------------\n\n[h2]How does it do[/h2]\nWhenever players enter a sector all enemies are scanned and a profile of their [b]level[/b], [b]affiliation[/b], and [b]loadout[/b] is created. This profile then is used to generate new weapons and armor. Mod uses [b]Cost[/b] property of items to access the items of similar strength.\n\n[h3]Weapons[/h3]\nNew weapons are generated of the same type. Based on the enemy level, affiliation, and the cost of the original weapon, the mod finds the proper weapon cost range and gives a random weapon from that range.\n\nNew weapons are also granted Components/Weapons' Mods (e.g. Scopes or Silencer) based on enemy level and affiliation.\n\nAdditionally, if the original loadout has free spots left and there was no Handgun or Grenade then the enemy might get an extra Handgun or Grenade.\n\n[h3]Armor[/h3]\nArmor follows a similar logic to weapons. Based on the enemy level, affiliation, and original armor new armor is spawned.\n\nNote: Enemies can't get unique weapons like Golden Gun.\n\n---------------\n\n[h2]Configuration options[/h2]\n[list]\n    [*][b]Extra Handgun[/b] If the original loadout has free spots left and there is no Handgun the enemy will get an extra Handgun.\n    [*][b]Extra Grenades Count[/b] If the original loadout has free spots left and there is no Grenade the enemy will get an extra Grenade of this count. Setting it to 0 causes no extra grenades.\n    [*][b]Extra Grenades Chance[/b] modifies the chance an enemy will get extra granades.\n    [*][b]Armament Strength Factor[/b] dificulty adjustement. Negative values cause the cost range to be closer to the cheapest armaments. Positive values make the cost range to be closer to expensive armaments. Note: orginal loadout is always within the cost range.\n    [*][b]Allow Alternative Weapon Type[/b] alternative version of weapon generation. Handguns can randomly be upgraded to SMGs, SMGs to ARs, and ARs to LMG or Sniper Rifles. \n    [*][b]Allow Glow And Flare Sticks[/b] allows to disable Glow and Flare Sticks from spawning on enemies. \n[/list]\n\n---------------\n\n[h2]Notes[/h2]\n[list]\n    [*][b]Compatible[/b] with all weapon mods and new enemies mods(as long as they have one of the enemy Affiliation)\n    [*]Mod uses enemy level as a base therefore it is affected by difficulty and can be more adjusted by using my other mod [b]Adjust Difficulty Settings[/b]\n    [*]Does not change enemies with Unique weapons like Pierre\n    [*]Can be enabled and disabled at any point\n    [*]Works with all saves. Will not change enemies in the middle of a fight.\n    [*]No compatible with Random Enemy Weapons as it duplicates its features\n    [*]Sourc code will be available here https://github.com/lucekdudek/C-UAE\n[/list]\n\n---------------\n\n[h2]Bugs and limitations[/h2]\n[list]\n    [*]Due to a lack of a better solution, Unique weapons are recognized by their UI image path so mods that reuse those can prevent this mod from buffin an enemy holding that weapon\n    [*] The drop chance of grenades is hardcoded to match the original drop chance of 5% therefore drop chance mods won't affect how often grenades are being dropped\n    [*]Enemies in the first sector of the game are being loaded twice causing the mod to roll for new loadout them twice. I am looking for a solution as a flag that is saved on units does not persist in this edge case\n[/list]",
	'image', "Mod/LDCUAE/Images/Preview.png",
	'last_changes', "Improve weapon Components logic",
	'id', "LDCUAE",
	'author', "Lucjan",
	'version_major', 1,
	'version_minor', 5,
	'version', 40,
	'lua_revision', 233360,
	'saved_with_revision', 347965,
	'affected_resources', {
		PlaceObj('ModResourcePreset', {
			'Class', "CharacterEffectCompositeDef",
			'Id', "CUAE",
			'ClassDisplayName', "Character effect",
		}),
	},
	'code', {
		"CharacterEffect/CUAE.lua",
		"Code/Armor.lua",
		"Code/Cfg.lua",
		"Code/Main.lua",
		"Code/Settings.lua",
		"Code/Utils.lua",
		"Code/Weapon.lua",
		"Code/WeaponComponents.lua",
	},
	'default_options', {
		AllowAlternativeWeaponType = true,
		AllowGlowAndFlareSticks = true,
		ArmamentStrengthFactor = "0",
		Debug = false,
		ExtraGrenadesChance = "50",
		ExtraGrenadesCount = "2",
		ExtraHandgun = true,
	},
	'has_data', true,
	'saved', 1706552855,
	'code_hash', -2202700496953912364,
	'steam_id', "3148282483",
	'TagWeapons&Items', true,
	'TagEnemies', true,
	'TagGameSettings', true,
})