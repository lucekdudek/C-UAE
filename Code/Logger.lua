CUAE_DEBUG = 10
CUAE_INFO = 20
CUAE_WARN = 30
CUAE_ERROR = 40
CUAE_LOG_LEVEL = CUAE_INFO

local logLevels = {
	D = CUAE_DEBUG,
	I = CUAE_INFO,
	W = CUAE_WARN,
	E = CUAE_ERROR,
}

local logLevelsT = {
	D = "DEBUG",
	I = "INFO ",
	W = "WARN ",
	E = "ERROR",
}

function Cuae_L(level, ...)
	if logLevels[level] >= CUAE_LOG_LEVEL then
		print("CUAE", logLevelsT[level], "|", ...)
	end
end
