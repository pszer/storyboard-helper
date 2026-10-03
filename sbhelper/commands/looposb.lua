-- Loop
return {
	easing = false, -- easing on paramter does nothing in .osb, 
	time_points = 1,
	dimension = 0,
	args = {"loop_count","force_length",
		"start_x" , "start_y" , "start_sx" , "start_sy" , "start_rot", "start_col_r" , "start_col_g" , "start_col_b"},
	args_valid = {
		function(x)
			sb.log:assert(type(x)=='number', "loop count expected to be an integer, got '%s'", type(x))
			return x
		end,
		function(x)
			sb.log:assert(type(x)=='number' or type(x)=='nil', "force_length expected to be a number, got '%s'", type(x))
			return x
		end,
	},
	varargs = true,
	eval = function(easing, t, vector_a, vector_b, args, varargs, self)
		local results = {sb.evalroot(easing, t, vector_a, vector_b, args, varargs)}

		local inner_loops = sb.verify:extractCommands(results, 'loop')
		if #inner_loops>0 then
			sb.log:error('Inner loops not yet supported.')
		end

		--local L = {'loop', t, sb.unpack(results)}
		--for i,v in pairs(args) do L[i] = v end
		for i,v in ipairs(results) do
			self[i+2]=results[i]
		end
		return self
	end,
	out = function(easing, t, vector_a, vector_b, args, varargs)
		local inner = {}

		for i,v in ipairs(varargs) do
			table.insert(inner,sb.com:out(v))
		end

		return sb.ir:newCompound(inner, "L", sb.ir:floorTime(t[1]),math.floor(args.loop_count))
	end
}
