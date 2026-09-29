local modules  = (...):gsub('%.[^%.]+$', '') .. "."
local sb = require (modules..'storyboard')
return function(easing, t, vector_a, vector_b, args, varargs)
	for i,v in ipairs(varargs) do
		if sb.com:equal(v,'loop') then
			v.start_x = args.start_x
			v.start_y = args.start_y
			v.start_sx = args.start_sx
			v.start_sy = args.start_sy
			v.start_rot = args.start_rot
			v.start_col_r = args.start_col_r
			v.start_col_g = args.start_col_g
			v.start_col_b = args.start_col_b
			v.start_col_a = args.start_col_a
		end
	end

	local evals = sb.com:eval(varargs)

	--[[print()
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

	for i,v in ipairs(flips) do
		local varargs = sb.com:parse(v, 'varargs')
	end

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
	local time_min2, time_max2 = sb.verify:getCommandsTimeSpan(evals)
	time_min  = time_min  or time_min2
	time_min2 = time_min2 or time_min
	time_max  = time_max  or time_max2
	time_max2 = time_max2 or time_max
	if time_min and time_min2 < time_min then time_min = time_min2 end
	if time_max and time_max2 > time_max then time_max = time_max2 end

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

	-- TODO fade relatives and resolution
	local fade = sb.verify:extractCommands(evals, 'fade')
	for _,v in ipairs(fade) do concat[#concat+1] = v end

	-- TODO colour relatives and resolution
	local cols = sb.verify:extractCommands(evals, 'color')
	for _,v in ipairs(cols) do concat[#concat+1] = v end

	local loops = sb.verify:extractCommands(evals, 'loop')
	for _,v in ipairs(loops) do concat[#concat+1] = v end

	if #evals > 0 then
		sb.log:printf("testing, still commands left in eval stack!")
		for i,v in ipairs(evals) do
			sb.log:printf("(%d), "..sb.com:toString(v), i)
		end
	end

	--
	--
	--

	return sb.unpack(concat)
end
