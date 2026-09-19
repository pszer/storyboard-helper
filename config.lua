local sb_log = require 'log'

local config = {
	["silent"] = false,
	["ignore-large-time-points"] = false,
	["allow-no-leading-zeroes"] = false,
	["allow-non-linear-easing-overlaps"] = false,
	["no-overlap-checks"] = false,
	["ignore-version"] = false,

	["disable-easing-keyframing"] = false,
	["default-easing-keyframing-epsilon"] = 2.0,
	["default-easing-keyframing-interval"] = 1,

	["default-epsilon"] = 2.0,

	["project-folder"] = "."..package.config:sub(1,1),
}

function config:readFromArgs(...)
	local args = {}
	local i = 1

	while args[i] do
		local v = args[i]

		sb_log:assert(type(v)=="string", "config:readFromArgs(): expected string, got '%s'", type(v))
		v = v:lower()
		if v:byte(1)==v:byte('-') then
			v=v:sub(2)
		end

		local exists = rawget(config, v)~=nil
		sb_log:assert(exists, "config:readFromArgs(): unknown variable '%s'", v)

		local typeofv = type(rawget(config, v))

		if typeofv~="boolean" then
			i=i+1
			local w = args[i]
			sb_log:assert(w, "config:readFromArgs(): expected argument for '%s'", v)
			sb_log:assert(type(w)==typeofv, "config:readFromArgs(): expected '%s' for '%s', got '%s'", typeofv, v, type(w))
			rawset(config, v, w)
		else
			rawset(config, v, true)
		end
	end
end

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
		sb_log:error("config[]: unknown config variable '%s'", key_f)
	end

	sb_log:error("config[]: expected string, got '%s'", type(key))
end

return config
