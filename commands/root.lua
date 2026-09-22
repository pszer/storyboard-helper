-- Root
local sb_ir = require 'ir'
local sb_log = require 'log'
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

		--for i,v in pairs(varargs) do
		--	print(i,table.unpack(v))
		--end

		local evals = sb_com:evalBlock(varargs)

		local time_min,time_max = sb_verify:getCommandsTimeSpan(evals)

		local start_pos   = {args.start_x, args.start_y}
		if not start_pos[1] then start_pos = nil end

		local start_rot   = {args.start_rot}
		if not start_rot[1] then start_rot = nil end

		local start_scale = {args.start_sx, args.start_sy}
		if not start_scale[1] then start_scale = nil end

		local start_col = {args.start_col_r, args.start_col_g, args.start_col_b}
		if not start_col[1] then start_col = nil end

		-- scale and vector have undefined .osb behaviour when used
		-- at the same time, even if they do behave correctly a percentage
		-- of the time. for now all scale commands are converted to vector.
		local function simplify_scale_vector()
			local scales = sb_verify:extractCommands(evals, 'scale', 'scalerel')
			local vector = sb_verify:extractCommands(evals, 'vector', 'vectorrel')

			if #vector == 0 and (start_scale and start_scale[1] == start_scale[2]) then
				return scales, 'scalerel'
			end

			for i,s in ipairs(scales) do
				local V = sb_com:scaleToVector(s)
				table.insert(vector, V)
			end

			return vector, 'vectorrel'
		end

		local function resolve(rel_type, start_vec, ...)
			local extract = sb_verify:extractCommands(evals, rel_type, ...)
			local time, dim = sb_verify:sortedTimes(extract)
			return {sb_verify:resolveTransformOverlaps(time, dim, rel_type, start_vec)}
		end

		local m = resolve('moverel', start_pos, 'move')
		local r = resolve('rotrel', start_rot, 'rot')

		local s_v_commands, s_v_rel_type, s_v_type = simplify_scale_vector()
		local s_time, s_dim = sb_verify:sortedTimes(s_v_commands)
		local s_v = {sb_verify:resolveTransformOverlaps(s_time, s_dim, s_v_rel_type, start_scale)}

		local flips
		s_v, flips = sb_verify:resolveNegativeScales(s_v)

		local concat = {}
		for _,v in ipairs(m) do concat[#concat+1] = v end
		for _,v in ipairs(r) do concat[#concat+1] = v end
		for _,v in ipairs(s_v) do concat[#concat+1] = v end

		---
		--- resolve protract commands to lifespan of this block.
		---
		
		local protract = sb_verify:extractCommands(evals, 'protract')
		local flip_protracts = sb_verify:extractCommands(flips, 'protract')
		local time_min, time_max = sb_verify:getCommandsTimeSpan(concat)
		local protract_results = {}

		for i,v in ipairs(flip_protracts) do
			v.span_end = time_max
			local protract_eval = { eval(v) }
			for _,z in ipairs(protract_eval) do table.insert(evals, z) end
		end
		for i,v in ipairs(protract) do
			v.span_end = time_max
			local protract_eval = { eval(v) }
			for _,z in ipairs(protract_eval) do table.insert(evals, z) end
		end
		for i,v in ipairs(flips) do
			table.insert(evals, v)
		end

		local params = sb_verify:extractCommands(evals, 'param')
		local hh,vv,aa = sb_verify:resolveParameterOverlaps(params)

		for _,v in ipairs(hh) do concat[#concat+1] = v end
		for _,v in ipairs(vv) do concat[#concat+1] = v end
		for _,v in ipairs(aa) do concat[#concat+1] = v end

		if #evals > 0 then
			sb_log:printf("testing, still commands left in eval stack!")
			for i,v in ipairs(evals) do
				print(sb_com:toString(v))
			end
		end

		--
		--
		--

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
