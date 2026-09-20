-- OriginScale
local sb_ir = require 'ir'
return {
	easing = true,
	time_points = 0,
	dimension = 0,
	args = {"origin", "scale"},
	args_valid = {
		function(x) if #x<2 then return {0,0},"origin expected to be 2D vector" end end,
		function(x) if #x<2 then return {0,0},"scale expected to be 2D vector" end end,
	},
	varargs = false,
	eval = function(t, easing, vector_a, vector_b, args, varargs)
		local sb_com = require 'commands'

		local coms = sb_com:eval(varargs)
		-- TODO
		return table.unpack(varargs)
	end,
}
