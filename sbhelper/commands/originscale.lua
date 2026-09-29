-- OriginScale
return {
	easing = false,
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

	varargs = true,
	eval = function(easing, t, vector_a, vector_b, args, varargs)
		local coms = sb.com:eval(varargs)
		local result = {}

		local Cos = math.cos(args.rotate or 0)
		local Sin = math.sin(args.rotate or 0)

		for i,v in ipairs(coms) do

			if sb.com:equal(v, 'move') then
				local easing, time, vec1, vec2, _, _ = sb.com:parse(v)

				local Ox,Oy
				if args.origin then
					Ox,Oy = args.origin[1], args.origin[2]
				else
					Ox,Oy = 0,0
				end

				local Sx, Sy
				if args.scale then
					Sx,Sy = args.scale[1], args.scale[2]

					local _dx1,_dy1,_dx2,_dy2
					_dx1 = vec1[1] - Ox
					_dy1 = vec1[2] - Oy
					_dx2 = vec2[1] - Ox
					_dy2 = vec2[2] - Oy
					
					local dx1 = _dx1 * Sx
					local dy1 = _dy1 * Sy
					local dx2 = _dx2 * Sx
					local dy2 = _dy2 * Sy

					vec1[1] = Ox + dx1
					vec1[2] = Oy + dy1
					vec2[1] = Ox + dx2
					vec2[2] = Oy + dy2
				end
				
				local dx1,dy1,dx2,dy2 = 0,0,0,0
				if args.rotate then
					local _dx1,_dy1,_dx2,_dy2
					_dx1 = vec1[1] - Ox
					_dy1 = vec1[2] - Oy
					_dx2 = vec2[1] - Ox
					_dy2 = vec2[2] - Oy
					
					local dx1 = _dx1 * Cos + _dy1 * Sin
					local dy1 = _dy1 * Cos - _dx1 * Sin
					local dx2 = _dx2 * Cos + _dy2 * Sin
					local dy2 = _dy2 * Cos - _dx2 * Sin

					vec1[1] = Ox + dx1
					vec1[2] = Oy + dy1
					vec2[1] = Ox + dx2
					vec2[2] = Oy + dy2
				end

				if args.translate then
					vec1[1] = vec1[1] + args.translate[1]
					vec1[2] = vec1[2] + args.translate[2]

					vec2[1] = vec2[1] + args.translate[1]
					vec2[2] = vec2[2] + args.translate[2]
				end

				table.insert(result, sb.com:createCommand('move', easing, time, vec1, vec2))

			-- scale
			elseif sb.com:equal(v, 'scale') then
				local easing, time, vec1, vec2, _, _ = sb.com:parse(v)

				if args.scale then
					if args.scale[1] == args.scale[2] then
						table.insert(result, sb.com:createCommand('scale', easing, time, {vec1[1]*args.scale[1]}, {vec2[1]*args.scale[1]}))
					else
						table.insert(result, sb.com:createCommand('vector', easing, time,
							{vec1[1]*args.scale[1], vec1[2]*args.scale[2]},
							{vec2[1]*args.scale[1], vec2[2]*args.scale[2]}))
					end
				else
					table.insert(result, sb.clone(v))
				end
			--scale
			--
			--
			--vector
			elseif sb.com:equal(v, 'vector') then
				local easing, time, vec1, vec2, _, _ = sb.com:parse(v)

				if args.scale then
					table.insert(result, sb.com:createCommand('vector', easing, time,
						{vec1[1]*args.scale[1], vec1[2]*args.scale[2]},
						{vec2[1]*args.scale[1], vec2[2]*args.scale[2]}))
				else
					table.insert(result, sb.clone(v))
				end
			--vector
			--
			--
			--rotate
			elseif sb.com:equal(v, 'rotate') then
				local easing, time, vec1, vec2, _, _ = sb.com:parse(v)

				if args.rotate then
					table.insert(result, sb.com:createCommand('rotate', easing, time,
						{vec1[1]+args.scale[1]},
						{vec2[1]+args.scale[1]}))
				else
					table.insert(result, sb.clone(v))
				end

			--
			--
			--
			-- moverel is the only relative command affected by
			-- origin_scale. namely, it is scaled and rotated.
			--
			--
			elseif sb.com:equal(v, 'moverel') then
				local easing, time, vec1, vec2, _, _ = sb.com:parse(v)
				
				local Sx, Sy
				if args.scale then
					Sx,Sy = args.scale[1], args.scale[2]

					vec1[1] = vec1[1] * Sx
					vec1[2] = vec1[2] * Sy
					vec2[1] = vec2[1] * Sx
					vec2[2] = vec2[2] * Sy
				end
				
				if args.rotate then
					vec1[1] = vec1[1] * Cos + vec1[2] * Sin
					vec1[2] = vec1[2] * Cos - vec1[1] * Sin
					vec2[1] = vec2[1] * Cos + vec2[2] * Sin
					vec2[2] = vec2[2] * Cos - vec2[1] * Sin
				end

				table.insert(result, sb.com:createCommand('moverel', easing, time,
					vec1, vec2))
			else
				table.insert(result, v)
			end
		end

		return sb.unpack(result)
	end,
}
