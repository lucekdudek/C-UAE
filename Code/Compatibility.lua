-- exclusionTable = {
-- 	affiliation = {"armamentId", "armamentId", "armamentId"}
-- 	affiliation = {"armamentId", "armamentId", "armamentId"}
-- }
-- CUAEAddExclusionTable(exclusionTable)
function CUAEAddExclusionTable(exclusionTable)
	for affiliation, armamentIds in pairs(exclusionTable) do
		for _, armamentId in ipairs(armamentIds) do
			Cuae_AffiliationExclusionTable[affiliation] = Cuae_AffiliationExclusionTable[affiliation] or {}
			Cuae_AffiliationExclusionTable[affiliation][armamentId] = true
		end
	end
end

-- immunityTable = { "armamentId", "armamentId", "armamentId" }
-- CUAEAddImmunityTable(immunityTable)
function CUAEAddImmunityTable(immunityTable)
	for _, armamentId in ipairs(immunityTable) do
		Cuae_ImmunityTable[armamentId] = true
	end
end

-- local settings = {
-- 	ReplaceWeapons = true,
-- 	AddWeaponComponents = true,
-- 	DisallowSilencers = true,
-- 	ReplaceArmor = true,
-- 	ExtraHandgun = true,
-- 	ExtraGrenadesCount = 2,
-- 	ExtraGrenadesChance = 50,
-- 	AllowAlternativeWeaponType = true,
-- 	ArmamentStrengthFactor = 0,
-- 	ApplyChangesInSateliteView = true,
-- }
-- CUAEForceSettings(settings)
function CUAEForceSettings(settings)
	for setting, value in pairs(settings) do
		Cuae_ForcedOptions[setting] = value
	end
	CUAE_ApplyModOptions()
end


