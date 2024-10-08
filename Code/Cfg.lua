Cuae_LoadedModOptions = {
	-- visible options
	ReplaceWeapons = true,
	AddWeaponComponents = true,
	ReplaceArmor = true,
	AffectMilitia = true,
	ExtraGrenadesChance = 50,
	ArmamentStrengthFactor = 0,
	Debug = false,
	-- hidden options
	DisallowSilencers = true,
	ExtraHandgun = false,
	ExtraGrenadesCount = 3,
	AlternativeWeaponTypeTables = nil,
	ApplyChangesInSateliteView = true,
	-- top secret options
	DropGrenades = true,
	AlwaysAddArmor = false,
	UseRandomGrenadeAsCqb = false
}

Cuae_ForcedOptions = {}

Cuae_AffiliationExclusionTable = {}

Cuae_ImmunityTable = {
	-- Quest and personal
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
	-- Task-oriented head pieces
	GasMask = true,
	NightVisionGoggles = true,
}

Cuae_AffiliationWeight = {
	Rebel = 0,
	Legion = -1,
	Thugs = 0,
	Army = 0,
	Adonis = 1,
	SuperSoldiers = 0,
	Militia = 1,
}

-- Position in table coresponds with a adjusted unit level 1...20
Cuae_UnitLevelToComponentChance = {
	18,
	24,
	30,
	36,
	42,
	48,
	54,
	60,
	66,
	72,
	78,
	84,
	90,
	92,
	94,
	95,
	96,
	97,
	98,
	99,
}

Cuae_ExcludeWeapons = {
	-- ToG OP
	"Katana_1",
	-- ToG outdated/broken
	"MK23_1",
	"Fn2000_1",
	"B93R_1",
	"G3_1",
	-- Grenade
	"ConcussiveGrenade_Mine",
	"ShapedCharge",
	"Super_HE_Grenade",
	"RemoteC4",
	"RemotePETN",
	"RemoteTNT",
	-- Task-oriented head pieces
	"GasMask",
	"NightVisionGoggles",
}

Cuae_Whitelist = {
	-- ToG
	-- Handgun
	"Mauser_C96_1",
	"C96R_1",
	-- SMG
	"PPSh41_1",
	-- AR
	"AR10_worn",
	"AR10commando_worn",
	"G3A3_1",
	"M70D_1",
	"STG44R_1",
	-- Sniper
	"Gewehr43_1",
	"M1Garand_5",
	"SKS_1",
	"Type56C_1",
	"Type56D_1",
	-- MachineGun
	"BrenMKI_1",
	"HK23ECamo_1",
	"M1918A2_1",
	"Mac24_1",
	"U100C_1",
	-- More Armor
	"CamoFlakArmor",
	"CamoFlakArmor_CeramicPlates",
	"CamoFlakArmor_WeavePadding",
	"CamoFlakVest_CeramicPlates",
	"CamoFlakVest_WeavePadding",
	"CamoKevlarChestplate",
	"CamoKevlarChestplate_CeramicPlates",
	"CamoKevlarChestplate_WeavePadding",
	"CamoKevlarVest_CeramicPlates",
	"CamoKevlarVest_WeavePadding",
	"RedCamoFlakArmor",
	"RedCamoFlakArmor_CeramicPlates",
	"RedCamoFlakArmor_WeavePadding",
	"RedCamoFlakVest",
	"RedCamoFlakVest_CeramicPlates",
	"RedCamoFlakVest_WeavePadding",
	"RedCamoKevlarChestplate",
	"RedCamoKevlarChestplate_CeramicPlates",
	"RedCamoKevlarChestplate_WeavePadding",
	"RedCamoKevlarVest",
	"RedCamoKevlarVest_CeramicPlates",
	"RedCamoKevlarVest_WeavePadding",
	"RedFlakArmor",
	"RedFlakArmor_CeramicPlates",
	"RedFlakArmor_WeavePadding",
	"RedFlakLeggings",
	"RedFlakLeggings_WeavePadding",
	"RedFlakVest",
	"RedFlakVest_CeramicPlates",
	"RedFlakVest_WeavePadding",
	"RedHeavyArmorChestplate",
	"RedHeavyArmorChestplate_CeramicPlates",
	"RedHeavyArmorChestplate_WeavePadding",
	"RedHeavyArmorHelmet",
	"RedHeavyArmorHelmet_WeavePadding",
	"RedHeavyArmorLeggings",
	"RedHeavyArmorLeggings_WeavePadding",
	"RedHeavyArmorTorso",
	"RedHeavyArmorTorso_CeramicPlates",
	"RedHeavyArmorTorso_WeavePadding",
	"RedKevlarChestplate",
	"RedKevlarChestplate_CeramicPlates",
	"RedKevlarChestplate_WeavePadding",
	"RedKevlarHelmet",
	"RedKevlarHelmet_WeavePadding",
	"RedKevlarLeggings",
	"RedKevlarLeggings_WeavePadding",
	"RedKevlarVest",
	"RedKevlarVest_CeramicPlates",
	"RedKevlarVest_WeavePadding",
	"RedLightHelmet",
	"RedLightHelmet_WeavePadding",
	"YellowFlakArmor",
	"YellowFlakArmor_CeramicPlates",
	"YellowFlakArmor_WeavePadding",
	"YellowFlakLeggings",
	"YellowFlakLeggings_WeavePadding",
	"YellowFlakVest",
	"YellowFlakVest_CeramicPlates",
	"YellowFlakVest_WeavePadding",
	"YellowHeavyArmorChestplate",
	"YellowHeavyArmorChestplate_CeramicPlates",
	"YellowHeavyArmorChestplate_WeavePadding",
	"YellowHeavyArmorHelmet",
	"YellowHeavyArmorHelmet_WeavePadding",
	"YellowHeavyArmorLeggings",
	"YellowHeavyArmorLeggings_WeavePadding",
	"YellowHeavyArmorTorso",
	"YellowHeavyArmorTorso_CeramicPlates",
	"YellowHeavyArmorTorso_WeavePadding",
	"YellowKevlarChestplate",
	"YellowKevlarChestplate_CeramicPlates",
	"YellowKevlarChestplate_WeavePadding",
	"YellowKevlarHelmet",
	"YellowKevlarHelmet_WeavePadding",
	"YellowKevlarLeggings",
	"YellowKevlarLeggings_WeavePadding",
	"YellowKevlarVest",
	"YellowKevlarVest_CeramicPlates",
	"YellowKevlarVest_WeavePadding",
	"YellowLightHelmet",
	"YellowLightHelmet_WeavePadding",
}

Cuae_ExcludeComponents = {
	-- ToG shotguns range
	BarrelLongShotgun = true,
	M1897_barrel_ext = true,
	Auto5_Long_LMag = true,
	Auto5_Long_NMag = true,
	Caws_Barrel_long_1 = true,
	FP6_Barrel_ext_1 = true,
	Spas12_Barrel_ext_1 = true,
	CondorN_Barrel_ext_1 = true,
	Condor_Barrel_ext_1 = true,
}

function Cuae_ExcludeComponents_DisallowSilencers()
	Cuae_ExcludeComponents.ImprovisedSuppressor = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.ImprovisedSuppressor_Anaconda = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.Suppressor = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.Suppressor_Anaconda = Cuae_LoadedModOptions.DisallowSilencers
	-- ToG
	Cuae_ExcludeComponents.FN2000_silencer_1 = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.ToG_Shotgun_Silencer = Cuae_LoadedModOptions.DisallowSilencers
	-- MoW
	Cuae_ExcludeComponents.MoW_Muz_Obs9 = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.MoW_Muz_Obs9s = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.MoW_Muz_Rev9 = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.MoW_Muz_Rev45 = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.MoW_Muz_Omega9 = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.MoW_Muz_N4 = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.MoW_Muz_Spectre = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.MoW_Muz_RotexIII = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.MoW_Muz_SR25 = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.MoW_Muz_MP9 = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.MoW_Muz_Vector = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.MoW_Muz_Phantom = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.MoW_Muz_TGPA = Cuae_LoadedModOptions.DisallowSilencers
	Cuae_ExcludeComponents.MoW_Muz_PBS1 = Cuae_LoadedModOptions.DisallowSilencers
	-- rato
	Cuae_ExcludeComponents.RAT_TOG_suppressor = Cuae_LoadedModOptions.DisallowSilencers
end

Cuae_ExcludeComponents_DisallowSilencers()

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
	Grenade = {},
	Head = {},
	Torso = {},
	Legs = {},
}
Cuae_HeadTypes = {
	"LHead",
	"MHead",
	"HHead",
}
Cuae_TorsoTypes = {
	"LVest",
	"MVest",
	"HVest",
	"LPlate",
	"MPlate",
	"HPlate",
}
Cuae_LegsTypes = {
	"LLegs",
	"MLegs",
	"HLegs",
}
Cuae_AllArmor = {
	Head = {},
	Torso = {},
	Legs = {},
}

Cuae_GrenadeTypes = {
	"Grenade",
	"GrenadeSmoke",
	"GrenadeTrap",
	"GrenadeNight",
	"GrenadeHe",
	"GrenadeUtil",
}
Cuae_GrenadeSubTypes = {
	"GrenadeSmoke",
	"GrenadeTrap",
	"GrenadeHe",
	"GrenadeUtil",
}
Cuae_GrenadeNightSubType = "GrenadeNight"

Cuae_AllGrenade = {}

Cuae_CQBTypes = {
	"MeleeWeapon",
	"Handgun",
	"SMG",
	"Shotgun",
}

Cuae_DefaultSmallWeapons = {
	Handgun = "HiPower",
	SMG = "UZI",
	AssaultRifle = "UZI",
	Sniper = "UZI",
	Shotgun = "UZI",
	MachineGun = "UZI",
	FlareGun = "FlareHandgun",
	MeleeWeapon = "Knife",
	HeavyWeapon40mmGrenade = "UZI",
	HeavyWeaponWarhead = "UZI",
	HeavyWeaponMortarShell = "UZI",
	MissileLauncher = "UZI",
}

Cuae_DefaultWeapons = {
	Rebel = {
		Handgun = "HiPower",
		SMG = "UZI",
		AssaultRifle = "AK47",
		Sniper = "DragunovSVD",
		Shotgun = "DoubleBarrelShotgun",
		MachineGun = "RPK74",
		FlareGun = "FlareHandgun",
		MeleeWeapon = "Knife",
		HeavyWeapon40mmGrenade = "MGL",
		HeavyWeaponWarhead = "RPG7",
		HeavyWeaponMortarShell = "MortarInventoryItem",
		MissileLauncher = "RPG7",
	},
	Legion = {
		Handgun = "HiPower",
		SMG = "MP40",
		AssaultRifle = "AK47",
		Sniper = "Gewehr98",
		Shotgun = "DoubleBarrelShotgun",
		MachineGun = "MG42",
		FlareGun = "FlareHandgun",
		MeleeWeapon = "Knife",
		HeavyWeapon40mmGrenade = "MGL",
		HeavyWeaponWarhead = "RPG7",
		HeavyWeaponMortarShell = "MortarInventoryItem",
		MissileLauncher = "RPG7",
	},
	Thugs = {
		Handgun = "HiPower",
		SMG = "UZI",
		AssaultRifle = "AK47",
		Sniper = "Gewehr98",
		Shotgun = "DoubleBarrelShotgun",
		MachineGun = "RPK74",
		FlareGun = "FlareHandgun",
		MeleeWeapon = "Knife",
		HeavyWeapon40mmGrenade = "MGL",
		HeavyWeaponWarhead = "RPG7",
		HeavyWeaponMortarShell = "MortarInventoryItem",
		MissileLauncher = "RPG7",
	},
	Army = {
		Handgun = "Glock18",
		SMG = "UZI",
		AssaultRifle = "FNFAL",
		Sniper = "M24Sniper",
		Shotgun = "M41Shotgun",
		MachineGun = "FNMinimi",
		FlareGun = "FlareHandgun",
		MeleeWeapon = "Knife_Sharpened",
		HeavyWeapon40mmGrenade = "MGL",
		HeavyWeaponWarhead = "RPG7",
		HeavyWeaponMortarShell = "MortarInventoryItem",
		MissileLauncher = "RPG7",
	},
	Adonis = {
		Handgun = "ColtAnaconda",
		SMG = "MP5",
		AssaultRifle = "AR15",
		Sniper = "M24Sniper",
		Shotgun = "M41Shotgun",
		MachineGun = "HK21",
		FlareGun = "FlareHandgun",
		MeleeWeapon = "Knife_Sharpened",
		HeavyWeapon40mmGrenade = "MGL",
		HeavyWeaponWarhead = "RPG7",
		HeavyWeaponMortarShell = "MortarInventoryItem",
		MissileLauncher = "RPG7",
	},
	SuperSoldiers = {
		Handgun = "Bereta92",
		SMG = "MP5",
		AssaultRifle = "FNFAL",
		Sniper = "M24Sniper",
		Shotgun = "M41Shotgun",
		MachineGun = "HK21",
		FlareGun = "FlareHandgun",
		MeleeWeapon = "Knife_Sharpened",
		HeavyWeapon40mmGrenade = "MGL",
		HeavyWeaponWarhead = "RPG7",
		HeavyWeaponMortarShell = "MortarInventoryItem",
		MissileLauncher = "RPG7",
	},
	Militia = {
		Handgun = "HiPower",
		SMG = "UZI",
		AssaultRifle = "FAMAS",
		Sniper = "DragunovSVD",
		Shotgun = "Auto5",
		MachineGun = "RPK74",
		FlareGun = "FlareHandgun",
		MeleeWeapon = "Knife",
		HeavyWeapon40mmGrenade = "MGL",
		HeavyWeaponWarhead = "RPG7",
		HeavyWeaponMortarShell = "MortarInventoryItem",
		MissileLauncher = "RPG7",
	},
}

Cuae_HeavyWeaponTypeToCaliber = {
	HeavyWeapon40mmGrenade = "40mmGrenade",
	HeavyWeaponWarhead = "Warhead",
	HeavyWeaponMortarShell = "MortarShell",
}

-- Build when selecting ammunition of a caliber for a first time
Cuae_AllAmmunition = {}
