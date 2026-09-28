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
		local function clamp(a)
			if a < 0 then return 0 end
			if a > 255 then return 255 end
			return math.floor(a)
		end

		return sb.ir:new("C",easing,sb.ir:floorTime(t[1]),sb.ir:floorTime(t[2]),
		 clamp(vector_a[1]),clamp(vector_a[2]),clamp(vector_a[3]),
		 clamp(vector_b[1]),clamp(vector_b[2]),clamp(vector_b[3]))
	end
}
