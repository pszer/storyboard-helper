-- FlipH
return {
	easing = false,
	time_points = 2,
	dimension = 0,
	args = nil,
	args_valid = nil,
	varargs = false,
	eval = function(easing, t, vector_a, vector_b, args, varargs)
		return {'param', t, value="H"}
	end,
}
