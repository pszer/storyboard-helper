-- RotateRel
return {
	easing = true,
	time_points = 2,
	dimension = 1,
	args = { "start_angle" },
	args_valid = { function(x) return x end },
	varargs = false,
	eval = nil,
	overlapping=true,
	absolute_equal="rotate",
	overlap_operator='+',
	out = function(easing, t, vector_a, vector_b, args, varargs)
		sb_log:assert(args.start_angle, "rotaterel out(): no starting angle. can't proceed.")

		return sb_ir:new("R",easing,t[1],t[2],
			vector_a[1]+args.start_angle, vector_b[1]+args.start_angle)
	end
}
