-- VectorRelative
return {
	easing = true,
	time_points = 2,
	dimension = 2,
	args = { "start_sx", "start_sy" }, -- start_sx and start_sy are
	                                   -- assigned a value when the command is being outputted
																  	 -- from an object and should never be manually changed.
	args_valid = { function(x) return x end, function(y) return y end },
	varargs = false,
	eval = nil,
	overlapping=true,
	absolute_equal="vector",
	overlap_operator='*',
	out = function(easing, t, vector_a, vector_b, args, varargs)
		sb.log:assert(args.start_sx, "vectorrel out(): no starting X scale. can't proceed.")
		sb.log:assert(args.start_sy, "vectorrel out(): no starting Y scale. can't proceed.")

		return sb.ir:new("V",easing,t[1],t[2],
			vector_a[1]+args.start_sx,vector_a[2]+args.start_sy,
			vector_b[1]+args.start_sx,vector_b[2]+args.start_sy)
	end
}
