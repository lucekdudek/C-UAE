--[[
LOADOUT CONFIGURATION SCHEMA
=================================
Configures combat equipment progression for faction units based on their role and experience level.

Hierarchy Structure:
LoadoutTables → Affiliation → Role → Configuration Parameters

Core Concepts:
----------------
• Affiliations:    Military factions (Rebel, Legion, Thugs, Army, Adonis, SuperSoldiers, Militia)
• Roles:           Combat specialties (Soldier, Heavy, Artillery, Recon, Medic, Marksman, Commander, Stormer, Demolitions, Beast)
• Component Curve: Progressive attachment unlocks based on adjusted unit level (1-20)
• Component Tags:  Tags (Intimate CloseQuarters Tactical Precision Strategic)
• Ammo Hierarchy:  Rarity tiers (AmmoBasicColor < AmmoAPColor < AmmoHPColor < AmmoMatchColor < AmmoTracerColor)
• Weapons:         Firearms and melee weapons types (Handgun SMG AssaultRifle Sniper Shotgun MachineGun FlareGun MeleeWeapon GrenadeLauncher Mortar MissileLauncher)
• Utility:         Grenades and others types (Flare Explosive Flash Fire Smoke Tear Toxic Timed Proximity Remote)
--]]

LoadoutTables = {
  --[[ AFFILIATION CONFIGURATION ------------------------------------------------------------
  Contains role-specific configurations for factions.
  Key Format:  Affiliation name from valid faction list
  Fallback:    Uses '_default' configuration for unspecified roles
  --]]
  Affiliation = {
    --[[ ROLE-SPECIFIC CONFIGURATION ---------------------------------------------------------
    Defines equipment rules for specific unit roles.
    Key Format:  Unit role from standard role list
    --]]
    Role = {
      --[[ WEAPON COMPONENT PROGRESSION SYSTEM -----------------------------------------------
      Progressive attachment unlocks based on unit level (1-20)
      
      Mechanics:
      - Array indexes correspond to unit levels 1-20
      - Values represent percentage of components to activate
      - Calculation: floor((percentage/100 * total_slots) + 0.5)
      - Example: Level 5 unit with 6-slot weapon → 42% of 6 = 2.52 → 3 components active
      --]]
      weaponComponentsCurve = {18,24,30,36,42,48,54,60,66,72,78,84,90,92,94,95,96,97,98,99},

      --[[ WEAPON COMPONENT PRIORITIES SYSTEM -----------------------------------------------
      Configuration Options:
      • tag:str              - Limits available components to only containing given tag
      • prioritySlots:{...}  - Which slots to fill first
      --]]
      weaponComponentsPriorities = {
        Handgun = {tag="CloseQuarters", prioritySlots={"Magazine", "Side"}},
        SMG = {tag="CloseQuarters", prioritySlots={"Stock", "Muzzle"}},
        AssaultRifle = {tag="Tactical", prioritySlots={"Handguard", "Under"}},
        Sniper = {tag="Precision", prioritySlots={"Mount", "Scope"}},
        Shotgun = {tag="Intimate", prioritySlots={"Barrel"}},
        MachineGun = {tag="Precision", prioritySlots={"Bipod"}},
      },

      --[[ AMMO TYPE BLACKLIST ---------------------------------------------------------------
      Restrict specific ammunition types from appearing in loadouts
      
      Format:
      [AmmoType] = boolean
      - true: Completely exclude this ammo type
      - false/omit: Allow with normal rarity distribution
      --]]
      excludeAmmoRarity = {
        AmmoBasicColor = true,   -- Block common ammunition
        AmmoAPColor = true,      -- Block armor-piercing rounds
        AmmoHPColor = true,      -- Block hollow-point ammunition
        AmmoMatchColor = false,  -- Permit match-grade ammo
        -- AmmoTracerColor = false, -- Enable tracer rounds by not including
      },

      --[[ WEAPON REPLACEMENT STRATEGY -------------------------------------------------------
      Override default weapon distribution with specialized rules
      
      Configuration Options:
      • discard:true    - Remove all weapons of this type
      • type:{...}      - Weighted replacement options
      • size:N          - Maximum allowed weapon size
      
      Replacement Logic:
      - Undefined categories use default type-to-type replacement
      - Weight values are cumulative (see examples)
      --]]
      replacements = {
        -- Sniper Configuration (inherits defaults if not overridden)
        Sniper = {},  -- Warning falsy table can be overwritten by `_default`

        -- Assault Rifle Upgrade Path
        AssaultRifle = {
          type = {{"Sniper", 100}},  -- Replace all ARs with sniper rifles
        },

        -- SMG Size Restriction
        SMG = {
          type = {{"SMG", 100}},  -- Maintain SMG type but limit size
          size = 1  -- Only compact SMGs (UZI-class)
        },
        
        -- Shotgun Removal
        Shotgun = {discard = true},  -- Eliminate all shotguns
        
        -- Handgun Replacement Strategy
        Handgun = {
          type = {
            {"MeleeWeapon", 50},   -- 50% chance (1 - 50)
            {"Handgun", 100}       -- 50% chance (51 - 100)
          },
        },
      },

      --[[ AUXILIARY WEAPON SYSTEMS ----------------------------------------------------------
      Additional weapons added to standard loadouts
      
      Weapon Group Structure:
      • type    - Weighted weapon type selection
      • size    - Maximum allowable weapon size (default=2)
      --]]
      extraWeapons = {
        { -- Primary Secondary Weapon
          type = {
            {"SMG", 50},         -- 50% probability (50/150)
            {"Shotgun", 80},     -- 30% probability (80-50)
            {"AssaultRifle", 100}-- 20% probability (100-80)
          },
          -- size = 2  -- Implicit default
        },
        { -- Sidearm Supplement
          type = {{"Handgun", 75}}  -- 75% chance for additional handgun
        },
      },

      --[[ TACTICAL EQUIPMENT PROVISIONS -----------------------------------------------------
      Specialized grenades and combat utilities
      
      Utility Group Rules:
      • type      - Weighted utility type selection
      • amount    - Number of items added
      • nightOnly - Restrict to nighttime/underground missions
      --]]
      extraUtility = {
        { -- Night Combat Package
          type = {{"Flare", 75}},  -- High probability illumination
          nightOnly = true,        -- Night/underground exclusive
          amount = 2               -- Two flare devices
        },
        { -- General Purpose Grenades
          type = {
            {"Smoke", 50},     -- 50% screening smoke
            {"Explosive", 100} -- 50% fragmentation
          },
          amount = 3  -- Three grenades total
        }
      }
    },

    --[[ DEFAULT ROLE TEMPLATE ---------------------------------------------------------------
    Baseline configuration for unspecified roles. Merges with role-specific configurations.
    
    Important Notes:
    - Replacement rules combine with role-specific configurations
    - To block inheritance for specific weapon types:
      {WeaponType = {discard = false}} - Empty configuration
    --]]
    _default = {
      -- ... identical structure to Role configurations ...
    }
  }
}
