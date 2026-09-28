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
	set_size = 100,
	anchor = 'TopCentre',
	file_str_format = 'T/%d.png',
	file_str_format_v2 = 'T/%dA.png',
	file_str_format_v3 = 'T/%dB.png',
	orientation = -1,
}

tri.__index = tri

tri.sample_set = {}

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

function tri:getTriangleOrientation(x1,y1, x2,y2, x3,y3)
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

function tri:getClosestSourceTri(x1,y1, x2,y2, x3,y3, test_side)
	local min_dist=1/0
	local min_i=nil
	local side=nil
	local mJ,mK
	local flip = false

	for i,v in ipairs(tri.sample_set) do

		if test_side==1 or test_side==nil then
			local Nx1,Ny1,Nx2,Ny2,Nx3,Ny3, NJ,NK = tri:normaliseTriangle(x1,y1, x2,y2, x3,y3, 1)

				--- 1 
			local dist = math.abs(v[1] - Nx3)
			if dist < min_dist then
				side, min_dist, min_i, mJ, mK, flip = 1, dist, i, NJ,NK, false end

			dist = math.abs( (1.0 - v[1]) - Nx3)
			if dist < min_dist then
				side, min_dist, min_i, mJ, mK, flip = 1, dist, i, NJ,NK, true end
		end
		---
		---
		---

			--- 2
		if test_side==2 or test_side==nil then
			Nx1,Ny1,Nx2,Ny2,Nx3,Ny3, NJ,NK = tri:normaliseTriangle(x1,y1, x2,y2, x3,y3, 2)

			dist = math.abs(v[1] - Nx3)
			if dist < min_dist then
				side, min_dist, min_i, mJ, mK, flip = 2, dist, i, NJ,NK, false end

			dist = math.abs((1.0 - v[1]) - Nx3)
			if dist < min_dist then
				side, min_dist, min_i, mJ, mK, flip = 2, dist, i, NJ,NK, true end
		end
		--
		--
		--

			--- 3
		if test_side==3 or test_side==nil then
			Nx1,Ny1,Nx2,Ny2,Nx3,Ny3, NJ,NK = tri:normaliseTriangle(x1,y1, x2,y2, x3,y3, 3)

			dist = math.abs(v[1] - Nx3)
			if dist < min_dist then
				side, min_dist, min_i, mJ, mK, flip = 3, dist, i, NJ,NK, false end

			dist = math.abs((1.0 - v[1]) - Nx3)
			if dist < min_dist then
				side, min_dist, min_i, mJ, mK, flip = 3, dist, i, NJ,NK, true end
		end
		--
		--

	end

	local tri_error = min_dist
	return min_i,side,mJ,mK,flip, tri_error
end

function tri:getSourceTriError(x1,y1, x2,y2, x3,y3, source_i, test_side)
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
		if dist < min_dist then
			side, min_dist, min_i, mJ, mK, flip = 1, dist, i, NJ,NK, false end

		dist = math.abs( (1.0 - v[1]) - Nx3)
		if dist < min_dist then
			side, min_dist, min_i, mJ, mK, flip = 1, dist, i, NJ,NK, true end
	end
	---
	---
	---

		--- 2
	if test_side==2 or test_side==nil then
		Nx1,Ny1,Nx2,Ny2,Nx3,Ny3, NJ,NK = tri:normaliseTriangle(x1,y1, x2,y2, x3,y3, 2)

		dist = math.abs(v[1] - Nx3)
		if dist < min_dist then
			side, min_dist, min_i, mJ, mK, flip = 2, dist, i, NJ,NK, false end

		dist = math.abs((1.0 - v[1]) - Nx3)
		if dist < min_dist then
			side, min_dist, min_i, mJ, mK, flip = 2, dist, i, NJ,NK, true end
	end
	--
	--
	--

		--- 3
	if test_side==3 or test_side==nil then
		Nx1,Ny1,Nx2,Ny2,Nx3,Ny3, NJ,NK = tri:normaliseTriangle(x1,y1, x2,y2, x3,y3, 3)

		dist = math.abs(v[1] - Nx3)
		if dist < min_dist then
			side, min_dist, min_i, mJ, mK, flip = 3, dist, i, NJ,NK, false end

		dist = math.abs((1.0 - v[1]) - Nx3)
		if dist < min_dist then
			side, min_dist, min_i, mJ, mK, flip = 3, dist, i, NJ,NK, true end
	end
	--
	--

	return min_dist
end

function tri:determineTriangleSide(x1,y1, x2,y2, x3,y3)
	if angleThreePoints(x1,y1,x2,y2,x3,y3) > math.pi/2 then
		return 3,1
	elseif angleThreePoints(x1,y1,x3,y3,x2,y2) > math.pi/2 then
		return 1,2
	end
	return 2,3
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
	result.vector = { Sx*J/tri.DIM, K/tri.DIM }
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
	local T1 = tri:getSpriteForTriangle(tri1, cols1)
	if not T1 then return nil end

	local T1alt = tri:getSpriteForTriangle(tri1, cols1, {alt_side=true})

	-- test which side is better
	--
	local weight1 = sb_config["3d-interp-1-weight"]
	local weight2 = sb_config["3d-interp-2-weight"]
	
	local x1,y1, x2,y2, x3,y3 = tri2[1], tri2[2], tri2[3], tri2[4],tri2[5], tri2[6]

	local err_a_1 = tri:getSourceTriError(x1,y1, x2,y2, x3,y3, T1.sample_i, T1.side)
	local err_a_2 = T1.tri_error
	local err_b_1 = tri:getSourceTriError(x1,y1, x2,y2, x3,y3, T1alt.sample_i, T1alt.side)
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
	--

	local side = T1.side
	local sample_i = T1.sample_i
	local atan2 = math.atan

	local T_i, _, J,K, flip = tri:getClosestSourceTri(x1,y1, x2,y2, x3,y3, side)
	local orientation = tri:getTriangleOrientation(x1,y1, x2,y2, x3,y3)
	local x,y,angle

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
	result.vector = { Sx*J/tri.DIM, K/tri.DIM }

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

	if T1 then
		obj1 = sb_object:new(T1.file, L, T1.anchor, 0,0):add(
			{'fade',    0, {time1,time2}, 1,1},
			{'move',    0, {time1,time2}, T1.pos, T2.pos},
			{'rot',     0, {time1,time2}, T1.rot, T2.rot},
			{'vector',  0, {time1,time2}, T1.vector, T2.vector},
			{'color' ,  0, {time1,time2}, T1.col, T2.col}
		)

		if T1.tri2 then
			obj2 = sb_object:new(T1.tri2.file, L, T1.anchor, 0,0):add(
				{'fade',    0, {time1,time2}, 1,1},
				{'move',    0, {time1,time2}, T1.tri2.pos, T2.tri2.pos},
				{'rot',     0, {time1,time2}, T1.tri2.rot, T2.tri2.rot},
				{'vector',  0, {time1,time2}, T1.tri2.vector, T2.tri2.vector},
				{'color' ,  0, {time1,time2}, T1.tri2.col, T2.tri2.col}
			)
		elseif T2.tri2 then
			obj2 = sb_object:new(T1.file_v2, L, T1.anchor, 0,0):add(
				{'fade',    0, {time1,time2}, 1,1},
				{'move',    0, {time1,time2}, T1.pos, T2.tri2.pos},
				{'rot',     0, {time1,time2}, T1.rot, T2.tri2.rot},
				{'vector',  0, {time1,time2}, T1.vector, T2.tri2.vector},
				{'color' ,  0, {time1,time2}, T1.col, T2.tri2.col}
			)
		end

		if T1.tri3 then
			obj3 = sb_object:new(T1.tri3.file, L, T1.anchor, T1.pos[1], T1.pos[2]):add(
				{'fade',    0, {time1,time2}, 1,1},
				{'move',    0, {time1,time2}, T1.tri3.pos, T2.tri3.pos},
				{'rot',     0, {time1,time2}, T1.tri3.rot, T2.tri3.rot},
				{'vector',  0, {time1,time2}, T1.tri3.vector, T2.tri3.vector},
				{'color' ,  0, {time1,time2}, T1.tri3.col, T2.tri3.col}
			)
		elseif T2.tri3 then
			obj3 = sb_object:new(T1.file_v3, L, T1.anchor, T1.pos[1], T1.pos[2]):add(
				{'fade',    0, {time1,time2}, 1,1},
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

function tri:get3DTrianglesOut(verts, format, model_m, view_m, proj_m, bone_mats, frag_shader)
	local Triangles = {}
	local Colors    = {}

	local Pos_i, Pos_j = sb_m3d:getVertexAttributeIndex(format, 'VertexPosition')

	local m3d = sb_m3d

	for i=1, #verts, 3 do
		local v1_pos, v1_norm, v1_c, v1_x, v1_y = m3d:vertexOut(verts[i+0], format, model_m, view_m, proj_m, bonemats)
		local v2_pos, v2_norm, v2_c, v2_x, v2_y = m3d:vertexOut(verts[i+1], format, model_m, view_m, proj_m, bonemats)
		local v3_pos, v3_norm, v3_c, v3_x, v3_y = m3d:vertexOut(verts[i+2], format, model_m, view_m, proj_m, bonemats)

		local v1_col = frag_shader(v1_pos, v1_norm, v1_c)
		local v2_col = frag_shader(v2_pos, v2_norm, v2_c)
		local v3_col = frag_shader(v3_pos, v3_norm, v3_c)

		--[[
		print('--------\n')
		print(v1_pos, v1_norm)
		print(v1_x, v1_y)
		print(' ')
		print(v2_pos, v2_norm)
		print(v2_x, v2_y)
		print(' ')
		print(v3_pos, v3_norm)
		print(v3_x, v3_y)
		print(' \n\n')--]]

		table.insert(Triangles, {v1_x,v1_y, v2_x,v2_y, v3_x,v3_y})
		table.insert(Colors   , {v1_col, v2_col, v3_col})
	end

	return Triangles, Colors
end

return tri
