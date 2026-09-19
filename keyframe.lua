require 'math'

local sb_log = require 'log'

local keyframe = {}

--
-- input - (keyframe) data to simplify
-- paramters - table of parameters-
--  ['in_func']  - a function that retrieves the time+vector to be used, useful if the input data
--                 is a specialised object and not just a raw table of the necessary time+vectors.
--                 the result should be {time, v1, v2, v3, ...} where v{n} is the n-th component
--                 of the vector.
--
--                 it is run on each element of input. by default it is it the identity function.
--
--  ['epsilon']  - specifies at what distance points get simplified, the greater epsilon is
--                 the fewer points the resulting curve will have.
--                 if keyframing movements, epsilon translates to the maximum deviation in
--                 pixels after simplification.
--
--  ['out_func'] - a function that runs on each of the resulting vectors post-simplification, to
--                 transform them into the necessary final object. identity function by default.
--                 passed in as a result is {time, v1, v2, v3, ...} where v{n} is the n-th component
--                 of the vector.
--
--

function keyframe:simplify(input, parameters)
	sb_log:assert(input, "keyframe.simplify(): missing argument.")	
	sb_log:assert(type(input)=="table", "keyframe.simplify(): expected table. got '%s'.", type(input))

	parameters = parameters or {}
	local in_func  = parameters.in_func 
	local epsilon  = parameters.epsilon or 2.0
	local out_func = parameters.in_func 

	local t_dimension = 0
	local dimension = -1

	-- if empty
	if input[1] == nil then
		return {}
	else
		local vec = input[1]
		if in_func then vec = in_func(vec) end
		t_dimension = #vec
		dimension = t_dimension - 1
	end

	-- dist
	local function dist(V)
		local sum = 0
		for i=2,t_dimension do
			sum = sum + V[i]
		end
		return math.pow(sum, 1.0 / dimension) + 0.01
	end

	local function dot(a, b)
		local sum = 0
		for i = 1,#a do
			sum = sum + a[i] * b[i]
		end
		return sum
	end

	-- shortest distance of v3 from line v1, v2
	local function perp_dist(v1, v2, v3, d, dd)

		local d = d or {}
		local p = {}
		for i=2,t_dimension do
			--d[i-1]=v2[i]-v1[i] -- precalculated v2-v1, since its re-used many times for each pass
			p[i-1]=v3[i]-v1[i]
		end
		local dd = dd or dot(d,d) -- precalculated d*d
		local pd = dot(p,d)
		if dd==0 then math.pow(dot(p,p),1/dimension) -- if v1 and v2 are the same point, just use point to point dist
			return
		end
		return math.sqrt(dot(p,p) - (pd*pd)/dd)
	end

	-- Ramer–Douglas–Peucker algorithm
	local RDP
	RDP = function(points, I, J)
		local result = {}

		local max_dist = -1/0
		local max_i = nil

		-- precalculate d and dd
		local d = {}
		for i=2,t_dimension do
			d[i-1]=points[J][i] - points[I][i]
		end
		local dd = dot(d,d)

		for i = I+1, J-1 do
			local dist_i = perp_dist(points[J],points[I], points[i], d, dd)
			if dist_i > max_dist then
				max_dist = dist_i
				max_i = i
			end
		end

		if max_dist > epsilon then
			local r_results1 = RDP(points,I,max_i)
			local r_results2 = RDP(points,max_i,J)

			for i=1,#r_results1-1 do
				table.insert(result,r_results1[i])
			end
			for i=1,#r_results2 do
				table.insert(result,r_results2[i])
			end
		else
			result = {points[I],points[J]}
		end

		return result
	end

	local points
	if in_func then
		for i,v in ipairs(input) do
			points[i] = in_func(v)
		end
	else
		points = input
	end

	local result = RDP(points, 1, #points)

	if out_func then
		for i,v in ipairs(result) do
			result[i] = out_func(v)
		end
	end

	return result
end

return keyframe
