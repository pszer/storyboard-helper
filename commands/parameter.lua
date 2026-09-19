-- Parameter
local sb_log = require 'log'
return {
	easing = true,
	time_points = 2,
	dimension = 0,
	args = {"value"},
	args_valid = {
		function(X)
			local x=X:upper()
			if x=="A"or x=="H"or x=="H"
				then return x end
			sb_log:error("Invalid ['value'] for Parameter command '%s'.",X)
			return nil
		end
	},
	varargs = false,
	eval = nil,
	out = function(t, easing, vector_a, vector_b, args, varargs)
		return sb_ir:new("P",easing,math.floor(t[1]),math.floor(t[2]),args["value"])
	end
}
