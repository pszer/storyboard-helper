-- Root
return {
	easing = false,
	time_points = 0,
	dimension = 0,
	args = { "memo_eval" , "memo_ir" , "memo_str" , "memo" ,
	         "start_x" , "start_y" , "start_sx" , "start_sy" , "start_rot", "start_col_r" , "start_col_g" , "start_col_b" },
	args_valid = {

		function(x) return false end,
		function(x) return false end,
		function(x) return false end,
		function(x)
			if x==nil then return true end
			if type(x)~="boolean" then
				return false, "'memo' expects a boolean value, for whether to enable/disable memorisation."
			end
			return x
		end,

		function(x) return x end, --start x
		function(y) return y end, --start y
		function(sx) return x end, -- start sx
		function(sy) return y end, -- start sy
		function(r) return r end, -- start r
		function(cr) return r end, -- start red
		function(cg) return g end, -- start green
		function(cb) return b end, -- start blue
	},
	varargs = true,
	eval = sb.evalroot
}
