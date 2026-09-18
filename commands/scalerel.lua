-- ScaleRelative
return {
	easing = true,
	time_points = 2,
	dimension = 1,
	args = { "start_scale" },
	args_valid = { function(sx) return sx end },
	varargs = false,
	eval = nil,
	overlapping=true,
	absolute_equal="scale",
	out = function(t, easing, vector_a, vector_b, args, varargs)
		local sb_log = require 'log'
		local sb_ir  = require 'ir'
		sb_log:assert(args.start_scale, "scalerel out(): no starting X scale. can't proceed.")

		return sb_ir:new("S",easing,t[1],t[2],
			vector_a[1]+args.start_scale,vector_b[1]+args.start_scale)
	end
}
