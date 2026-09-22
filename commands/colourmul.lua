-- ColourMul
return {
	easing = true,
	time_points = 2,
	dimension = 3,
	args = { "start_col_r", "start_col_g" , "start_col_b" }, -- start_x and start_y are
	                                                         -- assigned a value when the command is being outputted
								                									         -- from an object and should never be manually changed.
	args_valid = { function(x) return x end, function(y) return y end, function(z) return z end },
	varargs = false,
	eval = nil,
	overlapping=true,
	overlap_operator='*',
	absolute_equal='colour',
	out = function(easing, t, vector_a, vector_b, args, varargs)
		sb_log:assert(args.start_x, "colourmul out(): no starting R. can't proceed.")
		sb_log:assert(args.start_y, "colourmul out(): no starting G. can't proceed.")
		sb_log:assert(args.start_z, "colourmul out(): no starting B. can't proceed.")

		return sb_ir:new("C",easing,t[1],t[2],
			vector_a[1]*args.start_col_r,vector_a[2]*args.start_col_r,
			vector_b[1]*args.start_col_g,vector_b[2]*args.start_col_g,
			vector_b[1]*args.start_col_b,vector_b[2]*args.start_col_b)
	end
}
