-- exclusionTable = {
-- 	affiliation = {"armamentId", "armamentId", "armamentId"}
-- 	affiliation = {"armamentId", "armamentId", "armamentId"}
-- }
-- CUAEAddExclusionTable(exclusionTable)
function CUAEAddExclusionTable(exclusionTable)
	for affiliation, armamentIds in pairs(exclusionTable) do
		for _, armamentId in ipairs(armamentIds) do
			AffiliationExclusionTable[affiliation] = AffiliationExclusionTable[affiliation] or {}
			AffiliationExclusionTable[affiliation][armamentId] = true
		end
	end
end

-- immunityTable = { "armamentId", "armamentId", "armamentId" }
-- CUAEAddImmunityTable(immunityTable)
function CUAEAddImmunityTable(immunityTable)
	for _, armamentId in ipairs(immunityTable) do
		ImmunityTable[armamentId] = true
	end
end
