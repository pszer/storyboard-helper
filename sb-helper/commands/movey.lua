-- MoveY
return {
	easing = true,
	time_points = 2,
	dimension = 1,
	args = nil,
	args_valid = nil,
	varargs = false,
	eval = nil,
	out = function(easing, t, vector_a, vector_b, args, varargs)
		return sb.ir:new("MY",easing,sb.ir:floorTime(t[1]),sb.ir:floorTime(t[2]),vector_a[1],vector_b[1])
	end
}
