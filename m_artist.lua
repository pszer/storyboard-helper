local sb = require 'sb-helper'

storyboard = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/2585798 Kazumi Totaka - Title Theme/Kazumi Totaka - Title Theme (Nintendo 64).osb")
sb.file:setProjectFolder("/home/quake/.local/share/osu-wine/osu!/Songs/2585798 Kazumi Totaka - Title Theme/")

--         BPM, offset
redline = {138.37, -25}
interval_1_4 = sb.time:convert{redline, 0.25}
interval_1_2 = sb.time:convert{redline, 0.5}
interval_1_1 = sb.time:convert{redline, 1.0}

local tiles = {{1,3},{1,4},{2,3},{2,4},{3,1},{3,2},{3,3},{3,4},{4,0},{4,1},{4,2},{4,3},{4,4},{5,0},{5,1},{5,2},{5,3},{5,4},{6,0},{6,1},{6,2},{6,3},{6,4},{7,3},{7,4},{8,3},{8,4},
}
local tiles_replace_with_square = {
	{1,3},
	{2,3},
	{3,3},
	{4,3},
	{5,3},
	{6,3},
	{7,3},
	{8,3},

	{1,4},
	{2,4},
	{3,4},
	{4,4},
	{5,4},
	{6,4},
	{7,4},
	{8,4},
}

function tileAfterLogo(X,Y)
	for _,v in ipairs(tiles_replace_with_square) do
		if v[1]==X and v[2]==Y then


			if X==4 and Y==3 then
				return "sb/t/43N.png"
			end
			if X==5 and Y==3 then
				return "sb/t/53N.png"
			end

			return "Sq.png"
		end
	end
	return nil
end

function tileHasImg(X,Y)
	for _,v in ipairs(tiles) do
		if v[1]==X and v[2]==Y then return "sb/t/"..X..Y..".png" end
	end
end

-- { x , y , xi, yi, {commands} }
local std_squares = {}
local std_fadein_times = {}
local std_fadein_flipd = {}

for x=-2, 11 do
	std_fadein_times[x] = {}
	std_fadein_flipd[x] = {}
end

local start_time = sb.time:convert{redline, 0.25}
local target_time = sb.time:convert{redline, 13}
local DT = (target_time-start_time) / (10*8)
local steps = 0
local X,Y = 0,0
local DX,DY = 1,0

local logo_fade_in_time = sb.time:convert{redline, 12.75}
local FF_time = sb.time:convert{redline, 28}

local squares_fade_out_time_1 = sb.time:convert{redline, 30.75}

local reset_time = sb.time:convert{redline, 16*4-0.25}

while true do
	if std_fadein_times[X][Y] then break end

	std_fadein_times[X][Y] = steps*DT + start_time

	if DX==1 then
		std_fadein_flipd[X][Y] = 1
	elseif DX == -1 then
		std_fadein_flipd[X][Y] = -1
	elseif DY == 1 then
		std_fadein_flipd[X][Y] = 2
	elseif DY == -1 then
		std_fadein_flipd[X][Y] = -2
	end

	steps = steps + 1

	X=X+DX
	Y=Y+DY
	-- takes steps in the shape of a spiral.
	-- boundary is [0,9] for X and [0,7] for Y, which covers the 4:3 resolution
	-- the X = [-2,0] and [10,11] portions are filled in later
	if X== -1 or Y == -1 or X==10 or Y==8 or std_fadein_times[X][Y] ~= nil then
		X=X-DX
		Y=Y-DY
		local nDX = -DY
		local nDY = DX
		DX = nDX
		DY = nDY
		X=X+DX
		Y=Y+DY
	end
end
-- fill out values for the widescreen squares
for y=0,7 do
		std_fadein_flipd[-2][y] = -2
		std_fadein_flipd[-1][y] = -2
		std_fadein_flipd[10][y] = 2
		std_fadein_flipd[11][y] = 2
	if y>0 then
		std_fadein_times[-2][y] = std_fadein_times[0][y]
		std_fadein_times[-1][y] = std_fadein_times[0][y]
	else
		std_fadein_times[-2][0] = std_fadein_times[0][1]+DT
		std_fadein_times[-1][0] = std_fadein_times[0][1]+DT
	end
	
	std_fadein_times[10][y] = std_fadein_times[9][y]
	std_fadein_times[11][y] = std_fadein_times[9][y]
end
--std_fadein_times[-2][0] = std_fadein_times[-2][1]
--std_fadein_times[-1][0] = std_fadein_times[-1][1]
for y=0,7 do
	--if y>0 then
		std_fadein_times[-2][y] = std_fadein_times[-2][y]+DT+DT
		std_fadein_times[-1][y] = std_fadein_times[-1][y]+DT
	--end
	std_fadein_times[10][y] = std_fadein_times[10][y]+DT
	std_fadein_times[11][y] = std_fadein_times[11][y]+DT+DT
end

--[[ console out for debug.
--
for y=0,7 do
	local result = ""
	for x=-2,11 do
		local V = std_fadein_times[x][y]
		if V == nil then V = '.'
		else V = math.floor(V) end
		result = result..string.format("%s ",V)
	end
	print(result)
end--]]

local fake_3d_square_edges_objects = {}

math.randomseed(500)

local sfx_count = 0
for x = 0 - (64)*2, 640+107, 64 do
	for y = 0, 480, 64 do

		local Sq = {x + 64/2.0 , y + 64/2.0, math.floor(x/64), math.floor(y/64), {}}
		table.insert(std_squares, Sq)

		local Sq_time_in = std_fadein_times[Sq[3]][Sq[4]]
		table.insert(Sq[5], {'move'  , 'linear',  {Sq_time_in, Sq_time_in}, {Sq[1],Sq[2]}, {Sq[1],Sq[2]}})
		table.insert(Sq[5], {'fade'  , 'linear',  {Sq_time_in, Sq_time_in}, 1, 1})

		local flipd = std_fadein_flipd[Sq[3]][Sq[4]]
		local edge_v = {}
		local vec1, vec2
		if flipd==1 then
			vec1,vec2 = {0,1},{1,1}
			edge_v = {29,0}
		elseif flipd==-1 then
			vec1,vec2 = {0,1},{1,1}
			edge_v = {-29,0}
		elseif flipd==2 then
			vec1,vec2 = {1,0},{1,1}
			edge_v = {0,29}
		elseif flipd==-2 then
			vec1,vec2 = {1,0},{1,1}
			edge_v = {0,-29}
		end

		if tileHasImg(Sq[3],Sq[4]) then
			vec1[1] = vec1[1] * 0.5
			vec2[1] = vec2[1] * 0.5
			vec1[2] = vec1[2] * 0.5
			vec2[2] = vec2[2] * 0.5
		end

		if (Sq[3] >= 0) and (Sq[3] <= 9) and (Sq[3]+Sq[4])%1==0 then
			storyboard:newObject('sb/s.wav', 'Background', Sq_time_in+DT*0.3, 70)
		end
		sfx_count = sfx_count+1

		table.insert(Sq[5], {'vector', 'sineOut', {Sq_time_in + DT*0.1, Sq_time_in + DT*3.5}, vec1, vec2})
		table.insert(Sq[5], {'color', 'sineOut' , {Sq_time_in + DT*0.1, Sq_time_in + DT*3.5}, {111,111,111},{255,255,255}})

		-- fade out after 1st sequence

		local D_sq = (Sq_time_in - start_time) / 40.0
		local rand_i = math.random()
		local rand_j = math.random()
		local _v1,_v2 = sb.clone(vec1), sb.clone(vec2)
		local c
		if rand_i<0.5 then
			c=_v2[1]
			_v2[1]=_v2[2]
			_v2[2]=c
			c=_v1[1]
			_v1[1]=_v1[2]
			_v1[2]=c
		end
		if rand_j < 0.1 then
			D_sq = -interval_1_2
		end
		if rand_j < 0.4 then
			D_sq = -interval_1_2
		end

		local newSquare = tileAfterLogo(Sq[3], Sq[4])

		if not newSquare then
			table.insert(Sq[5], {'fade'  , 'linear',  {squares_fade_out_time_1+interval_1_2+D_sq,
																								 squares_fade_out_time_1+interval_1_1+D_sq}, 1, 0})
			table.insert(Sq[5], {'vector', 'sineOut', {squares_fade_out_time_1 + DT*0.1+D_sq, squares_fade_out_time_1 + DT*6.5+D_sq}, _v2, _v1})
		else
			local TT=squares_fade_out_time_1 - interval_1_2
			table.insert(Sq[5], {'fade' , 'linear',  {TT,TT}, 0, 0})

			if newSquare == "Sq.png" then
				_v1[1] = _v1[1] * 2
				_v2[1] = _v2[1] * 2
				_v1[2] = _v1[2] * 2
				_v2[2] = _v2[2] * 2
			end

			storyboard:newObject(newSquare, "Background", "Center", 320, 240):add(
				{'move'  , 'linear',  {TT,TT}, {Sq[1],Sq[2]}, {Sq[1],Sq[2]}},
				{'fade'  , 'linear',  {squares_fade_out_time_1+interval_1_2+D_sq,
																								 squares_fade_out_time_1+interval_1_1+D_sq}, 1, 0},
				{'vector', 'sineOut', {squares_fade_out_time_1 + DT*0.1+D_sq, squares_fade_out_time_1 + DT*6.5+D_sq},
					_v2, _v1}
			)
		end

		local rot = nil
		if flipd == 2 or flipd == -2 then
			rot = {'rotate', 0, {Sq_time_in,Sq_time_in}, math.pi/2, math.pi/2}
		end

		table.insert(fake_3d_square_edges_objects,
		storyboard:newObject("sb/Edge.png", "Background", "Center", 320, 240):add(
			{'fade',  1        , {Sq_time_in + DT*0.1, Sq_time_in + DT*0.2}, 0,1 },
			{'color', 'sineout', {Sq_time_in + DT*0.1, Sq_time_in + DT*3.4}, {233,233,233},{50,50,50} },
			{'fade',  1        , {Sq_time_in + DT*3.2, Sq_time_in + DT*3.4}, 1,0 },
			{'move', 'sineOut', {Sq_time_in + DT*0.1, Sq_time_in + DT*3.5}, {Sq[1],Sq[2]}, {Sq[1]+edge_v[1],Sq[2]+edge_v[2]}},
			rot
		))
	end
end

for _,v in ipairs(std_squares) do
	local img = tileHasImg(v[3],v[4]) or "Sq.png"

	storyboard:newObject(img, "Background", "Center", 320, 240):add(
		table.unpack(v[5])
	)
end
for _,v in ipairs(fake_3d_square_edges_objects) do
	storyboard:addObject(v)
end

local Tri = { 200,220, 300,40, 480,340 }
local Cols = {
	{255,255,255},
	{255,0,0},
	{0,0,255},
}

local Tri2 = { 100,40, 180,100, 50,140 }
local Cols2 = {
	{255,255,0},
	{80,50,150},
	{0,255,0},
}

local TriS = sb.tri:getSpriteForTriangle(Tri, Cols)
local TriS2 = sb.tri:getSpriteForTriangle(Tri2, Cols2)

if TriS then
	storyboard:newObject(TriS.file, "Foreground", TriS.anchor, TriS.pos[1], TriS.pos[2]):add(
		{'fade',    0, {15000,30000}, 1,1},
		{'rot',     0, {15000,30000}, TriS.rot, TriS.rot},
		{'vector',  0, {15000,30000}, TriS.vector, TriS.vector},
		{'color' ,  0, {15000,30000}, TriS.col, TriS.col}
	)

	if TriS.tri2 then
		storyboard:newObject(TriS.tri2.file, "Foreground", TriS.tri2.anchor, TriS.tri2.pos[1], TriS.tri2.pos[2]):add(
			{'fade',    0, {15000,30000}, 1,1},
			{'rot',     0, {15000,30000}, TriS.tri2.rot, TriS.tri2.rot},
			{'vector',  0, {15000,30000}, TriS.tri2.vector, TriS.tri2.vector},
			{'color' ,  0, {15000,30000}, TriS.tri2.col, TriS.tri2.col}
		)
	end

	if TriS.tri3 then
		storyboard:newObject(TriS.tri3.file, "Foreground", TriS.tri3.anchor, TriS.tri3.pos[1], TriS.tri3.pos[2]):add(
			{'fade',    0, {15000,30000}, 1,1},
			{'rot',     0, {15000,30000}, TriS.tri3.rot, TriS.tri3.rot},
			{'vector',  0, {15000,30000}, TriS.tri3.vector, TriS.tri3.vector},
			{'color' ,  0, {15000,30000}, TriS.tri3.col, TriS.tri3.col}
		)
	end
end

if TriS2 then
	storyboard:newObject(TriS2.file, "Foreground", TriS2.anchor, TriS2.pos[1], TriS2.pos[2]):add(
		{'fade',    0, {15000,30000}, 1,1},
		{'rot',     0, {15000,30000}, TriS2.rot, TriS2.rot},
		{'vector',  0, {15000,30000}, TriS2.vector, TriS2.vector},
		{'color' ,  0, {15000,30000}, TriS2.col, TriS2.col}
	)

	if TriS2.tri2 then
		storyboard:newObject(TriS2.tri2.file, "Foreground", TriS2.tri2.anchor, TriS2.tri2.pos[1], TriS2.tri2.pos[2]):add(
			{'fade',    0, {15000,30000}, 1,1},
			{'rot',     0, {15000,30000}, TriS2.tri2.rot, TriS2.tri2.rot},
			{'vector',  0, {15000,30000}, TriS2.tri2.vector, TriS2.tri2.vector},
			{'color' ,  0, {15000,30000}, TriS2.tri2.col, TriS2.tri2.col}
		)
	end

	if TriS2.tri3 then
		storyboard:newObject(TriS2.tri3.file, "Foreground", TriS2.tri3.anchor, TriS2.tri3.pos[1], TriS2.tri3.pos[2]):add(
			{'fade',    0, {15000,30000}, 1,1},
			{'rot',     0, {15000,30000}, TriS2.tri3.rot, TriS2.tri3.rot},
			{'vector',  0, {15000,30000}, TriS2.tri3.vector, TriS2.tri3.vector},
			{'color' ,  0, {15000,30000}, TriS2.tri3.col, TriS2.tri3.col}
		)
	end
end

--[[for i,v in pairs(TriS) do
	print(i,v)
end--]]

-- switch between badly cropped version to better
storyboard:newObject("sb/LogoLQ.png","Background","Center", 320, 240):add(
	{'move', 0, {logo_fade_in_time,logo_fade_in_time}, {64+263,243}},
	{'fade',   0, {logo_fade_in_time, logo_fade_in_time + 500}, 0, 1},
	{'vector', 0, {logo_fade_in_time, logo_fade_in_time}, {0.5,0.5}, {0.5,0.5}},
	--{'fade',   0, {logo_fade_in_time + 1500,30000}, 1, 1},

	{'moverel', 0, {squares_fade_out_time_1 + interval_1_4, squares_fade_out_time_1 + interval_1_1*2},
		{0,0}, {320*0.65,240*0.77}},
	{'vectorrel', 0, {squares_fade_out_time_1 + interval_1_4, squares_fade_out_time_1 + interval_1_1*2},
		{1,1}, {0.32,0.56}},
	{'fade', 0, {squares_fade_out_time_1 + interval_1_4, squares_fade_out_time_1 + interval_1_1*2},
		1, 0}
)

storyboard:newObject("sb/Logo.png","Background","Center", 320, 240):add(
	{'move', 0, {squares_fade_out_time_1 + interval_1_4,squares_fade_out_time_1 + interval_1_4}, {64+263,243}},
	{'vector', 0, {squares_fade_out_time_1 + interval_1_4,squares_fade_out_time_1 + interval_1_4}, {0.5,0.5},{0.5,0.5}},

	{'moverel', 0, {squares_fade_out_time_1 + interval_1_4, squares_fade_out_time_1 + interval_1_1*2},
		{0,0}, {320*0.65,240*0.77}},
	{'vectorrel', 0, {squares_fade_out_time_1 + interval_1_4, squares_fade_out_time_1 + interval_1_1*2},
		{1,1}, {0.32,0.56}},
	{'fade', 0, {squares_fade_out_time_1 + interval_1_4, squares_fade_out_time_1 + interval_1_1*2},
		0, 1},
	{'fade',   0, {reset_time, reset_time + interval_1_1}, 1, 0}
)

interval_1_22 = sb.time:convert{redline, 0.55}
storyboard:newObject("sb/FF.png","Background","Center", 320, 240):add(
	{'fade',  'out', {FF_time                 , FF_time + interval_1_22*1.1}, 0, 0.6},
	{'fade',  'in', {FF_time + interval_1_22*1.1  , FF_time + interval_1_22*1.8}, 0.6, 0},

	{'fade',  'out', {FF_time + interval_1_22*2, FF_time + interval_1_22*3.1}, 0, 0.6},
	{'fade',  'in', {FF_time + interval_1_22*3.1, FF_time + interval_1_22*3.8}, 0.6, 0},

	{'fade',  'out', {FF_time + interval_1_22*4, FF_time + interval_1_22*5.1}, 0, 0.6},
	{'fade',  'out', {FF_time + interval_1_22*5.1, FF_time + interval_1_22*5.8}, 0.6, 0}
	--{'protract', {'param', {FF_time,FF_time}, value='a'}}
)


storyboard:newObject("bg.png", "Background", "Center", 320, 240):add(
	{'fade', 0, { {redline,0}, {redline,0} }, 0,0 }
)

storyboard:writeToFile()
