Cuae_LoadedModOptions = {
	ReplaceWeapons = true,
	ReplaceArmor = true,
	ExtraHandgun = true,
	ExtraGrenadesCount = 2,
	ExtraGrenadesChance = 50,
	AllowAlternativeWeaponType = true,
	ArmamentStrengthFactor = 0,
	Debug = false,
}

Cuae_AffiliationExclusionTable = {}

Cuae_ImmunityTable = {
	--Quest and personal
	TheThing = true,
	PierreMachete = true,
	EndlessKnives = true,
	GutHookKnife = true,
	Galil_FlagHill = true,
	LionRoar = true,
	Auto5_quest = true,
	TexRevolver = true,
	GoldenGun = true,
	Winchester_Quest = true,
	ShamanLeggings = true,
	ShamanHelmet = true,
	ShamanTorso = true,
	NailsLeatherVest = true,
	IvanUshanka = true,
	Machete_Crafted = true,
	ShapedCharge = true,
	-- Specific vanilla helmet
	PostApoHelmet = true,
	-- U-Bahn DLC
	Gasmaskenhelm = true,
}

Cuae_AffiliationWeight = {
	Rebel = -1,
	Legion = -1,
	Thugs = -1,
	Army = 0,
	Adonis = 1,
	SuperSoldiers = 2,
	SiegfriedSuperSoldiers = 3,
}

Cuae_DefaultCost = {
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
Cuae_UnitLevelToComponentChance = { 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 92, 94, 95, 96, 97, 98, 99 }

Cuae_ExcludeWeapons = {
	--ToG outdated/broken
	'MK23_1',
	'Fn2000_1',
	'B93R_1',
	'G3_1',
	--ToG duplicates
	'M1Garand_2',
	'M1Garand_3',
	'M1Garand_4',
	'M1Garand_5',
	'Papovka2SKS_1',
	'Type56B_1',
	'Type56C_1',
	'Type56D_1',
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

-- Build on OnMsg.ModsReloaded
Cuae_AllWeapons = {
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

Cuae_HeavyWeaponTypeToCaliber = {
	HeavyWeapon40mmGrenade = "40mmGrenade",
	HeavyWeaponWarhead = "Warhead",
	HeavyWeaponMortarShell = "MortarShell",
}

-- Build when selecting ammunition of a caliber for a first time
Cuae_AllAmmunition = {}
