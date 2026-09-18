-- Root
local sb_ir = require 'ir'
return {
	easing = false,
	time_points = 0,
	dimension = 0,
	args = { "memo_eval" , "memo_ir" , "memo_str" , "memo" },
	args_valid = {

		function(x)
			return false
		end,
		function(x)
			return false
		end,
		function(x)
			return false
		end,
		function(x)
			if x==nil then return true end
			if type(x)~="boolean" then
				return false, "'memo' expects a boolean value, for whether to enable/disable memorisation."
			end
			return x
		end

	},
	varargs = true,
	eval = function(t, easing, vector_a, vector_b, args, varargs)
		return table.unpack(varargs)
	end,
	out = function(easing, t, vector_a, vector_b, args, varargs)
		local function eval_root()
			local eval = require 'eval'

			local coms_result = {}
			for _,com in ipairs (varargs) do
				local pass = {eval(com)}
				for i,v in ipairs(pass) do
					table.insert(coms_result, v)
				end
			end

			local sb_com = require 'commands'
			local ir_result = {}
			for i,v in ipairs(coms_result) do
				table.insert(ir_result, sb_com:out(v))
			end

			local str_result = ""
			for i,v in ipairs(ir_result) do
				str_result = str_result..v:out()
				if i~=#ir_result then str_result=str_result.."\n" end
			end

			return coms_result, ir_result, str_result
		end

		if not args.memo then

			local _,__,str = eval_root()
			return {
				out=function(self)
					return str
				end
			}
			
		elseif args.memo and args.memo_str then

			return {
				out=function(self)
					return args.memo_str
				end
			}

		elseif args.memo then

			args.memo_eval, args.memo_ir, args.memo_str = eval_root()

			return {
				out=function(self)
					return args.memo_str
				end
			}

		end
	end
}
