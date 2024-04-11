Cuae_LoadedModOptions = {
	-- visible options
	ReplaceWeapons = true,
	AddWeaponComponents = true,
	ReplaceArmor = true,
	ExtraGrenadesChance = 50,
	ArmamentStrengthFactor = 0,
	-- hidden options
	DisallowSilencers = true,
	ExtraHandgun = false,
	ExtraGrenadesCount = 3,
	AlternativeWeaponTypeTables = nil,
	ApplyChangesInSateliteView = true,
	Debug = false,
}

Cuae_ForcedOptions = {}

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
	--Task-oriented head pieces
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
Cuae_UnitLevelToComponentChance = { 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 92, 94, 95, 96, 97, 98, 99 }

Cuae_ExcludeWeapons = {
	--ToG OP
	'Katana_1',
	--ToG outdated/broken
	'MK23_1',
	'Fn2000_1',
	'B93R_1',
	'G3_1',
	--Grenade
	'ConcussiveGrenade_Mine',
	'ShapedCharge',
	'Super_HE_Grenade',
	'RemoteC4',
	'RemotePETN',
	'RemoteTNT',
	--Task-oriented head pieces
	'GasMask',
	'NightVisionGoggles',
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
