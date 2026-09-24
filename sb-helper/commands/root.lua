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
	eval = function(easing, t, vector_a, vector_b, args, varargs)
		local evals = sb.com:eval(varargs)

		--[[
		for i,v in ipairs(evals) do
			print(sb.com:toString(v))
		end--]]

		local status = sb.verify:checkTimeOverlaps(evals)
		if status then
			sb.log:error(status)
		end

		local time_min,time_max = sb.verify:getCommandsTimeSpan(evals)

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
			local scales = sb.verify:extractCommands(evals, 'scale', 'scalerel')
			local vector = sb.verify:extractCommands(evals, 'vector', 'vectorrel')

			if #vector == 0 and (start_scale and start_scale[1] == start_scale[2]) then
				return scales, 'scalerel'
			end

			for i,s in ipairs(scales) do
				local V = sb.com:scaleToVector(s)
				table.insert(vector, V)
			end

			return vector, 'vectorrel'
		end

		local function resolve(rel_type, start_vec, ...)
			local extract = sb.verify:extractCommands(evals, rel_type, ...)
			local time, dim = sb.verify:sortedTimes(extract)
			return {sb.verify:resolveTransformOverlaps(time, dim, rel_type, start_vec)}
		end

		local m = resolve('moverel', start_pos, 'move')
		local r = resolve('rotrel', start_rot, 'rot')

		local s_v_commands, s_v_rel_type, s_v_type = simplify_scale_vector()
		local s_time, s_dim = sb.verify:sortedTimes(s_v_commands)
		local s_v = {sb.verify:resolveTransformOverlaps(s_time, s_dim, s_v_rel_type, start_scale)}

		local flips
		s_v, flips = sb.verify:resolveNegativeScales(s_v)

		local concat = {}
		for _,v in ipairs(m) do concat[#concat+1] = v end
		for _,v in ipairs(r) do concat[#concat+1] = v end
		for _,v in ipairs(s_v) do concat[#concat+1] = v end

		---
		--- resolve protract commands to lifespan of this block.
		---
		
		local protract = sb.verify:extractCommands(evals, 'protract')
		local flip_protracts = sb.verify:extractCommands(flips, 'protract')
		local time_min, time_max = sb.verify:getCommandsTimeSpan(concat)
		local protract_results = {}

		for i,v in ipairs(flip_protracts) do
			v.span_end = time_max
			local protract_eval = { sb.eval(v) }
			for _,z in ipairs(protract_eval) do table.insert(evals, z) end
		end
		for i,v in ipairs(protract) do
			v.span_end = time_max
			local protract_eval = { sb.eval(v) }
			for _,z in ipairs(protract_eval) do table.insert(evals, z) end
		end
		for i,v in ipairs(flips) do
			table.insert(evals, v)
		end

		local params = sb.verify:extractCommands(evals, 'param')
		local hh,vv,aa = sb.verify:resolveParameterOverlaps(params)

		for _,v in ipairs(hh) do concat[#concat+1] = v end
		for _,v in ipairs(vv) do concat[#concat+1] = v end
		for _,v in ipairs(aa) do concat[#concat+1] = v end

		if #evals > 0 then
			sb.log:printf("testing, still commands left in eval stack!")
			for i,v in ipairs(evals) do
				sb.log:printf("(%d), "..com:toString(v), i)
			end
		end

		--
		--
		--

		return sb.unpack(concat)
	end,
}
