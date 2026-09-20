-- Root
local sb_ir = require 'ir'
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
	eval = function(t, easing, vector_a, vector_b, args, varargs)
		local sb_verify = require 'verify'
		local sb_com = require 'commands'
		local eval = require 'eval'

		for i,v in pairs(varargs) do
		--	print(i,table.unpack(v))
		end

		local evals = {}
		for i,v in ipairs(varargs) do
			local R = { eval(v) }
			for _,w in ipairs(R) do
				table.insert(evals, w)
			end
		end

		-- scale and vector have undefined .osb behaviour when used
		-- at the same time, even if they do behave correctly a percentage
		-- of the time. for now all scale commands are converted to vector.
		local function simplify_scale_vector()
			local scales = sb_verify:filterToCommand(evals, 'scale')
			local vector = sb_verify:filterToCommand(evals, 'vector')

			for i,s in ipairs(scales) do
				local V = sb_com:scaleToVector(V)
				table.insert(vector, V)
			end

			return vector
		end

		local function resolve(rel_type, ...)
			local time, dim = sb_verify:sortedTimes(evals, {rel_type, ...})
			return {sb_verify:resolveTransformOverlaps(time, dim, rel_type)}
		end
		
		local m = resolve('moverel', 'move')
		local r = resolve('rotrel', 'rot')

		--local s = resolve('scalerel', 'scale')
		--local v = resolve('vectorrel', 'vector')
		local time, dim = sb_verify:sortedTimes(simplify_scale_vector())
		local s_v = {sb_verify:resolveTransformOverlaps(time, dim, rel_type)}

		local concat = {}
		for _,v in ipairs(m) do concat[#concat+1] = v end
		--for _,v in ipairs(r) do concat[#concat+1] = v end
		--for _,v in ipairs(s_v) do concat[#concat+1] = v end

		return table.unpack(concat)
	end,

	--[[
	out = function(easing, t, vector_a, vector_b, args, varargs)
		local function eval_root()
			local eval = require 'eval'
			local sb_com = require 'commands'

			local coms_result = {}
			for _,com in ipairs (varargs) do
				local com_def = sb_com[ com[1] ]
				if com_def.args and not com["start_x"] then
					com["start_x"] = self.x or 320 end
				if com_def.args and not com["start_y"] then
					com["start_y"] = self.y or 240 end

				local pass = {eval(com)}
				for i,v in ipairs(pass) do
					table.insert(coms_result, v)
				end
			end

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
	end--]]
}
