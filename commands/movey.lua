-- MoveY
local sb_ir = require 'ir'
return {
	easing = true,
	time_points = 2,
	dimension = 1,
	args = nil,
	args_valid = nil,
	varargs = false,
	eval = nil,
	out = function(t, easing, vector_a, vector_b, args, varargs)
		return sb_ir:new("MY",easing,math.floor(t[1]),math.floor(t[2]),vector_a[1],vector_b[1])
	end
}
