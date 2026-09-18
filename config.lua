local sb_log = require 'log'

local config = {
	["silent"] = false,
	["ignore-large-time-points"] = false,
	["allow-no-leading-zeroes"] = false,
	["allow-non-linear-easing-overlaps"] = false,
	["no-overlap-checks"] = false,
	["ignore-version"] = false,
}

local config_mt = {}
config_mt.__index = function(t, key)
	if type(key) == "string" then
		local key_f = key:lower()
		if key_f:sub(1,1)=="-" then
			key_f = key_f:sub(2,-1)
		end
		local result = rawget(t, key)
		if result then return result end
		if key_f ~= key then
			key_f = key_f.."' '("..key..")"
		end
		sb_log:error(string.format("config[]: unknown config variable '%s'", key_f))
	end

	sb_log:error(string.format("config[]: expected string, got '%s'", type(key)))
end

return config
