TestCuea_DiscardAllLoadoutTable = {
  _default = {
    replacements = {
      	-- weapons
        Handgun = {discard=true},
        SMG = {discard=true},
        AssaultRifle = {discard=true},
        Sniper = {discard=true},
        Shotgun = {discard=true},
        MachineGun = {discard=true},
        FlareGun = {discard=true},
        MeleeWeapon = {discard=true},
        GrenadeLauncher = {discard=true},
        Mortar = {discard=true},
        MissileLauncher = {discard=true},
        -- utility
        Flare = {discard=true},
        Explosive = {discard=true},
        Flash = {discard=true},
        Fire = {discard=true},
        Smoke = {discard=true},
        Tear = {discard=true},
        Toxic = {discard=true},
        Timed = {discard=true},
        Proximity = {discard=true},
        Remote = {discard=true},
    }
  }
}

TestCuea_ExtraSetupLoadoutTable = {
  _default = {
    replacements = TestCuea_DiscardAllLoadoutTable._default.replacements,
    extraWeapons = {
      {type={{"AssaultRifle",100}}},
      {type={{"Handgun",100}, size=1}},
    },
    extraUtility = {
      {type={{"Flare",100}}, nightOnly=true, amount=2},
      {type={{"Fire",100}}, amount=3},
    }
  }
}

TestCuea_MarksmanKeepsSniperLoadoutTable = {
  _default = {
    replacements = TestCuea_DiscardAllLoadoutTable._default.replacements,
  },
  Marksman = {
    replacements = {
      Sniper = {discard=false}, -- the table has to be not falsy e.g. `{}`
    }
  }
}

TestCuea_RepalceWeaponsLoadoutTable = {
  _default = {
    replacements = {
      	-- weapons
        Handgun = {type={{"AssaultRifle",100}}},
        SMG = {type={{"AssaultRifle",100}}},
        AssaultRifle = {type={{"Sniper",100}}},
        Sniper = {type={{"AssaultRifle",100}}},
        Shotgun = {type={{"AssaultRifle",100}}},
        MachineGun = {type={{"AssaultRifle",100}}},
        FlareGun = {type={{"AssaultRifle",100}}},
        MeleeWeapon = {type={{"AssaultRifle",100}}},
        GrenadeLauncher = {type={{"AssaultRifle",100}}},
        Mortar = {type={{"AssaultRifle",100}}},
        MissileLauncher = {type={{"AssaultRifle",100}}},
        -- utility
        Flare = {type={{"Fire",100}}},
        Explosive = {type={{"Fire",100}}},
        Flash = {type={{"Fire",100}}},
        Fire = {type={{"Flash",100}}},
        Smoke = {type={{"Fire",100}}},
        Tear = {type={{"Fire",100}}},
        Toxic = {type={{"Fire",100}}},
        Timed = {type={{"Fire",100}}},
        Proximity = {type={{"Fire",100}}},
        Remote = {type={{"Fire",100}}},
    }
  }
}

TestCuea_APAmmonOnlyLoadoutTable = {
  _default = {
    excludeAmmoRarity={
      AmmoBasicColor = true,
      -- AmmoAPColor = false,
      AmmoHPColor = true,
      AmmoMatchColor = true,
      AmmoTracerColor = true,
    }
  }
}

TestCuea_100ComponentsLoadoutTable = {
  _default = {
    weaponComponentsCurve = {100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100}
  }
}

TestCuea_SimpleGBOLoadoutTable = {
  _default = {
    extraWeapons = {
      {type={{"Handgun",100}, size=1}},
    },
    extraUtility = {
      {type={{"Flare",100}}, nightOnly=1, amount=2},
      {type={{"Explosive",30}, {"Fire",70}, {"Timed",100}}, amount=2},
      {type={{"Flash",30}, {"Smoke",70}, {"Tear",100}}, amount=1},
    },
  }
}

TestCuea_ReplaceSizeDiffConflictLoadoutTable = {
  _default = {
    replacements = {
      Handgun = {type={{"AssaultRifle",100}}},
    }
  }
}

function TestCuea_GetSettings(weapons, components, armor, loadoutTable)
	return {
		ReplaceWeapons = not not weapons,
		AddWeaponComponents = not not components,
		ReplaceArmor = not not armor,
		LoadoutTables = {
			AIM = loadoutTable,
			Adonis = loadoutTable,
			Army = loadoutTable,
			Legion = loadoutTable,
			Militia = loadoutTable,
			Rebel = loadoutTable,
			SuperSoldiers = loadoutTable,
			Thugs = loadoutTable,
		},
		AffectMilitia = true,
		ArmamentStrengthFactor = 0,
		ApplyChangesInSateliteView = true,
		DisallowSilencers = true,
	}
end

-- Run in mod editor on a selected unit

-- CUAE_LOG_LEVEL = CUAE_DEBUG

-- Cuae_ChangeArmament(TestCuea_GetSettings(true, true, false, TestCuea_DiscardAllLoadoutTable), SelectedObj, 0)

-- Cuae_ChangeArmament(TestCuea_GetSettings(true, true, false, TestCuea_ExtraSetupLoadoutTable), SelectedObj, 0)

-- SelectedObj.role="Marksman"
-- Cuae_ChangeArmament(TestCuea_GetSettings(true, true, false, TestCuea_MarksmanKeepsSniperLoadoutTable), SelectedObj, 0)

-- SelectedObj.Affiliation = "Legion"
-- Cuae_ChangeArmament(TestCuea_GetSettings(false, false, false, TestCuea_RepalceWeaponsLoadoutTable), SelectedObj, 0)

-- Cuae_ChangeArmament(TestCuea_GetSettings(true, false, false, TestCuea_APAmmonOnlyLoadoutTable), SelectedObj, 0)

-- Cuae_ChangeArmament(TestCuea_GetSettings(true, true, false, TestCuea_100ComponentsLoadoutTable), SelectedObj, 0)

-- Cuae_ChangeArmament(TestCuea_GetSettings(true, true, false, TestCuea_SimpleGBOLoadoutTable), SelectedObj, 2)

-- Cuae_ChangeArmament(TestCuea_GetSettings(true, false, false, TestCuea_ReplaceSizeDiffConflictLoadoutTable), SelectedObj, 0)
-- Cuae_ChangeArmament(TestCuea_GetSettings(false, false, false, TestCuea_ReplaceSizeDiffConflictLoadoutTable), SelectedObj, 0)

-- Cuae_AddRandomComponents(settings, weapon, adjustedUnitLevel, weaponComponentsCurve, weaponComponentsPriority)
-- Cuae_AddRandomComponents({AddWeaponComponents=true}, SelectedObj:GetItemAtPos("Handheld A", 1, 1), 10, {100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100}, {tag="Precision", prioritySlots={"Scope"}})
