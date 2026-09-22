-- Protract
--
-- extends the end time point for the commands passed into 'protract'
-- to the argument 'span_end'.
-- 'span_end' is set to the maximum time point of all commands inside
-- an evaluated block,
--
-- in practice this is used to create toggles for the flip/additive-blend
-- parameters for a sprite.
-- the command:
-- {'protract', {'parameter' { 1000 }, value='H'} }
-- enables a horizontal flip until the end of the current command block/sprite
-- lifespan, without having to manually keep track of where to put the end point.
--
return {
	easing = false,
	time_points = 0,
	dimension = 0,
	args = { "span_end" },
	args_valid = { function(x) return x end },
	varargs = true,
	eval = function(easing, t, vector_a, vector_b, args, varargs)
		if not args.span_end then
			return {'protract', table.unpack(varargs)}
		end

		local sb_com = require 'commands'
		local result = {}
		for i,v in ipairs(varargs) do
			local v_easing, v_time, v_vec1, v_vec2, v_args, v_varargs =
				sb_com:parseCommand(v)
			local extended = {table.unpack(v_time)}
			extended[#extended] = args.span_end
			table.insert(result, sb_com:createCommand(v[1], v_easing, extended, v_vec1, v_vec2, v_args, v_varargs))
		end
		return table.unpack(result)
	end
}
