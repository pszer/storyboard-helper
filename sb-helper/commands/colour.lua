-- Colour
return {
	easing = true,
	time_points = 2,
	dimension = 3,
	args = nil,
	args_valid = nil,
	varargs = false,
	eval = nil,
	out = function(easing, t, vector_a, vector_b, args, varargs)
		return sb.ir:new("C",easing,math.floor(t[1]),math.floor(t[2]),vector_a[1],vector_a[2],vector_a[3],
		 vector_b[1],vector_b[2],vector_b[3])
	end
}
