require 'math'

local modules = (...):gsub('%.[^%.]+$', '') .. "."
local sb_anchor = require (modules..'anchor')
local sb_clone = require (modules..'clone')

local tri = {
	DIM = 192,
	set_size = 60,
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

local count = 1
for i=0,0.5, 0.5/tri.set_size do
	--[[local Canvas = love.graphics.newCanvas(DIM,DIM)
	love.graphics.setCanvas(Canvas)
	love.graphics.polygon("fill",0,0,DIM,0,i*DIM,DIM)
	love.graphics.setCanvas()--]]
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

	return min_i,side,mJ,mK,flip
end

function tri:determineTriangleSide(x1,y1, x2,y2, x3,y3)
	if angleThreePoints(x1,y1,x2,y2,x3,y3) > math.pi/2 then
		return 3
	elseif angleThreePoints(x1,y1,x3,y3,x2,y2) > math.pi/2 then
		return 1
	end
	return 2
end

local function vec3Eq(a,b)
	return a[1]==b[1] and
	       a[2]==b[2] and
				 a[3]==b[3]
end

--
-- Returns { file=, anchor=, pos={}, vector={}, rot=, flip=f/t, side=, col=, tri2=, tri3= }
--
-- tri2 and tri3 are present if the triangle has differently coloured vertices,otherwise it
-- is entirely one triangle of one colour.
--
-- (vector is automatically given the correct negative scale in case of flip)
--
function tri:getSpriteForTriangle(T, Cols, params)
	local params = params or {}
	local cull = params.backwards_cull or T.orientation or -1
	local atan2 = math.atan

	local x1,y1, x2,y2, x3,y3 = T[1], T[2], T[3], T[4], T[5], T[6]

	local orientation = tri:getTriangleOrientation(x1,y1, x2,y2, x3,y3)
	if cull and orientation ~= cull then return nil end

	local result = {}

	local test_side = tri:determineTriangleSide(x1,y1, x2,y2, x3,y3)
	local T_i, side, J,K, flip = tri:getClosestSourceTri(x1,y1, x2,y2, x3,y3, test_side)

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

	result.anchor = sb_anchor:out(tri.anchor)
	result.side   = side
	result.flip   = flip

	result.file   = tri.sample_set[T_i].file

	result.pos    = { x,y }
	result.rot    =  angle
	result.vector = { Sx*J/tri.DIM, K/tri.DIM }

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

	result.col = Cols[ v_map[1] ]

	local tri2 = nil
	local tri3 = nil

	if not vec3Eq(Cols[ v_map[1] ], Cols[ v_map[2] ]) then
		print("mogged")
		tri2 = sb_clone(result)
		tri2.col = Cols[ v_map[2] ]
		tri2.file = tri.sample_set[T_i].file_v2
	end

	if not vec3Eq(Cols[ v_map[1] ], Cols[ v_map[3] ]) then
		print("mogged")
		tri3 = sb_clone(result)
		tri3.col = Cols[ v_map[3] ]
		tri3.file = tri.sample_set[T_i].file_v3
	end

	result.tri2 = tri2
	result.tri3 = tri3

	return result
end

return tri
