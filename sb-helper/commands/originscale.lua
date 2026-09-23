-- OriginScale
return {
	easing = true,
	time_points = 0,
	dimension = 0,
	-- if rotate_origin is non-nil
	args = {"translate", "scale", "rotate", "origin"},
	args_valid = {
		function(x)
			if not x then return nil end
			if type(x)~="table" then return {0,0}, "table expected" end
			if #x<2 then return {0,0},"translate expected to be 2D vector" end
			if type(x[1])~="number" then return {0,0},"number expected" end
			if type(x[2])~="number" then return {0,0},"number expected" end
			return x
		end,
		function(x)
			if not x then return nil end
			if type(x)~="table" then return {1,1}, "table expected" end
			if #x<2 then return {1,1},"scale expected to be 2D vector" end
			if type(x[1])~="number" then return {1,1},"number expected" end
			if type(x[2])~="number" then return {1,1},"number expected" end
			return x
		end,
		function(x)
			if not x then return nil end
			if type(x)~="number" then return 0,"number expected" end
			return x
		end,
		function(x)
			if not x then return nil end
			if type(x)~="table" then return {320,240}, "table expected" end
			if #x<2 then return {320,240},"origin expected to be 2D vector" end
			if type(x[1])~="number" then return {320,240},"number expected" end
			if type(x[2])~="number" then return {320,240},"number expected" end
			return x
		end
	},
	varargs = false,
	eval = function(easing, t, vector_a, vector_b, args, varargs)
		local coms = sb_com:eval(varargs)
		local result = {}

		local Cos = math.cos(args.rotate)
		local Sin = math.sin(args.rotate)

		for i,v in ipairs(coms) do
			if sb_com:equal(v, 'move') then
				local easing, time, vec1, vec2, _, _ = sb_com:parse(v, "vec")
				
				local dx1,dy1,dx2,dy2 = 0,0,0,0
				if args.rotate then
					local _dx1,_dy1,_dx2,_dy2
					_dx1 = vec1[1] - args.rotate_origin[1]
					_dy1 = vec1[2] - args.rotate_origin[2]
					_dx2 = vec2[1] - args.rotate_origin[1]
					_dy2 = vec2[2] - args.rotate_origin[2]
					
					local dx1 = _dx1 * Cos + _dy1 * Sin
					local dy1 = _dy1 * Cos - _dx1 * Sin
					local dx2 = _dx2 * Cos + _dy2 * Sin
					local dy2 = _dy2 * Cos - _dx2 * Sin

					vec1[1] = args.rotate_origin[1] + dx1 + args.origin[1]
					vec1[2] = args.rotate_origin[2] + dy1 + args.origin[2]
					vec2[1] = args.rotate_origin[1] + dx2 + args.origin[1]
					vec2[2] = args.rotate_origin[2] + dy2 + args.origin[2]
				else
					vec1[1] = vec1[1] + args.origin[1]
					vec1[2] = vec1[2] + args.origin[2]
					vec2[1] = vec1[1] + args.origin[1]
					vec2[2] = vec1[2] + args.origin[2]
				end

			elseif sb_com:equal(v, 'scale') then
			elseif sb_com:equal(v, 'vector') then
			elseif sb_com:equal(v, 'rotate') then

			else
				table.insert(result, v)
			end
		end

		-- TODO
		return table.unpack(varargs)
	end,
}
