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
	HeavyWeapon40mmGrenade = 1,
	HeavyWeaponWarhead = 1,
	HeavyWeaponMortarShell = 1,
	MissileLauncher = 1,
	GrenadeDay = 150,
	GrenadeNight = 150,
	Head = 0,
	Torso = 0,
	Legs = 0,
}

-- Position in table coresponds with a adjusted unit level 1...20
UnitLevelToComponentChance = { 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 92, 94, 95, 96, 97, 98, 99 }

-- Required to deduct if unit is one that should not be changed (e.g. Pierre)
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
	--ToG duplicates and broken
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

RailMounts = {
	'ToG_Rail_Block',
	'ToG_Rail_1',
	'AWP_rail_1',
	'L85A1_toprail_1',
	'FN2000_Toprail_1',
	'hk33_top_rail_1',
	'EM2_rail_1',
	'G11_Rail_1',
}

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
	HeavyWeapon40mmGrenade = {},
	HeavyWeaponWarhead = {},
	HeavyWeaponMortarShell = {},
	MissileLauncher = {},
	GrenadeDay = {},
	GrenadeNight = {},
	Head = {},
	Torso = {},
	Legs = {},
}

HeavyWeaponTypeToCaliber = {
	HeavyWeapon40mmGrenade = "40mmGrenade",
	HeavyWeaponWarhead = "Warhead",
	HeavyWeaponMortarShell = "MortarShell",
}

-- Build when selecting ammunition of a caliber for a first time
AllAmmunition = {}
