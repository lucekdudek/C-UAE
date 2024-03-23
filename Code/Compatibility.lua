function CUAEAddExclusionTable(exclusionTable)
	for affiliation, armamentIds in pairs(exclusionTable) do
		for _, armamentId in ipairs(armamentIds) do
			Cuae_AffiliationExclusionTable[affiliation] = Cuae_AffiliationExclusionTable[affiliation] or {}
			Cuae_AffiliationExclusionTable[affiliation][armamentId] = true
		end
	end
end

function CUAEAddImmunityTable(immunityTable)
	for _, armamentId in ipairs(immunityTable) do
		Cuae_ImmunityTable[armamentId] = true
	end
end

function CUAEForceSettings(settings)
	for setting, value in pairs(settings) do
		Cuae_ForcedOptions[setting] = value
	end
	CUAE_ApplyModOptions()
end
