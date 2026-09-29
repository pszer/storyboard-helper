-- MoveRelative
return {
	easing = true,
	time_points = 2,
	dimension = 2,
	args = { "start_x", "start_y" }, -- start_x and start_y are
	                                 -- assigned a value when the command is being outputted
																	 -- from an object and should never be manually changed.
	args_valid = { function(x) return x end, function(y) return y end },
	varargs = false,
	eval = nil,
	overlapping=true,
	overlap_operator='+',
	absolute_equal='move',
	out = function(easing, t, vector_a, vector_b, args, varargs)
		sb.log:assert(args.start_x, "moverel out(): no starting X co-ordinate. can't proceed.")
		sb.log:assert(args.start_y, "moverel out(): no starting Y co-ordinate. can't proceed.")

		return sb.ir:new("M",easing,t[1],t[2],
			vector_a[1]+args.start_x,vector_a[2]+args.start_y,
			vector_b[1]+args.start_x,vector_b[2]+args.start_y)
	end
}
