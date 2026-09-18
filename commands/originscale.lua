-- OriginScale
local sb_ir = require 'ir'
return {
	easing = true,
	time_points = 0,
	dimension = 5,
	args = nil,
	args_valid = nil,
	varargs = false,
	eval = function(t, easing, vector_a, vector_b, args, varargs)
		-- TODO
		return table.unpack(varargs)
	end,
}
