return PlaceObj('ModDef', {
	'title', "C-UAE Cross-Mod Universal Armament Expansion",
	'description', "[h1]Cross-Mod Universal Armament  Expansion (C-UAE)[/h1]\n\nTL;DR\n\nSemi-Random Enemy Weapons and Semi-Random Enemy Armor with Robust weapon attachment and ammo distribution system that scale with campaign progression\n\n[h2]What does it do[/h2]\n\nIncrease the variety of [b]Weapons[/b] and [b]Armor[/b] of all enemies you meet.\n\nThe goal of this modification is to be [b]compatible[/b] with other modifications out of the box without the requirement of compatibility patches. So mods like ToG, Rato's Overhaul, or AI mods can be used with no issues.\n\n[h2]Featuers:[/h2]\n[list]\n    [*][b]Enemies get new weapons and armor of similar strength[/b]\n    [*][b]Weapons and Armor from other modifications are automatically added to the pool of available weapons[/b](e.g. Tons of Guns or Masters of War)\n    [*][b]Robust attachements system. Weapons are granted attachments matching adjusted enemy level. At higher level, enemies will have more and more powerful attachments[/b]\n    [*][b]Ammunition distribution system. At higher level, enemies will have more and more powerful ammunition[/b]\n    [*][b]Works with old saves, can be disabled at anypoint[/b]\n    [*][b][Configuration option] Strength of new armaments can be adjusted[/b]\n    [*][b]Armaments condition (how much they are damaged) matches the condition of the original loadout[/b]\n    [*][b]Mod uses drop chance logic from the base game[/b](Most mods that modify drop chance are compatible)\n    [*][b][Configuration option] Enemies get extra Grenades[/b]\n    [*][b]Night grenades(flares etc) are only distributed during a night and in underground sectors[/b]\n    [*][b]Heavy Weapons are distributed based on ammunition type[/b](RocketMan still shoots rockets, Montar Enemy still use Montar-like weapons)\n    [*][b]Mod does not affect unique armaments[/b](e.g.[spoiler] Pierre won't lose his unique machete [/spoiler])\n[/list]\n\n[h2]C-UAE vs Random Enemy Weapons[/h2]\n\n[b]C-UAE[/b] distributes all available weapons among all enemy fractions while [b]REW[/b] provides a more structured distribution where all weapons are picked by hand to be distributed for specific fractions only. This difference leads to multiple consequences. E.g. in REW weapons from mods that don't support REW won't be distributed at all but in C-UAE Weapons that are not configured to be available in Bobby Ray's won't be distributed\n\n[b]Configuration options[/b] allow to disable weapon replacement enabling players to use logic for weapons for [b]REW[/b] and the rest of the features of C-UAE\n\n[h2]Recommended mods to use with C-UAE[/h2]\n\n[b]More arnaments[/b]\n\n[list]\n    [*][b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=3157842808] More Armor [/url][/b] Note: new vanilla armor and variations of existing once\n    [*][b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=3090261695] Masters of War [/url][/b] Note: new weapons\n    [*][b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=3023672178] Tons of Guns [/url][/b] Note: new weapons(a lot of them)\n[/list]\n\n[b]Enemy AI[/b]\n\n[list]\n    [*][b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=3042581131] Tactical AI Project (Old The Grand Chien Nightmare) [/url][/b] Best AI mod there is\n[/list]\n\n[b]Alternative balance (alongside with more armaments)[/b]\n\n[list]\n    [*][b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=3021320057] Rato's Gameplay Balance and Overhaul 3 [/url][/b] Note: new weapons logic\n    [*][b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=3022236291] Timmeh's Armor Overhaul [/url][/b] and [b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=3017633184] Timmeh's Weapon Overhaul [/url][/b] Note: new weapons and armors and new armor, not compatible with other mods\n    [*][b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=3038472406] BCE Guns [/url][/b] and [b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=3031643676] Armor Crafting Economy [/url][/b] Note: new weapons and armor, not compatible with other mods\n[/list]\n\nNote: [b]BCE[/b] and [b]Timmeh's[/b] Weapon are changing prices of vanilla weapons and are not balanced for vanilla prices so they will not work with ToG and/or MoW\n\nDon't use all mods from the above lists together. For information on which mods can be used with which related to the particular mod's description\n\n[h2]How does it do[/h2]\nWhenever players meet enemies in the satellite or tactical view, all enemies are scanned and a profile of their [b]level[/b], [b]affiliation[/b], and [b]loadout[/b] is created. This profile then is used to generate new weapons and armor. Mod remembers which enemies were already changed and meeting the same enemies for a second time will not trigger the mod's logic. \n\n[h3]Avaiable Armaments Logic[/h3]\nC-UAE is built based on in game system of Cost and Bobby Ray's CanAppearInShop property. So only armaments that can appear in the shop are distributed to enemies.\n\nThis way mod automatically filters out all leftover, unfinished, or quest items. Those items can be found in both the Vanilla game as well as in some popular weapon mods.\n\n[h3]Weapons[/h3]\nNew weapons are generated of the same type. Based on the enemy level, affiliation, and the cost of the original weapon, the mod finds the proper weapon cost range and gives a random weapon from that range.\n\nNew weapons are also granted Components/Weapons' Mods (e.g. Scopes or Silencer) based on enemy level.\n\nAdditionally, if the original loadout has free spots left and there was no Handgun or Grenade then the enemy might get an extra Handgun or Grenade.\n\n[h3]Armor[/h3]\nArmor follows a similar logic to weapons. Based on the enemy level, affiliation, and original armor new one is added.\n\n[h3]Uniques[/h3]\nEnemies can't get unique weapons like Golden Gun. But also enemies who wield unique weapons or armor will keep them. For example, enemies with \"Shiny and Chrome Helmet\" will keep it but their weapon and other armor pieces will get replaced according to the mod logic.\n\n[h2]Configuration options[/h2]\nSee [b]Discussions[/b] section.\n\n[h2]Special compatibility options for modders[/h2]\n\nRead more in the [b]Discussions[/b] section.\n\n[h2]Notes[/h2]\n[list]\n    [*]Will not change enemies in the middle of a fight.\n    [*]Does not work with [b]New weapons of combinations of the original model[/b] as it is outdated.\n    [*]Source code is available at [url=https://github.com/lucekdudek/C-UAE]GitHub[/url]\n[/list]",
	'image', "Mod/LDCUAE/Images/Preview.png",
	'last_changes', "Version 3.0\nAdded new modders compatibility features\nAdded support for Militia\nAdded feature that allows enemies to keep the original weapons and armor sometimes\nRemoved Silencers from spawning as enemeis have no use of them - tested with vanilla tog mow and rato\nKept weapons now will get weapons components if possible\nAdjusted special compatibility features for TGCN(Tactical AI proejct)\nRefactored weapon replacement decision logic - fixed bugs - improved code quality\nHidden most mod options to improve user experience - now avaiavle via modders compatibility features",
	'ignore_files', {
		"*.git/*",
		"*.svn/*",
		"*.code-workspace/*",
		"local/*",
	},
	'id', "LDCUAE",
	'author', "Lucjan",
	'version_major', 3,
	'version', 86,
	'lua_revision', 233360,
	'saved_with_revision', 350233,
	'code', {
		"Code/Armor.lua",
		"Code/Compatibility.lua",
		"Code/Cfg.lua",
		"Code/Main.lua",
		"Code/Settings.lua",
		"Code/Utils.lua",
		"Code/Weapon.lua",
		"Code/WeaponComponents.lua",
	},
	'default_options', {
		ArmamentStrengthFactor = "0",
		ExtraGrenadesChance = "50",
		ReplaceArmor = true,
		ReplaceWeapons = true,
	},
	'saved', 1711307741,
	'code_hash', 3802737038960330316,
	'affected_resources', {},
	'steam_id', "3148282483",
	'TagBalancing&Difficulty', true,
	'TagEnemies', true,
	'TagGameSettings', true,
	'TagWeapons&Items', true,
})