require 'math'

local modules = (...):gsub('%.[^%.]+$', '') .. "."
local sb_anchor = require (modules..'anchor')
local sb_clone = require (modules..'clone')
local sb_object = require (modules..'object')
local sb_config = require (modules..'config')
local sb_layer = require (modules..'layer')
local sb_m3d = require (modules..'model')

local tri = {
	DIM = 160,
	PIXEL_DIM,
	set_size = 166,
	anchor = 'TopCentre',
	file_str_format = 'T/%d.png',
	file_str_format_v2 = 'T/%dA.png',
	file_str_format_v3 = 'T/%dB.png',
	orientation = -1,
}

tri.PIXEL_DIM = 1.0 / tri.DIM

tri.__index = tri

tri.sample_set = {}
tri.file_set = {}

local function degToRad(x)
	return math.pi*x/180.0
end
local function radToDeg(x)
	return 180.0*x/math.pi
end

-- fill out sample set
local count = 1
for i=0,0.5, 0.5/tri.set_size do
	tri.sample_set[count] = { i,1 , file = string.format(tri.file_str_format, count),
                                  file_v2 = string.format(tri.file_str_format_v2, count),
                                  file_v3 = string.format(tri.file_str_format_v3, count),
																}
	table.insert(tri.file_set, string.format(tri.file_str_format, count))
	table.insert(tri.file_set, string.format(tri.file_str_format_v2, count))
	table.insert(tri.file_set, string.format(tri.file_str_format_v3, count))
	count=count+1
end

local function angleThreePoints(x1,y1, x2,y2, x3,y3)
	local dx1,dy1 = x1-x2, y1-y2
	local dx2,dy2 = x3-x2, y3-y2

	local tA = math.atan(dy1,dx1)
	local tB = math.atan(dy2,dx2)

	local A = math.abs(tB - tA)
	if A > math.pi then return 2*math.pi-A end
	return A
end

local function rotate(x,y, cos, sin)
	local X,Y
	X = cos*x + sin*y
	Y = cos*y - sin*x
	return X,Y
end

function tri:triangleVisible(tri, y1, x2,y2, x3,y3)
	local x1
	if type(tri) == "table" then
		x1,y1, x2,y2, x3,y3 = tri[1],tri[2],tri[3],tri[4],tri[5],tri[6]
	else
		x1 = tri
	end

	if (x1<=-107 or x1>=854) and
	   (x2<=-107 or x2>=854) and
	   (x3<=-107 or x3>=854) and
	   (y1<=0 or y1>=480) and
	   (y2<=0 or y2>=480) and
	   (y3<=0 or y3>=480)
	then
	 return false end
	return true
end

function tri:getTriangleOrientation(x1,y1, x2,y2, x3,y3)
	if type(x1)=="table" then
		x1,y1,x2,y2,x3,y3 = x1[1],x1[2],x1[3],x1[4],x1[5],x1[6]
	end

	local dx1,dy1 = x2-x1, y2-y1
	local dx2,dy2 = x3-x1, y3-y1
	local result = dx1*dy2 - dy1*dx2
	if result < 0 then return 1 else return -1 end
end

--
--
-- 
--
function tri:normaliseTriangle(x1,y1, x2,y2, x3,y3, side)
	if side==2 then
		return tri:normaliseTriangle(x2,y2, x3,y3, x1,y1, 1)
	elseif side==3 then
		return tri:normaliseTriangle(x3,y3, x1,y1, x2,y2, 1)
	end

	local dx,dy = nil,nil
	-- set origin to point 'side'
	x2,y2 = x2-x1, y2-y1
	x3,y3 = x3-x1, y3-y1
	x1,y1 = 0,0

	dx,dy = x2-x1, y2-y1

	local Angle = math.atan(dy, dx)
	local Cos = math.cos(Angle)
	local Sin = math.sin(Angle)

	x1,y1 = rotate(x1,y1, Cos, Sin)
	x2,y2 = rotate(x2,y2, Cos, Sin)
	x3,y3 = rotate(x3,y3, Cos, Sin)

	local K, J = math.abs(y3),math.abs(x2)
	x1,x2,x3 = x1/J, x2/J, x3/J
	y1,y2,y3 = y1/K, y2/K, y3/K
	return x1,y1, x2,y2, x3,y3, J, K
end

function tri:getClosestSourceTri(x1,y1, x2,y2, x3,y3, test_side, sample_i, flip_lock)
	local min_dist=1/0
	local min_i=nil
	local side=nil
	local mJ,mK
	local flip = false

	local do_without_flip = true
	local do_with_flip = true

	local C_x1, C_y1, C_x2, C_y2, C_x3, C_y3

	if flip_lock ~= nil then
		if flip_lock == false then do_with_flip = false end
		if flip_lock == true then do_without_flip = false end
	end

	local set = tri.sample_set
	if sample_i then set = {set[sample_i]} end

	for i,v in ipairs(set) do

		if test_side==1 or test_side==nil then
			local Nx1,Ny1,Nx2,Ny2,Nx3,Ny3, NJ,NK = tri:normaliseTriangle(x1,y1, x2,y2, x3,y3, 1)

				--- 1 
			local dist = math.abs(v[1] - Nx3)
			if dist < min_dist and do_without_flip then
				side, min_dist, min_i, mJ, mK, flip = 1, dist, i, NJ,NK, false end

			dist = math.abs( (1.0 - v[1]) - Nx3)
			if dist < min_dist and do_with_flip then
				side, min_dist, min_i, mJ, mK, flip = 1, dist, i, NJ,NK, true end
		end
		---
		---
		---

			--- 2
		if test_side==2 or test_side==nil then
			Nx1,Ny1,Nx2,Ny2,Nx3,Ny3, NJ,NK = tri:normaliseTriangle(x1,y1, x2,y2, x3,y3, 2)

			dist = math.abs(v[1] - Nx3)
			if dist < min_dist and do_without_flip then
				side, min_dist, min_i, mJ, mK, flip = 2, dist, i, NJ,NK, false end

			dist = math.abs((1.0 - v[1]) - Nx3)
			if dist < min_dist and do_with_flip then
				side, min_dist, min_i, mJ, mK, flip = 2, dist, i, NJ,NK, true end
		end
		--
		--
		--

			--- 3
		if test_side==3 or test_side==nil then
			Nx1,Ny1,Nx2,Ny2,Nx3,Ny3, NJ,NK = tri:normaliseTriangle(x1,y1, x2,y2, x3,y3, 3)

			dist = math.abs(v[1] - Nx3)
			if dist < min_dist and do_without_flip then
				side, min_dist, min_i, mJ, mK, flip = 3, dist, i, NJ,NK, false end

			dist = math.abs((1.0 - v[1]) - Nx3)
			if dist < min_dist and do_with_flip then
				side, min_dist, min_i, mJ, mK, flip = 3, dist, i, NJ,NK, true end
		end
		--
		--

	end

	local tri_error = min_dist
	return min_i,side,mJ,mK,flip, tri_error
end

function tri:getSourceTriError(x1,y1, x2,y2, x3,y3, source_i, test_side, flip)
	local min_dist=1/0
	local min_i=nil
	local side=nil
	local mJ,mK
	local flip = false

	local v = tri.sample_set[source_i]

	if test_side==1 or test_side==nil then
		local Nx1,Ny1,Nx2,Ny2,Nx3,Ny3, NJ,NK = tri:normaliseTriangle(x1,y1, x2,y2, x3,y3, 1)

			--- 1 
		local dist = math.abs(v[1] - Nx3)
		if dist < min_dist and not flip then
			side, min_dist, min_i, mJ, mK, flip = 1, dist, i, NJ,NK, false end

		dist = math.abs( (1.0 - v[1]) - Nx3)
		if dist < min_dist and flip then
			side, min_dist, min_i, mJ, mK, flip = 1, dist, i, NJ,NK, true end
	end
	---
	---
	---

		--- 2
	if test_side==2 or test_side==nil then
		Nx1,Ny1,Nx2,Ny2,Nx3,Ny3, NJ,NK = tri:normaliseTriangle(x1,y1, x2,y2, x3,y3, 2)

		dist = math.abs(v[1] - Nx3)
		if dist < min_dist and not flip then
			side, min_dist, min_i, mJ, mK, flip = 2, dist, i, NJ,NK, false end

		dist = math.abs((1.0 - v[1]) - Nx3)
		if dist < min_dist and flip then
			side, min_dist, min_i, mJ, mK, flip = 2, dist, i, NJ,NK, true end
	end
	--
	--
	--

		--- 3
	if test_side==3 or test_side==nil then
		Nx1,Ny1,Nx2,Ny2,Nx3,Ny3, NJ,NK = tri:normaliseTriangle(x1,y1, x2,y2, x3,y3, 3)

		dist = math.abs(v[1] - Nx3)
		if dist < min_dist and not flip then
			side, min_dist, min_i, mJ, mK, flip = 3, dist, i, NJ,NK, false end

		dist = math.abs((1.0 - v[1]) - Nx3)
		if dist < min_dist and flip then
			side, min_dist, min_i, mJ, mK, flip = 3, dist, i, NJ,NK, true end
	end
	--
	--

	return min_dist
end

function tri:determineTriangleSide(x1,y1, x2,y2, x3,y3)
	if angleThreePoints(x1,y1,x2,y2,x3,y3) > math.pi/2.0 then
		return 3,1
	elseif angleThreePoints(x1,y1,x3,y3,x2,y2) > math.pi/2.0 then
		return 1,2
	end
	return 2,3
end

function tri:triangleOverlap(a, b, epsilon)
	local epsilon = epsilon or 0.25
	local ax, ay = a[1], a[2]
	local bx, by = a[3], a[4]
	local cx, cy = a[5], a[6]

	local dx, dy = b[1], b[2]
	local ex, ey = b[3], b[4]
	local fx, fy = b[5], b[6]

	local function separated(nx, ny)
		local amin = math.huge
		local amax = -math.huge
		local bmin = math.huge
		local bmax = -math.huge

		local p = ax * nx + ay * ny
		amin = math.min(amin, p)
		amax = math.max(amax, p)

		p = bx * nx + by * ny
		amin = math.min(amin, p)
		amax = math.max(amax, p)

		p = cx * nx + cy * ny
		amin = math.min(amin, p)
		amax = math.max(amax, p)

		p = dx * nx + dy * ny
		bmin = math.min(bmin, p)
		bmax = math.max(bmax, p)

		p = ex * nx + ey * ny
		bmin = math.min(bmin, p)
		bmax = math.max(bmax, p)

		p = fx * nx + fy * ny
		bmin = math.min(bmin, p)
		bmax = math.max(bmax, p)

		return amax-epsilon <= bmin or bmax-epsilon <= amin
	end

	local function testEdge(x1, y1, x2, y2)
		-- Perpendicular to edge
		local nx = -(y2 - y1)
		local ny =  (x2 - x1)

		local len = math.sqrt(nx * nx + ny * ny)
		if len > 0 then
				nx = nx / len
				ny = ny / len
		end

		return separated(nx, ny)
	end

	if testEdge(ax, ay, bx, by) then return false end
	if testEdge(bx, by, cx, cy) then return false end
	if testEdge(cx, cy, ax, ay) then return false end

	if testEdge(dx, dy, ex, ey) then return false end
	if testEdge(ex, ey, fx, fy) then return false end
	if testEdge(fx, fy, dx, dy) then return false end

	return true
end

function tri:triangleContains(tri, sub, epsilon)
	local function pointInTriangle(px, py, t)
		local x1, y1 = t[1], t[2]
		local x2, y2 = t[3], t[4]
		local x3, y3 = t[5], t[6]

		local function cross(ax, ay, bx, by)
				return (bx - ax) * (py - ay)
						 - (by - ay) * (px - ax)
		end

		local c1 = cross(x1, y1, x2, y2)
		local c2 = cross(x2, y2, x3, y3)
		local c3 = cross(x3, y3, x1, y1)

		-- normalise by length, so that it can be tested for
		-- tolerance epsilon in actual pixel units
		local len1,len2,len3 =
			(x2-x1)^2 + (y2-y1)^2,
			(x3-x2)^2 + (y3-y2)^2,
			(x1-x3)^2 + (y1-y3)^2
		if len1 > 0 then c1=c1/math.sqrt(len1) end
		if len2 > 0 then c2=c2/math.sqrt(len2) end
		if len3 > 0 then c3=c3/math.sqrt(len3) end

		local min_c = math.min(c1, c2, c3)
    local max_c = math.max(c1, c2, c3)

		return min_c >= -epsilon or max_c <= epsilon
	end

	return pointInTriangle(sub[1], sub[2], tri) and
	       pointInTriangle(sub[3], sub[4], tri) and
	       pointInTriangle(sub[5], sub[6], tri) 
end

function tri:centroid(v1,v2,v3)
	return (v1.x + v2.x + v3.x)/3.0,
	       (v1.y + v2.y + v3.y)/3.0,
	       (v1.z + v2.z + v3.z)/3.0
end
function tri:centroidZ(v1,v2,v3)
	return (v1.z + v2.z + v3.z)/3.0
end

local function vec3Eq(a,b)
	return (a[1]==b[1]) and (a[2]==b[2]) and (a[3]==b[3])
end

--
-- Returns { file=, anchor=, pos={}, vector={}, rot=, flip=f/t, side=, col=, tri2=, tri3= ,
--           file_v2=, file_v3= }
--
-- tri2 and tri3 are present if the triangle has differently coloured vertices,otherwise it
-- is entirely one triangle of one colour.
--
-- (vector is automatically given the correct negative scale in case of flip)
--
function tri:getSpriteForTriangle(T, Cols, params)
	if not tri:triangleVisible(T) then return nil end

	local params = params or {}
	local params_alt_side = params.alt_side or false
	local cull = params.backwards_cull or tri.orientation or -1
	local atan2 = math.atan

	local x1,y1, x2,y2, x3,y3 = T[1], T[2], T[3], T[4], T[5], T[6]

	local orientation = tri:getTriangleOrientation(x1,y1, x2,y2, x3,y3)
	if cull and orientation ~= cull then return nil end

	local test_side, test_side_alt = tri:determineTriangleSide(x1,y1, x2,y2, x3,y3)

	if params_alt_side then
		test_side = test_side_alt
	end

	local T_i, side, J,K, flip, tri_error = tri:getClosestSourceTri(x1,y1, x2,y2, x3,y3, test_side)

	local x,y,angle

	if test_side==1 then
		angle = atan2(y2-y1, x2-x1)
		x,y = x1+(x2-x1)*0.5 , y1+(y2-y1)*0.5
	elseif test_side==2 then
		angle = atan2(y3-y2, x3-x2)
		x,y = x2+(x3-x2)*0.5 , y2+(y3-y2)*0.5
	else
		angle = atan2(y1-y3, x1-x3)
		x,y = x3+(x1-x3)*0.5 , y3+(y1-y3)*0.5
	end

	local Sx = 1
	if flip==true then Sx=-1 end

	local edge_padding = sb_config['3d-scale-padding']
	local sc_pad = edge_padding * tri.PIXEL_DIM

	local result = {}
	result.anchor = sb_anchor:out(tri.anchor)
	result.side   = side
	result.flip   = flip

	result.file   = tri.sample_set[T_i].file
	result.file_v2= tri.sample_set[T_i].file_v2
	result.file_v3= tri.sample_set[T_i].file_v3
	result.sample_i = T_i

	result.pos    = { x,y }
	result.rot    =  angle
	result.vector = { Sx*J/tri.DIM+sc_pad, K/tri.DIM+sc_pad }
	result.tri_error = tri_error

	local v_map = {1,2,3}
	if     test_side == 1 and flip == true then
		v_map = {2,1,3}

	elseif test_side == 2 and flip == false then
		v_map = {2,3,1}
	elseif test_side == 2 and flip == true then
		v_map = {3,2,1}

	elseif test_side == 3 and flip == false then
		v_map = {3,1,2}
	elseif test_side == 3 and flip == true then
		v_map = {1,3,2}
	end

	local t2 = nil
	local t3 = nil

	if not vec3Eq( Cols[v_map[1]], Cols[v_map[2]] ) then
		t2 = sb_clone(result)
		t2.col = sb_clone(Cols[ v_map[2] ])
		t2.file = tri.sample_set[T_i].file_v2
	end

	if not vec3Eq(Cols[ v_map[1] ], Cols[ v_map[3] ]) then
		t3 = sb_clone(result)
		t3.col = sb_clone(Cols[ v_map[3] ])
		t3.file = tri.sample_set[T_i].file_v3
	end

	result.col = Cols[ v_map[1] ]

	result.tri2 = t2
	result.tri3 = t3

	return result
end

-- generates the closest fitting sprite for tri1, and the closest fitting sprite for
-- tri2 using the same source triangle
function tri:getSpritesTwoFrames(tri1, cols1, tri2, cols2)
	local cols1 = cols1 or tri1.cols
	local cols2 = cols2 or tri2.cols

	local T1 = tri:getSpriteForTriangle(tri1, cols1)
	if not T1 then return nil end

	--
	--
	-- Determine which side creates the better end result visual.
	--
	--
	--
	local T1alt = tri:getSpriteForTriangle(tri1, cols1, {alt_side=true})
	local x1,y1, x2,y2, x3,y3 = tri2[1], tri2[2], tri2[3], tri2[4],tri2[5], tri2[6]

	local lengthT1side
	local lengthT1altside

	--- Calculate the length of the primary sides used. If one is much smaller it will typically
	--- create worse results if used
	---
	if T1.side == 1 then lengthT1side = math.sqrt(  (tri1[3]-tri1[1])*(tri1[3]-tri1[1]) + (tri1[4]-tri1[2])*(tri1[4]-tri1[2]) ) end
	if T1.side == 2 then lengthT1side = math.sqrt(  (tri1[5]-tri1[3])*(tri1[5]-tri1[3]) + (tri1[6]-tri1[4])*(tri1[6]-tri1[4]) ) end
	if T1.side == 3 then lengthT1side = math.sqrt(  (tri1[1]-tri1[5])*(tri1[1]-tri1[5]) + (tri1[2]-tri1[6])*(tri1[2]-tri1[6]) ) end
	if T1alt.side == 1 then lengthT1altside = math.sqrt(  (tri1[3]-tri1[1])*(tri1[3]-tri1[1]) + (tri1[4]-tri1[2])*(tri1[4]-tri1[2]) ) end
	if T1alt.side == 2 then lengthT1altside = math.sqrt(  (tri1[5]-tri1[3])*(tri1[5]-tri1[3]) + (tri1[6]-tri1[4])*(tri1[6]-tri1[4]) ) end
	if T1alt.side == 3 then lengthT1altside = math.sqrt(  (tri1[1]-tri1[5])*(tri1[1]-tri1[5]) + (tri1[2]-tri1[6])*(tri1[2]-tri1[6]) ) end

	local length_threshold = sb_config["3d-larger-size-priority-scalar"]
	if lengthT1side > lengthT1altside*length_threshold then
		T1 = T1
	elseif lengthT1altside > lengthT1side*length_threshold then
		T1 = T1alt

		-- if no side is significantly longer, test error values VVV
	else
		-- test which side is better through an error estimate
		--
		local weight1 = sb_config["3d-interp-1-weight"]
		local weight2 = sb_config["3d-interp-2-weight"]
		

		local err_a_1 = tri:getSourceTriError(x1,y1, x2,y2, x3,y3, T1.sample_i, T1.side, T1.flip)
		local err_a_2 = T1.tri_error
		local err_b_1 = tri:getSourceTriError(x1,y1, x2,y2, x3,y3, T1alt.sample_i, T1alt.side, T1alt.flip)
		local err_b_2 = T1alt.tri_error

		err_a_1 = err_a_1 * math.sqrt(weight1)
		err_b_1 = err_b_1 * math.sqrt(weight1)
		err_a_2 = err_a_2 * math.sqrt(weight2)
		err_b_2 = err_b_2 * math.sqrt(weight2)

		local err = (err_a_1*err_a_1 + err_a_2*err_a_2)
		local err_alt = (err_b_1*err_b_1 + err_b_2*err_b_2)

		if err_alt < err then
			T1 = T1alt
		end
	end
	--
	-- ^^ Side determined
	--

	local side = T1.side
	local sample_i = T1.sample_i
	local atan2 = math.atan

	local T_i, _, J,K, T2_flip = tri:getClosestSourceTri(x1,y1, x2,y2, x3,y3, side, T1.sample_i, T1.flip)
	local orientation = tri:getTriangleOrientation(x1,y1, x2,y2, x3,y3)
	local x,y,angle

	local edge_padding = sb_config['3d-scale-padding']
	local sc_pad = edge_padding * tri.PIXEL_DIM

	flip = T1.flip

	if side==1 then
		angle = atan2(y2-y1, x2-x1)
		x,y = x1+(x2-x1)*0.5 , y1+(y2-y1)*0.5
	elseif side==2 then
		angle = atan2(y3-y2, x3-x2)
		x,y = x2+(x3-x2)*0.5 , y2+(y3-y2)*0.5
	else
		angle = atan2(y1-y3, x1-x3)
		x,y = x3+(x1-x3)*0.5 , y3+(y1-y3)*0.5
	end

	if angle > T1.rot+math.pi then
		angle = angle - 2*math.pi
	elseif angle < T1.rot - math.pi then
		angle = angle + 2*math.pi
	end

	--if math.abs(angle - T1.rot) > 0.0 then
	--	angle = T1.rot
	--end

	--[[
	if math.abs(angle - T1.rot) > 0.1 then
		print()
		print(angle, T1.rot)
		print(T2_flip, T1.flip, T1.side, _)
		print(x1,y1,x2,y2,x3,y3)
		print(tri1[1], tri1[2], tri1[3], tri1[4], tri1[5], tri1[6])
	end--]]

	local Sx = 1
	if flip==true then Sx=-1 end

	local result = {}

	result.anchor = sb_anchor:out(tri.anchor)
	result.side   = side
	result.flip   = flip

	result.file   = T1.file
	result.file_v2= tri.sample_set[T_i].file_v2
	result.file_v3= tri.sample_set[T_i].file_v3
	result.sample_i = T_i

	result.pos    = { x,y }
	result.rot    =  angle
	result.vector = { Sx*J/tri.DIM + sc_pad, K/tri.DIM + sc_pad}

	local v_map = {1,2,3}
	if     side == 1 and flip == true then
		v_map = {2,1,3}
	elseif side == 2 and flip == false then
		v_map = {2,3,1}
	elseif side == 2 and flip == true then
		v_map = {3,2,1}
	elseif side == 3 and flip == false then
		v_map = {3,1,2}
	elseif side == 3 and flip == true then
		v_map = {1,3,2}
	end

	result.col = cols2[ v_map[1] ]

	local tri2 = nil
	local tri3 = nil

	if (not vec3Eq( cols2[ v_map[1] ], cols2[ v_map[2] ])) or T1.tri2 then
		tri2 = sb_clone(result)
		tri2.col = cols2[ v_map[2] ]
		tri2.file = tri.sample_set[T_i].file_v2
	end

	if (not vec3Eq( cols2[ v_map[1] ], cols2[ v_map[3] ])) or T1.tri3 then
		tri3 = sb_clone(result)
		tri3.col = cols2[ v_map[3] ]
		tri3.file = tri.sample_set[T_i].file_v3
	end

	result.tri2 = tri2
	result.tri3 = tri3

	return T1,result
end

function tri:convertTriDataToObjects(T1, T2, layer, time1, time2)
	local obj1,obj2,obj3

	if T2==nil then T2=T1 end
	local L = sb_layer:out(layer)

	if T1 and sb_config['3d-debug-depth-shader'] then
		T1.col = {math.min(T1.height*50+50,255), math.min(T1.height*75+50,255), 50}
		T2.col = T1.col
	end

	if T1 then
		obj1 = sb_object:new(T1.file, L, T1.anchor, 0,0):add(
			{'fade',    0, {time1,time1}, 1,1},
			{'move',    0, {time1,time2}, T1.pos, T2.pos},
			{'rot',     0, {time1,time2}, T1.rot, T2.rot},
			{'vector',  0, {time1,time2}, T1.vector, T2.vector},
			{'color' ,  0, {time1,time2}, T1.col, T2.col}
		)

		if T1.tri2 then
			obj2 = sb_object:new(T1.tri2.file, L, T1.anchor, 0,0):add(
				{'fade',    0, {time1,time1}, 1,1},
				{'move',    0, {time1,time2}, T1.tri2.pos, T2.tri2.pos},
				{'rot',     0, {time1,time2}, T1.tri2.rot, T2.tri2.rot},
				{'vector',  0, {time1,time2}, T1.tri2.vector, T2.tri2.vector},
				{'color' ,  0, {time1,time2}, T1.tri2.col, T2.tri2.col}
			)
		elseif T2.tri2 then
			obj2 = sb_object:new(T1.file_v2, L, T1.anchor, 0,0):add(
				{'fade',    0, {time1,time1}, 1,1},
				{'move',    0, {time1,time2}, T1.pos, T2.tri2.pos},
				{'rot',     0, {time1,time2}, T1.rot, T2.tri2.rot},
				{'vector',  0, {time1,time2}, T1.vector, T2.tri2.vector},
				{'color' ,  0, {time1,time2}, T1.col, T2.tri2.col}
			)
		end

		if T1.tri3 then
			obj3 = sb_object:new(T1.tri3.file, L, T1.anchor, T1.pos[1], T1.pos[2]):add(
				{'fade',    0, {time1,time1}, 1,1},
				{'move',    0, {time1,time2}, T1.tri3.pos, T2.tri3.pos},
				{'rot',     0, {time1,time2}, T1.tri3.rot, T2.tri3.rot},
				{'vector',  0, {time1,time2}, T1.tri3.vector, T2.tri3.vector},
				{'color' ,  0, {time1,time2}, T1.tri3.col, T2.tri3.col}
			)
		elseif T2.tri3 then
			obj3 = sb_object:new(T1.file_v3, L, T1.anchor, T1.pos[1], T1.pos[2]):add(
				{'fade',    0, {time1,time1}, 1,1},
				{'move',    0, {time1,time2}, T1.pos, T2.tri3.pos},
				{'rot',     0, {time1,time2}, T1.rot, T2.tri3.rot},
				{'vector',  0, {time1,time2}, T1.vector, T2.tri3.vector},
				{'color' ,  0, {time1,time2}, T1.col, T2.tri3.col}
			)
		end
	end

	if not obj2 and obj3 then
		obj2 = obj3
	end

	return obj1, obj2, obj3
end

--
-- format
--
-- {x,y, x,y, x,y,  centroid_z=, height=, cols={}, id=ID,    start_t=..., end_t=..., final=false/true}
--
-- start_t, end_t and final is to be filled out by the animation framework.
-- final==true means that the triangle next frame is to be culled.
--
function tri:get3DTrianglesOut(verts, format, model_m, view_m, proj_m, bone_mats, frag_shader)
	local Triangles = {}
	local Colors    = {}

	local Pos_i, Pos_j = sb_m3d:getVertexAttributeIndex(format, 'VertexPosition')

	local m3d = sb_m3d

	for i=1, #verts, 3 do
		local ID = verts[i+0].id

		local v1_pos, v1_norm, v1_c, v1_x, v1_y = m3d:vertexOut(verts[i+0], format, model_m, view_m, proj_m, bone_mats)
		local v2_pos, v2_norm, v2_c, v2_x, v2_y = m3d:vertexOut(verts[i+1], format, model_m, view_m, proj_m, bone_mats)
		local v3_pos, v3_norm, v3_c, v3_x, v3_y = m3d:vertexOut(verts[i+2], format, model_m, view_m, proj_m, bone_mats)

		local v1_col = frag_shader(v1_pos, v1_norm, v1_c)
		local v2_col = frag_shader(v2_pos, v2_norm, v2_c)
		local v3_col = frag_shader(v3_pos, v3_norm, v3_c)

		local centroid_z = tri:centroidZ(v1_pos, v2_pos, v3_pos)

		table.insert(Triangles, {v1_x,v1_y, v2_x,v2_y, v3_x,v3_y, ["centroid_z"] = centroid_z, height=0, cols =
			{v1_col,v2_col,v3_col}, id=ID})
		table.insert(Colors   , {v1_col, v2_col, v3_col})
	end

	return Triangles, Colors
end

-- subdivides triangle once
--     /\         /\
--    /  \       /  \
--   /    \     /____\
--  /      \   / \   /\
-- /________\ /__ \ /__\
--
function tri:subdivideTriangle(tri)
	local mid_12_x = (tri[1] + tri[3]) * 0.5
	local mid_12_y = (tri[2] + tri[4]) * 0.5
	--
	local mid_23_x = (tri[3] + tri[5]) * 0.5
	local mid_23_y = (tri[4] + tri[6]) * 0.5
	--
	local mid_31_x = (tri[5] + tri[1]) * 0.5
	local mid_31_y = (tri[6] + tri[2]) * 0.5
	--
	local Tri1, Tri2, Tri3, Tri4
	Tri1 =   {tri[1], tri[2], mid_12_x, mid_12_y, mid_31_x, mid_31_y }
	Tri2 =   {mid_12_x, mid_12_y, tri[3], tri[4], mid_23_x, mid_23_y }
	Tri3 =   {mid_23_x, mid_23_y, tri[5], tri[6], mid_31_x, mid_31_y }
	Tri4 = {mid_12_x, mid_12_y, mid_23_x, mid_23_y, mid_31_x, mid_31_y}

	return Tri1, Tri2, Tri3, Tri4
end

-- Test if a triangle to be rendered behind others, is fully occluded by them.
-- returns true if full occlusion, meaning the triangle can safely be not drawn.
--
-- epsilon is a value in pixels that allows for differences in that many pixels
-- to still count as occlusion, which allows for numerical edge cases to still be occluded
-- because they visually make little impact.
--
function tri:testTriangleOcclusion(triangle, set, epsilon)
	local epsilon = epsilon or sb_config['3d-default-occlusion-epsilon'] -- 1.8 pixel by default
	local TriRoot = { triangle, coverage=false, children=nil }

	local recur = nil
	recur = function(root, top_tri)
		-- already occluded
		if root.coverage == true then 
			return
		end

		-- if full occlusion of this subdivision
		if tri:triangleContains(top_tri, root[1], epsilon) then
			root.coverage = true
			return
		elseif tri:triangleOverlap(top_tri, root[1]) then

			-- subdivide if new
			if root.children==nil then
				local t1,t2,t3,t4 = tri:subdivideTriangle(root[1])
				root.children = {{t1},{t2},{t3},{t4}}
				root.children[1].coverage = false
				root.children[2].coverage = false
				root.children[3].coverage = false
				root.children[4].coverage = false
			end

			recur(root.children[1], top_tri)
			recur(root.children[2], top_tri)
			recur(root.children[3], top_tri)
			recur(root.children[4], top_tri)

			if root.children[1].coverage and root.children[2].coverage
				and root.children[3].coverage and root.children[4].coverage
			then
				root.coverage = true
				return
			end
		end

	end

	for i,v in ipairs(set) do
		recur(TriRoot, v)
		if TriRoot.coverage then return true end
	end
	return false
end

--
--
-- triangle centroid Z is used to approximate depth order, the resulting
-- depth stack can be used in depth-correct sprite pooling.
--
--
function tri:calculateDepthStack(triangles)
	local sorted_count = 1
	local sorted_by_centroid = {}
	for i,v in ipairs(triangles) do
		local orientation = tri:getTriangleOrientation(v)
		
		if orientation == tri.orientation and v.centroid_z > 0.0 then
			v.min_x = math.min(v[1],v[3],v[5])
			v.min_y = math.min(v[2],v[4],v[6])
			v.max_x = math.max(v[1],v[3],v[5])
			v.max_y = math.max(v[2],v[4],v[6])

			sorted_by_centroid[sorted_count] = v
			sorted_count=sorted_count+1
		end
	end

	local function compare(x,y)
		return x.centroid_z > y.centroid_z
	end
	table.sort(sorted_by_centroid, compare)

	local function overlap(t1,t2)
		-- bounding box test first
		if t1.min_x > t2.max_x or
			 t1.min_y > t2.max_y or
			 t2.min_x > t1.max_x or
			 t2.min_y > t1.max_y then
			return false
		end
		return tri:triangleOverlap(t1,t2, 0.25)
	end

	-- store for each triangle, what triangles overlap on top of it
	-- this is used to determine fully/99% overlapped triangles that
	-- do not need to be rendered.
	local occlusion_set = {}
	
	local set_size = #sorted_by_centroid
	for i=2,set_size do
		local test_tri = sorted_by_centroid[i]

		for j=i-1, 1,-1 do
			local tri_j = sorted_by_centroid[j]
			local Ov = overlap(test_tri, tri_j)
			
			if Ov then
				test_tri.height = math.max(tri_j.height+1, test_tri.height)

				-- add overlapping triangle to occlusion set
				local set = occlusion_set[tri_j]
				if set == nil then
					occlusion_set[tri_j] = {}
					set = occlusion_set[tri_j]
				end
				table.insert(set, test_tri)
			end

		end
	end

	-- test for triangles that are fully occluded by whats above them, they
	-- can be removed from rendering.
	for test_tri, overlaps in pairs(occlusion_set) do
		local test = tri:testTriangleOcclusion(test_tri, overlaps)

		if test then
			--remove
			for i,v in ipairs(sorted_by_centroid) do
				if v==test_tri then
					table.remove(sorted_by_centroid, i)
					break
				end
			end
			--
		end
	end

	table.sort(sorted_by_centroid, function(a,b) return a.height < b.height end)
	return sorted_by_centroid
end

return tri
