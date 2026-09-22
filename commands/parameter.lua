-- Parameter
local sb_log = require 'log'
local sb_ir = require 'ir'
return {
	easing = false, -- easing on paramter does nothing in .osb, 
	time_points = 2,
	dimension = 0,
	args = {"value"},
	args_valid = {
		function(X)
			local x=X:lower()
			if x=="a"or x=="h"or x=="v"
				then return x end
			sb_log:error("invalid ['value'] for parameter command: '%s'. expected 'a','h' or 'v'",X)
			return nil
		end
	},
	varargs = false,
	eval = nil,
	out = function(t, easing, vector_a, vector_b, args, varargs)
		return sb_ir:new("P",0,math.floor(t[1]),math.floor(t[2]),args["value"]:upper())
	end
}
