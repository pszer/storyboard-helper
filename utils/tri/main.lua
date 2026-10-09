local DIM=160
local SET_SIZE=166

local sample_set = {


}

local pixelcode = [[
	vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
	{
			//vec4 texcolor = Texel(tex, texture_coords);
			//texcolor *= color;
			return vec4(1,1,1,color.a);
	}
]]
local vertexcode = [[
	vec4 position( mat4 transform_projection, vec4 vertex_position )
	{
			return transform_projection * vertex_position;
	}
]]

local shader = love.graphics.newShader(pixelcode, vertexcode)

function degToRad(x)
	return math.pi*x/180.0
end
function radToDeg(x)
	return 180.0*x/math.pi
end

local TriMesh = nil
local TriMesh2
local TriMesh3

love.graphics.setShader(shader)
local count = 1
for i=0,0.5, 0.5/SET_SIZE do

	TriMesh = love.graphics.newMesh({
		{0  ,0,0,0,1,1,1,1},
		{DIM,0,0,0,1,1,1,1},
		{i*DIM,DIM,0,0,1,1,1,1},
	},"fan","static")
	TriMesh2 = love.graphics.newMesh({
		{0  ,0,0,0,1,1,1,0},
		{DIM,0,0,0,1,1,1,1},
		{i*DIM,DIM,0,0,1,1,1,0},
	},"fan","static")
	TriMesh3 = love.graphics.newMesh({
		{0  ,0,0,0,1,1,1,0},
		{DIM,0,0,0,1,1,1,0},
		{i*DIM,DIM,0,0,1,1,1,1},
	},"fan","static")

	local Canvas  = love.graphics.newCanvas(DIM,DIM)
	local Canvas2 = love.graphics.newCanvas(DIM,DIM)
	local Canvas3 = love.graphics.newCanvas(DIM,DIM)
	love.graphics.setCanvas(Canvas)
	love.graphics.clear(1,1,1,0)
	love.graphics.draw(TriMesh,0,0)
	love.graphics.setCanvas(Canvas2)
	love.graphics.clear(1,1,1,0)
	love.graphics.draw(TriMesh2,0,0)
	love.graphics.setCanvas(Canvas3)
	love.graphics.clear(1,1,1,0)
	love.graphics.draw(TriMesh3,0,0)
	--love.graphics.polygon("fill",0,0,DIM,0,i*DIM,DIM)
	love.graphics.setCanvas()

	sample_set[count] = {
		0,0 , {i,1}, Canvas ,Canvas2, Canvas3}

	local imgd = Canvas:newImageData()
	local file = love.filesystem.newFile(count..'.png')
	file:open('w')
	file:write(imgd:encode('png'))
	file:close()

	local imgd = Canvas2:newImageData()
	local file = love.filesystem.newFile(count..'A.png')
	file:open('w')
	file:write(imgd:encode('png'))
	file:close()

	local imgd = Canvas3:newImageData()
	local file = love.filesystem.newFile(count..'B.png')
	file:open('w')
	file:write(imgd:encode('png'))
	file:close()

	count=count+1
end

love.graphics.setShader()

local fix_angle = math.pi*60/180
local tan_fix_angle = math.tan(fix_angle)

print("set is ", #sample_set)

function love.load()

end

local TX1,TY1 = 200,360
local TX2,TY2 = 400,390
local TX3,TY3 = 400,360

local gX1,gY1 = 200,460
local gX2,gY2 = 400,360
local gX3,gY3 = 400,260

local tri_translate = {0,0}
local tri_rot = 0
local tri_scale = {1,1}

-- the angle is on vertex 2
--
function angleThreePoints(x1,y1, x2,y2, x3,y3)
	local dx1,dy1 = x1-x2, y1-y2
	local dx2,dy2 = x3-x2, y3-y2

	local tA = math.atan2(dy1,dx1)
	local tB = math.atan2(dy2,dx2)

	local A = math.abs(tB - tA)
	if A > math.pi then return 2*math.pi-A end
	return A
end

function rotate(x,y, cos, sin)
	local X,Y
	X = cos*x + sin*y
	Y = cos*y - sin*x
	return X,Y
end

function getTriangleOrientation(x1,y1, x2,y2, x3,y3)
	local dx1,dy1 = x2-x1, y2-y1
	local dx2,dy2 = x3-x1, y3-y1
	local result = dx1*dy2 - dy1*dx2
	if result < 0 then return 1 else return -1 end
end

function normaliseTriangle(x1,y1, x2,y2, x3,y3, side)

	if side==2 then
		return normaliseTriangle(x2,y2, x3,y3, x1,y1, 1)
	elseif side==3 then
		return normaliseTriangle(x3,y3, x1,y1, x2,y2, 1)
	end

	local dx,dy = nil,nil
	-- set origin to point 'side'
	x2,y2 = x2-x1, y2-y1
	x3,y3 = x3-x1, y3-y1
	x1,y1 = 0,0

	dx,dy = x2-x1, y2-y1

	local Angle = math.atan2(dy, dx)
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

function getClosestSourceTri(x1,y1, x2,y2, x3,y3, test_side)

	local min_dist=1/0
	local min_i=nil
	local side=nil
	local mJ,mK
	local flip = false

	for i,v in ipairs(sample_set) do

		if test_side==1 or test_side==nil then
			local Nx1,Ny1,Nx2,Ny2,Nx3,Ny3, NJ,NK = normaliseTriangle(x1,y1, x2,y2, x3,y3, 1)

				--- 1 
			local dist = math.abs(v[3][1] - Nx3)
			if dist < min_dist then
				side, min_dist, min_i, mJ, mK, flip = 1, dist, i, NJ,NK, false end

			dist = math.abs( (1.0 - v[3][1]) - Nx3)
			if dist < min_dist then
				side, min_dist, min_i, mJ, mK, flip = 1, dist, i, NJ,NK, true end
		end
		---
		---
		---

			--- 2
		if test_side==2 or test_side==nil then
			Nx1,Ny1,Nx2,Ny2,Nx3,Ny3, NJ,NK = normaliseTriangle(x1,y1, x2,y2, x3,y3, 2)

			dist = math.abs(v[3][1] - Nx3)
			if dist < min_dist then
				side, min_dist, min_i, mJ, mK, flip = 2, dist, i, NJ,NK, false end

			dist = math.abs((1.0 - v[3][1]) - Nx3)
			if dist < min_dist then
				side, min_dist, min_i, mJ, mK, flip = 2, dist, i, NJ,NK, true end
		end
		--
		--
		--

			--- 3
		if test_side==3 or test_side==nil then
			Nx1,Ny1,Nx2,Ny2,Nx3,Ny3, NJ,NK = normaliseTriangle(x1,y1, x2,y2, x3,y3, 3)

			dist = math.abs(v[3][1] - Nx3)
			if dist < min_dist then
				side, min_dist, min_i, mJ, mK, flip = 3, dist, i, NJ,NK, false end

			dist = math.abs((1.0 - v[3][1]) - Nx3)
			if dist < min_dist then
				side, min_dist, min_i, mJ, mK, flip = 3, dist, i, NJ,NK, true end
		end
		--
		--

	end

	return min_i,side,mJ,mK,flip
end

local source_i, TJ,TK, side, flip
function love.update(dt)
	TX3,TY3 = love.mouse.getPosition()

	local ts = 2
	if angleThreePoints(TX1,TY1,TX2,TY2,TX3,TY3) > math.pi/2 then
		ts = 3
	elseif angleThreePoints(TX1,TY1,TX3,TY3,TX2,TY2) > math.pi/2 then
		ts = 1
	end

	source_i, side, TJ,TK, flip = getClosestSourceTri(TX1,TY1,TX2,TY2,TX3,TY3, ts)
end

function love.draw()
	love.graphics.translate(-40,0)
	love.graphics.setColor(1,1,1,0.5)
	love.graphics.polygon("fill",TX1,TY1,TX2,TY2,TX3,TY3)

	local angle,x,y
	if side==1 then
		angle = math.atan2(TY2-TY1,TX2-TX1)
		x,y = TX1 + (TX2-TX1)/2, TY1 + (TY2-TY1)/2
	elseif side==2 then
		angle = math.atan2(TY3-TY2,TX3-TX2)
		x,y = TX2 + (TX3-TX2)/2, TY2 + (TY3-TY2)/2
	else
		angle = math.atan2(TY1-TY3,TX1-TX3)
		x,y = TX3 + (TX1-TX3)/2, TY3 + (TY1-TY3)/2
	end
	--local mid_Px, mid_Py = (TX2+TX1)*0.5, (TY2+TY1)*0.5
	local Sx = -1
	if flip then Sx=1 end

	local orientation = getTriangleOrientation(TX1,TY1,TX2,TY2,TX3,TY3)
	if orientation == -1 then TK=-TK end
	print(orientation)
	love.graphics.setColor(1,1,1,0.6)
	love.graphics.draw(sample_set[source_i][6], x+300, y, math.pi+angle, Sx*(TJ/DIM), TK/DIM, DIM/2, 0)
end
