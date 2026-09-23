-- OriginScale
return {
	easing = true,
	time_points = 0,
	dimension = 0,
	args = {"origin", "scale", "rotate", "rotate_origin"},
	args_valid = {
		function(x)
			if not x then return {0,0} end
			if type(x)~="table" then return {0,0}, "table expected" end
			if #x<2 then return {0,0},"origin expected to be 2D vector" end
			if type(x[1])~="number" then return 0,"number expected" end
			if type(x[2])~="number" then return 0,"number expected" end
			return x
		end,
		function(x)
			if not x then return {0,0} end
			if type(x)~="table" then return {0,0}, "table expected" end
			if #x<2 then return {0,0},"scale expected to be 2D vector" end
			if type(x[1])~="number" then return 0,"number expected" end
			if type(x[2])~="number" then return 0,"number expected" end
			return x
		end,
		function(x)
			if not x then return 0 end
			if type(x)=="table" then x = x[1] end
			if type(x)~="number" then return 0,"number expected" end
			return x
		end,
		function(x)
			if not x then return {0,0} end
			if type(x)~="table" then return {0,0}, "table expected" end
			if #x<2 then return {0,0},"rotate origin expected to be 2D vector" end
			if type(x[1])~="number" then return 0,"number expected" end
			if type(x[2])~="number" then return 0,"number expected" end
			return x
		end
	},
	varargs = false,
	eval = function(easing, t, vector_a, vector_b, args, varargs)
		local coms = sb_com:eval(varargs)
		local result = {}

		for i,v in ipairs(coms) do
			if sb_com:equal(v, 'move') then
				local vec1, vec2 = sb_com:parse(v, "vec")
				
				if args.rotate then
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
