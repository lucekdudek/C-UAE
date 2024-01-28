LoadedModOptions = {
	ExtraHandgun = true,
	ExtraGrenadesCount = 2,
	ExtraGrenadesChance = 50,
	AllowAlternativeWeaponType = true,
	ArmamentStrengthFactor = 0,
	Debug = false,
}

AffiliationWeight = {
	Rebel = -1,
	Legion = -1,
	Thugs = -1,
	Army = 0,
	Adonis = 1,
	SuperSoldiers = 2,
	SiegfriedSuperSoldiers = 3,
}

DefaultCost = {
	Handgun = 500,
	SMG = 900,
	AssaultRifle = 1500,
	Sniper = 1100,
	Shotgun = 1000,
	MachineGun = 2000,
	FlareGun = 500,
	MeleeWeapon = 100,
	HeavyWeapon = 1200,
	Grenade = 150,
	Head = 0,
	Torso = 0,
	Legs = 0,
}

-- Position in table coresponds with a adjusted unit level 1...20
UnitLevelToComponentChance = { 1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 96, 97, 98, 99, 100, 100, 100, 100, 100 }

QuestItemsIcons = {
	["UI/Icons/Weapons/Auto5Quest"] = true,
	["UI/Icons/Weapons/Galil_Flaghill"] = true,
	["UI/Icons/Weapons/GoldenGun"] = true,
	["UI/Icons/Weapons/LionRoar"] = true,
	["UI/Icons/Weapons/MacheteChainsword"] = true,
	["UI/Icons/Weapons/TheThing"] = true,
	-- ["UI/Icons/Weapons/Winchester"] = true, Confidante(Winchester_Quest) icon
	["UI/Icons/Weapons/TexRevolver"] = true,
	["UI/Icons/Weapons/pierre_machete"] = true,
	["UI/Icons/Weapons/EndlessKnives"] = true,
	["UI/Icons/Weapons/GutHookKnife"] = true,
	["UI/Icons/Items/ivan_ushanka"] = true,
	["UI/Icons/Items/leather_jacket"] = true,
	["UI/Icons/Weapons/ShapedCharge"] = true,
}

ExcludeWeapons = {
	--Quest and personal
	'TheThing',
	'PierreMachete',
	'EndlessKnives',
	'GutHookKnife',
	'Galil_FlagHill',
	'LionRoar',
	'Auto5_quest',
	'TexRevolver',
	'GoldenGun',
	'Winchester_Quest',
	'Machete_Crafted',
	--Other
	'DebugAuto',
	--ToG duplicates and broken
	'M134_1',
	'M70D_1',
	'Condor_1',
	'M1Garand_2',
	'M1Garand_3',
	'M1Garand_4',
	'M1Garand_5',
	'Papovka2SKS_1',
	'Type56B_1',
	'Type56C_1',
	'Type56D_1',
	'Sturmgewehr44_Special',
	'G3A3Green_1',
	--ToG SuperRare
	-- 'B93R_1',
	-- 'MAC11_1',
	-- 'Spas12_1',
	-- 'G3_1',
	-- 'AN94_1',
	-- 'VSS_1',
	-- 'FG42_1',
	-- 'APS_1',
	-- 'RK95_1',
	-- 'SSG69_1',
	-- 'AWP_1',
	-- 'G11_1',
	-- 'WA2000_1',
	-- 'CAWS_1',
	-- 'PPSh41_1',
	-- 'RK62_1',
	--MeleeWeapon
	'Katana_1',
	'SKS_Bay_M_2',
	'SKS_Bay_M_3',
	'CrocodileJaws',
	'HyenaJaws',
	'Unarmed_Infected',
	'Unarmed',
	--Grenade
	'ConcussiveGrenade_Mine',
	'ShapedCharge',
	'Super_HE_Grenade',
	'RemoteC4',
	'RemotePETN',
	'RemoteTNT',
	'ProximityC4',
	'ProximityPETN',
	'ProximityTNT',
}
ExcludeArmors = {
	'FlakVest_Test',
	'ShamanLeggings',
	'ShamanHelmet',
	'ShamanTorso',
	'CrocodileHide',
	'NailsLeatherVest',
	'IvanUshanka',
	'Infected_HardenedSkin'
}
ExcludeAmmos = {}

-- Build on OnMsg.ModsReloaded
AllWeapons = {
	Handgun = {},
	SMG = {},
	AssaultRifle = {},
	Sniper = {},
	Shotgun = {},
	MachineGun = {},
	FlareGun = {},
	MeleeWeapon = {},
	HeavyWeapon = {},
	Grenade = {},
	Head = {},
	Torso = {},
	Legs = {},
}
