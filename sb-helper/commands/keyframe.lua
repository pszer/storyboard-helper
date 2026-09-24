-- Root
return {
	easing = false,
	time_points = 0,
	dimension = 0,


	-- arguments
	--
	-- action        - the command being keyframed (example: 'moverel')
	-- epsilon       - the higher, the more simplified the resulting frames
	--            are. when dealing with co-ordinates, each epsilon is
	--            equal to a pixel unit amount of maximum deviation.
	--            default is 2.0, can be configured in config["default-epsilon"]
	--
	-- varargs       - list of keyframes, each one is of the format {time, v1, v2, v3, ...}
	--            where v{n} are the n-th component of the vector data.
	--
	--            instead of a list, the keyframe command can accept a function over time,
	--            with which to sample the desired motion. this requires configuring the
	--            follow commands below.
	--
	--            span/interval/absolute_time are for when keyframing
	--            a function over time, instead of passing keyframe values directly.
	--
	-- span          - the span of time {start, end} to keyframe.
	-- interval      - how spaced out the sampled keyframe are in time, by default it's 1
	--                 which mean every millisecond gets sampled. has to be greater than or equal to 1.
	-- absolute_time - flag to pass in the absolute time to the function ranging from [start, end].
	--                 by default the function is sampled with time relative to the start, from [0, end-start].

	args = { "action", "epsilon", "span", "interval", "absolute_time" },
	args_valid = {

		function(x)
			local com = require 'commands'
			sb.log:assert(com[x], "invalid ['action'] for keyframe command: %s", x)
			return false
		end,
		function(x)
			return false
		end,
		function(x)
			return false
		end,
		function(x)
			return x 
		end,
		function(y)
			return y
		end
	},
	varargs = true,
	eval = function(easing, t, vector_a, vector_b, args, varargs)
		--TODO
		local time, dim = sb.verify:sortedTimes(varargs)
		local movers = sb.verify:resolveTransformOverlaps(time, dim, "moverel")

		return sb.unpack(movers)
	end,
}
