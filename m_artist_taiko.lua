package.path = "./?.lua;./?/init.lua;" .. package.path
local sb = require('sbhelper')

table.unpack = unpack or table.unpack

local x = os.clock()

--storyboard = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/2585798 Kazumi Totaka - Title Theme/Kazumi Totaka - Title Theme (Nintendo 64).osb")
storyboard_base = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/2585798 Kazumi Totaka - Title Theme/Kazumi Totaka - Title Theme (Nintendo 64).osb")
storyboard      = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/2585798 Kazumi Totaka - Title Theme/taiko.osb")

-- taiko mappers
skey     = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/2585798 Kazumi Totaka - Title Theme/skey_taiko.osb")
wth      = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/2585798 Kazumi Totaka - Title Theme/wth_taiko.osb")
ectomic  = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/2585798 Kazumi Totaka - Title Theme/ectomic_taiko.osb")
nintendo = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/2585798 Kazumi Totaka - Title Theme/nintendo_taiko.osb")

-- tsarbomba
bomba = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/2585798 Kazumi Totaka - Title Theme/bomba_horse.osb")

sb.file:setProjectFolder("/home/quake/.local/share/osu-wine/osu!/Songs/2585798 Kazumi Totaka - Title Theme/")

local taiko_width = 48
local taiko_rescale = 48/64
local underbar_y = 245
local AXX = 3 -- taiko has two additional columns because of the smaller squares
local AXX_M = 1 -- Shift logo 1 square to the right 

--- 3d
--- model
--         BPM, offset
redline = {138.37, -25}
interval_1_4 = sb.time:convert{redline, 0.25}
interval_1_2 = sb.time:convert{redline, 0.5}
interval_1_1 = sb.time:convert{redline, 1.0}
sb.m3d:setCamera({0,0,-15}, 'xyz', {0,0,0})
sb.m3d:setPerspective()

--local derpy = sb.m3d:loadModelTable('derpyflat.txt')
--
local viewport_y_s     = (480-245)/480
local viewport_x_scale = 1 / viewport_y_s
local viewport_x_add   = 854 * viewport_x_scale - 854

STAR_EPSILON = 28.0
__BOUND_X_LOW  = -107 - (viewport_x_add*0.4)
__BOUND_X_HIGH = 640  + (viewport_x_add*0.4)
__BOUND_Y_LOWEST  = 0
__BOUND_Y_LOW  = 0
__BOUND_Y_HIGH = 480


local OriginScale3D = {
	'origin_scale',
	translate = {170,underbar_y},
	scale     = {viewport_y_s, viewport_y_s},
}

local AnimPhases = require 'm_artist_anims'
local MarioStars = require 'm_artist_stars'

--storyboard:addObjectTable(AnimPhases[1](derpy, 5.5, 3.2, 40))
--storyboard:addObjectTable(AnimPhases[2](derpy, 5.5, 3.2))
--storyboard:addObjectTable(AnimPhases[3](derpy, 5.5, 3.2))
--storyboard:addObjectTable(AnimPhases[4](derpy, 5.5, 3.2))
local function append_os(p)
	for i,v in ipairs(p) do
		v:wrap(OriginScale3D)
	end
end
local function DoModel(filename, story_out, scale, y_off, sample_r, anim, anim_s, anim_o, anim_l, anim_234, anim_234_s, anim_234_o)
	local Model = sb.m3d:loadModelTable(filename)
	local p1 = AnimPhases[1](Model, scale, y_off, sample_r, anim,anim_s,anim_o, anim_l)
	local cache = sb.config["3d-time-padding"]
	sb.config["3d-time-padding"] = 4
	sb.config["3d-default-triangle-epsilon"] = 6.23
	local p2 = AnimPhases[2](Model, scale, y_off, anim_234, anim_234_s)
	local p3 = AnimPhases[3](Model, scale, y_off, anim_234, anim_234_s)
	sb.config["3d-time-padding"] = cache
	local p4 = AnimPhases[4](Model, scale, y_off, anim_234, anim_234_s, anim_234_o)
	append_os(p1)
	append_os(p2)
	append_os(p3)
	append_os(p4)
	story_out:addObjectTable(p1)
	story_out:addObjectTable(p2)
	story_out:addObjectTable(p3)
	story_out:addObjectTable(p4)
	story_out:sortByHeight()
end

sb.a3d:setViewport(__BOUND_X_LOW, __BOUND_X_HIGH, __BOUND_Y_LOW, __BOUND_Y_HIGH)

--DoModel('derpyflat.txt', skey, 5.5, 3.2, 20)
sb.config["3d-default-triangle-epsilon"] = 5.73
sb.config["3d-time-padding"] = 76
sb.config["3d-scale-padding"] = 4.6
DoModel('derpies.txt', bomba, 5.5, 3.2, 180, 'DerpyWalk', 1.0, 0.0, true)
sb.config["3d-default-triangle-epsilon"] = 5.43-1.7
sb.config["3d-time-padding"] = 46
sb.config["3d-scale-padding"] = 4.0
DoModel('mega.txt', skey, 6.3, 3.2, 180, 'MegaAction', 0.99, 0.25, false, 'MegaIdle', 2.7, 0.0)
sb.config["3d-default-triangle-epsilon"] = 2.23
sb.config["3d-time-padding"] = 15
sb.config["3d-scale-padding"] = 3.5
DoModel('rhombi.txt', ectomic, 5.5, 3.2, 120, 'RhombiAction', 0.95, -0.11, false)

append_os(MarioStars.stars)
append_os(MarioStars.trails)
storyboard_base:addObjectTable(MarioStars.stars)
storyboard_base:addObjectTable(MarioStars.trails)
--
storyboard:newObject("sb/ScreenGap.png","Background","TopRight", 640+107, 0):add(
	{'fade',0,{{redline,1.9},{redline,2.5}},0,1},
	{'fade','cubicOut',{{redline,7.6*4},{redline,8.3*4}},1,0}
)
storyboard:newObject("sb/ScreenGap.png","Background","TopLeft", -107, 0):add(
	{'fade',0,{{redline,1.01*4},{redline,1.3*4}},0,1},
	{'fade','cubicOut',{{redline,7.6*4},{redline,8.3*4}},1,0}
)

--storyboard:sortByHeight()

local tiles = {{1,3},{1,4},{2,3},{2,4},{3,1},{3,2},{3,3},{3,4},{4,0},{4,1},{4,2},{4,3},{4,4},{5,0},{5,1},{5,2},{5,3},{5,4},{6,0},{6,1},{6,2},{6,3},{6,4},{7,3},{7,4},{8,3},{8,4},
}
local tiles_replace_with_square = {
	{1+AXX_M,3+3},
	{2+AXX_M,3+3},
	{3+AXX_M,3+3},
	{4+AXX_M,3+3},
	{5+AXX_M,3+3},
	{6+AXX_M,3+3},
	{7+AXX_M,3+3},
	{8+AXX_M,3+3},
	{1+AXX_M,4+3},
	{2+AXX_M,4+3},
	{3+AXX_M,4+3},
	{4+AXX_M,4+3},
	{5+AXX_M,4+3},
	{6+AXX_M,4+3},
	{7+AXX_M,4+3},
	{8+AXX_M,4+3},
}

function tileAfterLogo(X,Y)
	for _,v in ipairs(tiles_replace_with_square) do
		if v[1]==X and v[2]==Y then


			if X==4 and Y==3+3 then
				return "sb/t/43N.png"
			end
			if X==5 and Y==3+3 then
				return "sb/t/53N.png"
			end

			return "Sq.png"
		end
	end
	return nil
end

function tileHasImg(X,Y)
	for _,v in ipairs(tiles) do
		if v[1]==X-AXX_M and v[2]==Y-3 then return "sb/t/"..(X-AXX_M)..(Y-3)..".png" end
	end
end

-- { x , y , xi, yi, {commands} }
local std_squares = {}
local std_fadein_times = {}
local std_fadein_flipd = {}


local std_squares_2 = {}
local std_fadein_times_2 = {}
local std_fadein_flipd_2 = {}

local X_OFF = taiko_width/4.0

for x=-2, 11+AXX do
	std_fadein_times[x] = {}
	std_fadein_flipd[x] = {}

	std_fadein_times_2[x] = {}
	std_fadein_flipd_2[x] = {}
end

local start_time = sb.time:convert{redline, 0.25}
local target_time = sb.time:convert{redline, 13}
local DT = (target_time-start_time) / ((10+AXX)*8)
local steps = 0
local X,Y = 0,0
local DX,DY = 1,0

local logo_fade_in_time = sb.time:convert{redline, 12.75}
local FF_time = sb.time:convert{redline, 28}

local squares_fade_out_time_1 = sb.time:convert{redline, 30.75}

local start_time_2 = sb.time:convert{redline, 16*4+1}
local end_time_2 = sb.time:convert{redline, 18*4+2}
local squares_fade_out_time_2a = sb.time:convert{redline, 20*4+1}
local squares_fade_out_time_2b = sb.time:convert{redline, 22*4+2}

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
	if X== -1 or Y == -1 or X==10+AXX or Y==8 or std_fadein_times[X][Y] ~= nil then
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
		std_fadein_flipd[10+AXX][y] = 2
		std_fadein_flipd[11+AXX][y] = 2
	if y>0 then
		std_fadein_times[-2][y] = std_fadein_times[0][y]
		std_fadein_times[-1][y] = std_fadein_times[0][y]
	else
		std_fadein_times[-2][0] = std_fadein_times[0][1]+DT
		std_fadein_times[-1][0] = std_fadein_times[0][1]+DT
	end
	
	std_fadein_times[10+AXX][y] = std_fadein_times[9+AXX][y]
	std_fadein_times[11+AXX][y] = std_fadein_times[9+AXX][y]
end
--std_fadein_times[-2][0] = std_fadein_times[-2][1]
--std_fadein_times[-1][0] = std_fadein_times[-1][1]
for y=0,7 do
	--if y>0 then
		std_fadein_times[-2][y] = std_fadein_times[-2][y]+DT+DT
		std_fadein_times[-1][y] = std_fadein_times[-1][y]+DT
	--end
	std_fadein_times[10+AXX][y] = std_fadein_times[10+AXX][y]+DT
	std_fadein_times[11+AXX][y] = std_fadein_times[11+AXX][y]+DT+DT
end

math.randomseed(66663)
-- Tiles 2
for x=-2,11+AXX do
	local D = end_time_2 - start_time_2
	for y=0,8 do
		local R = math.random() -- random fade in time
		std_fadein_times_2[x][y] = start_time_2 + D*R
		R = math.random()
		R = math.floor(R)*5
		if R<1 then R = -2 -- random flip direction
		elseif R<2 then R = 2
		elseif R<3 then R = 1
		else R=-1 end
	end
end

local fake_3d_square_edges_objects = {}

math.randomseed(500)

local sfx_count = 0
--- Tiles In
---
---
for x = 0 - (taiko_width)*2, 640+taiko_width*2-1, taiko_width do
	if x/taiko_width >= 12+AXX then break end
	for Y = 0, 480, taiko_width do
		local y = Y
		local offset_added = false
		if y >= taiko_width*3 then
			y = (Y-taiko_width*3) + underbar_y
			offset_added = true
		end

		local Sq = {x + taiko_width/2.0 , y + taiko_width/2.0, math.floor(x/taiko_width), math.floor(y/taiko_width), {}}
		if offset_added then Sq[4]=Sq[4]-2 end
		if Sq[4]==8 then break end
		table.insert(std_squares, Sq)

		local Sq2 = {x + taiko_width/2.0 , y + taiko_width/2.0, math.floor(x/taiko_width), math.floor(y/taiko_width), {}}
		if offset_added then Sq2[4]=Sq2[4]-2 end
		table.insert(std_squares_2, Sq2)

		local Sq_time_in = std_fadein_times[Sq[3]][Sq[4]]
		table.insert(Sq[5], {'move'  , 'linear',  {Sq_time_in, Sq_time_in}, {Sq[1]+X_OFF,Sq[2]}, {Sq[1]+X_OFF,Sq[2]}})
		table.insert(Sq[5], {'fade'  , 'linear',  {Sq_time_in, Sq_time_in}, 0, 1})

		local Sq_time_in_2 = std_fadein_times_2[Sq2[3]][Sq2[4]]
		table.insert(Sq2[5], {'move'  , 'linear',  {Sq_time_in_2, Sq_time_in_2}, {Sq2[1]+X_OFF,Sq2[2]}, {Sq2[1]+X_OFF,Sq2[2]}})
		table.insert(Sq2[5], {'fade'  , 'linear',  {Sq_time_in_2, Sq_time_in_2}, 0, 1})

		local flipd = std_fadein_flipd[Sq[3]][Sq[4]]
		local edge_v = {}
		local vec1, vec2
		if flipd==1 then
			vec1,vec2 = {0,taiko_rescale},{taiko_rescale,taiko_rescale}
			edge_v = {29*taiko_rescale,0}
		elseif flipd==-1 then
			vec1,vec2 = {0,taiko_rescale},{taiko_rescale,taiko_rescale}
			edge_v = {-29*taiko_rescale,0}
		elseif flipd==2 then
			vec1,vec2 = {taiko_rescale,0},{taiko_rescale,taiko_rescale}
			edge_v = {0,29*taiko_rescale}
		elseif flipd==-2 then
			vec1,vec2 = {taiko_rescale,0},{taiko_rescale,taiko_rescale}
			edge_v = {0,-29*taiko_rescale}
		end

		if tileHasImg(Sq[3],Sq[4]) then
			vec1[1] = vec1[1] * 0.5
			vec2[1] = vec2[1] * 0.5
			vec1[2] = vec1[2] * 0.5
			vec2[2] = vec2[2] * 0.5
		end

		local flipd_2 = std_fadein_flipd[Sq2[3]][Sq2[4]]
		local edge_v_2 = {}
		local vec1_2, vec2_2
		if flipd_2==1 then
			vec1_2,vec2_2 = {0,taiko_rescale},{taiko_rescale,taiko_rescale}
			edge_v_2 = {29*taiko_rescale,0}
		elseif flipd_2==-1 then
			vec1_2,vec2_2 = {0,taiko_rescale},{taiko_rescale,taiko_rescale}
			edge_v_2 = {-29*taiko_rescale,0}
		elseif flipd_2==2 then
			vec1_2,vec2_2 = {taiko_rescale,0},{taiko_rescale,taiko_rescale}
			edge_v_2 = {0,29*taiko_rescale}
		elseif flipd_2==-2 then
			vec1_2,vec2_2 = {taiko_rescale,0},{taiko_rescale,taiko_rescale}
			edge_v_2 = {0,-29*taiko_rescale}
		end

		if tileHasImg(Sq2[3],Sq2[4]) then
			vec1_2[1] = vec1_2[1] * 0.5
			vec2_2[1] = vec2_2[1] * 0.5
			vec1_2[2] = vec1_2[2] * 0.5
			vec2_2[2] = vec2_2[2] * 0.5
		end

		if (Sq[3] >= 0) and (Sq[3] <= 9+AXX) and (Sq[3]+Sq[4])%1==0 then
			storyboard:newObject('sb/s.wav', 'Background', Sq_time_in+DT*0.3, 70)
		end
		if (Sq2[3] >= 0) and (Sq2[3] <= 9+AXX) and (Sq2[3]+Sq2[4])%1==0 then
			storyboard:newObject('sb/s.wav', 'Background', Sq_time_in_2+DT*0.3, 70)
		end
		sfx_count = sfx_count+1

		table.insert(Sq[5], {'vector', 'sineOut', {Sq_time_in + DT*0.1, Sq_time_in + DT*3.5}, vec1, vec2})
		table.insert(Sq[5], {'color', 'sineOut' , {Sq_time_in + DT*0.1, Sq_time_in + DT*3.5}, {99,99,99},{255,255,255}})
		table.insert(Sq2[5], {'vector', 'sineOut', {Sq_time_in_2 + DT*0.1, Sq_time_in_2 + DT*3.5}, vec1, vec2})
		table.insert(Sq2[5], {'color', 'sineOut' , {Sq_time_in_2 + DT*0.1, Sq_time_in_2 + DT*3.5}, {99,99,99},{255,255,255}})

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
				{'move'  , 'linear',  {TT,TT}, {Sq[1]+X_OFF,Sq[2]}, {Sq[1]+X_OFF,Sq[2]}},
				{'fade'  , 'linear',  {squares_fade_out_time_1+interval_1_2+D_sq,
																								 squares_fade_out_time_1+interval_1_1+D_sq}, 1, 0},
				{'vector', 'sineOut', {squares_fade_out_time_1 + DT*0.1+D_sq, squares_fade_out_time_1 + DT*6.5+D_sq},
					_v2, _v1}
			)
		end

		table.insert(Sq2[5], {'fade'  , 'linear',  {squares_fade_out_time_2a,
																							 squares_fade_out_time_2b}, 1, 0})
		--table.insert(Sq2[5], {'vector', 'sineOut', {squares_fade_out_time_2a + DT*0.1+D_sq, squares_fade_out_time_2a + DT*6.5+D_sq}, vec1, vec2})

		local rot = nil
		if flipd == 2 or flipd == -2 then
			rot = {'rotate', 0, {Sq_time_in,Sq_time_in}, math.pi/2, math.pi/2}
		else
			rot = {'rotate', 0, {Sq_time_in,Sq_time_in}, 0}
		end

		local rot_2 = nil
		if flipd_2 == 2 or flipd_2 == -2 then
			rot = {'rotate', 0, {Sq_time_in_2,Sq_time_in_2}, math.pi/2, math.pi/2}
		else
			rot = {'rotate', 0, {Sq_time_in_2,Sq_time_in_2}, 0}
		end

		table.insert(fake_3d_square_edges_objects,
		storyboard:newObject("sb/E.png", "Background", "Center", 320, 240):add(
			{'fade',  1        , {Sq_time_in + DT*0.1, Sq_time_in + DT*0.2}, 0,1 },
			{'scale',  1        , {Sq_time_in + DT*0.1}, taiko_rescale },
			--{'color', 'sineout', {Sq_time_in + DT*0.1, Sq_time_in + DT*3.4}, {233,233,233},{50,50,50} },
			{'fade',  1        , {Sq_time_in + DT*3.2, Sq_time_in + DT*3.4}, 1,0 },
			{'move', 'sineOut', {Sq_time_in + DT*0.1, Sq_time_in + DT*3.5}, {Sq[1]+X_OFF,Sq[2]}, {Sq[1]+edge_v[1]+X_OFF,Sq[2]+edge_v[2]}},
			rot
		))
		table.insert(fake_3d_square_edges_objects,
		storyboard:newObject("sb/E.png", "Background", "Center", 320, 240):add(
			{'fade',  1        , {Sq_time_in_2 + DT*0.1, Sq_time_in_2 + DT*0.2}, 0,1 },
			{'scale',  1        , {Sq_time_in_2 + DT*0.1}, taiko_rescale },
			--{'color', 'sineout', {Sq_time_in_2 + DT*0.1, Sq_time_in_2 + DT*3.4}, {233,233,233},{50,50,50} },
			{'fade',  1        , {Sq_time_in_2 + DT*3.2, Sq_time_in_2 + DT*3.4}, 1,0 },
			{'move', 'sineOut', {Sq_time_in_2 + DT*0.1, Sq_time_in_2 + DT*3.5}, {Sq2[1]+X_OFF,Sq2[2]}, {Sq2[1]+edge_v_2[1]+X_OFF,Sq2[2]+edge_v_2[2]}},
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
for _,v in ipairs(std_squares_2) do
	local img = tileHasImg(v[3],v[4]) or "Sq.png"

	storyboard:newObject(img, "Background", "Center", 320, 240):add(
		table.unpack(v[5])
	)
end
for _,v in ipairs(fake_3d_square_edges_objects) do
	storyboard:addObject(v)
end

storyboard:newObject("sb/CC.jpg", "Background", "Center", 320, 47):add(
	{'fade', 0, {{redline,3*4}}, 1},
	{'scale', 0,{{redline,3*4}}, 0.5*taiko_rescale},
	{'move', 0, {{redline,3*4}, {redline,3*4+3}}, {-300,47}, {320,47}},
	{'fade', 0, {{redline,8*4+1}}, 0},
	{'move', 0, {{redline,7*4+2}, {redline,7*4+5}}, {320,47}, {940,47}}
)
storyboard:newObject("sb/dot.png", "Background", "Center", 320, 90):add(
	{'fade', 0, {{redline,3*4}}, 1},
	{'scale', 0,{{redline,3*4}}, 0.5*taiko_rescale},
	{'move', 0, {{redline,3*4}, {redline,3*4+3}}, {940,90}, {320,90}},
	{'fade', 0, {{redline,8*4+1}}, 0},
	{'move', 0, {{redline,7*4+2}, {redline,7*4+5}}, {320,90}, {-300,90}}
)
storyboard:newObject("sb/Pstart.png", "Background", "Center", 320, 90):add(
	{'fade', 0, {{redline,5*4}, {redline,5*4+2}} ,0,1},
	{'fade', 0, {{redline,5*4+2}, {redline,5*4+4}} ,1,0.7},
	{'fade', 0, {{redline,5*4+4}, {redline,5*4+6}} ,0.7,1},
	{'fade', 0, {{redline,5*4+6}, {redline,5*4+8}} ,1,0.7},
	{'fade', 0, {{redline,5*4+8}, {redline,5*4+10}} ,0.7,1},
	{'scale', 0, {{redline,3*4}}, 0.5*taiko_rescale},
	{'move', 0, {{redline,3*4}, {redline,3*4+3}}, {-300,90}, {320,90}},
	{'fade', 0, {{redline,8*4+1}}, 0},
	{'move', 0, {{redline,7*4+2}, {redline,7*4+5}}, {320,90}, {-300,90}}
)

storyboard:newObject("sb/CC.jpg", "Background", "Center", 320, 47):add(
	{'fade', 0, {{redline,3*4 + 16*4}}, 1},
	{'scale', 0,{{redline,3*4 + 16*4}}, 0.5*taiko_rescale},
	{'move', 0, {{redline,3*4 + 16*4}, {redline,3*4+3 + 16*4}}, {-300,47}, {320,47}},
	{'color', 0, { squares_fade_out_time_2a, squares_fade_out_time_2b }, {255,255,255},{0,0,0}},
	{'fade', 0, { squares_fade_out_time_2b, squares_fade_out_time_2b }, 0,0}
)
storyboard:newObject("sb/dot.png", "Background", "Center", 320, 90):add(
	{'fade', 0, {{redline,3*4 + 16*4}}, 1},
	{'scale', 0,{{redline,3*4 + 16*4}}, 0.5*taiko_rescale},
	{'move', 0, {{redline,3*4 + 16*4}, {redline,3*4+3 + 16*4}}, {940,90}, {320,90}},
	{'color', 0, {squares_fade_out_time_2a, squares_fade_out_time_2b}, {255,255,255},{0,0,0}},
	{'fade', 0, {squares_fade_out_time_2b, squares_fade_out_time_2b}, 0,0}
)
storyboard:newObject("sb/Pstart.png", "Background", "Center", 320, 90):add(
	{'fade', 0, {{redline,4*4 + 16*4-1}, {redline,4*4+1 + 16*4}} ,0,1},
	{'scale', 0,{{redline,3*4 + 16*4}}, 0.5*taiko_rescale},
	{'move', 0, {{redline,3*4 + 16*4}, {redline,3*4+3 + 16*4}}, {-300,90}, {320,90}},
	{'color', 0, {squares_fade_out_time_2a, squares_fade_out_time_2b}, {255,255,255},{0,0,0}},
	{'fade', 0, {squares_fade_out_time_2b, squares_fade_out_time_2b}, 0,0}
)

local LogoPosX, LogoPosY = 319-16+2,420+14-6
local LogoPosX2, LogoPosY2 = 535,426
local LogoScale = taiko_rescale

-- switch between badly cropped version to better
storyboard:newObject("sb/LogoLQ.png","Background","Center", 320, 240):add(
	{'move', 0, {logo_fade_in_time,logo_fade_in_time}, {LogoPosX,LogoPosY}},
	{'fade',   0, {logo_fade_in_time, logo_fade_in_time + 500}, 0, 1},
	{'scale', 0, {logo_fade_in_time}, {0.5*LogoScale} },
	--{'fade',   0, {logo_fade_in_time + 1500,30000}, 1, 1},

	--{'moverel', 0, {squares_fade_out_time_1 + interval_1_4, squares_fade_out_time_1 + interval_1_1*2},
	--	{0,0}, {320*0.65,240*0.77}},
	{'move', 0, {squares_fade_out_time_1 + interval_1_4, squares_fade_out_time_1 + interval_1_1*2},
		{LogoPosX,LogoPosY}, {LogoPosX2, LogoPosY2}},
	{'vectorrel', 0, {squares_fade_out_time_1 + interval_1_4, squares_fade_out_time_1 + interval_1_1*2},
		{1,1}, {0.32/taiko_rescale,0.56/taiko_rescale}},
	{'fade', 0, {squares_fade_out_time_1 + interval_1_4, squares_fade_out_time_1 + interval_1_1*2},
		1, 0}
)

storyboard:newObject("sb/Logo.png","Background","Center", 320, 240):add(
	{'move', 0, {squares_fade_out_time_1 + interval_1_4,squares_fade_out_time_1 + interval_1_4}, {LogoPosX,LogoPosY}},
	{'scale', 0, {squares_fade_out_time_1 + interval_1_4}, 0.5*LogoScale},

	{'move', 0, {squares_fade_out_time_1 + interval_1_4, squares_fade_out_time_1 + interval_1_1*2},
		{LogoPosX,LogoPosY}, {LogoPosX2, LogoPosY2}},
	{'vectorrel', 0, {squares_fade_out_time_1 + interval_1_4, squares_fade_out_time_1 + interval_1_1*2},
		{1,1}, {0.32/taiko_rescale,0.56/taiko_rescale}},
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
storyboard:newObject("bg.jpg", "Background", "Center", 320, 240):add(
	{'fade', 0, { {redline,0}, {redline,0} }, 0,0 }
)

local params = { pool_sprites = sb.tri.file_set }
storyboard_base:writeToFile2(nil, params)
sb.config['silence-headers'] = true

-- disable pooling 4 compile speeed
--params = nil
storyboard:writeToFile2(nil, params)

-- write mapper specific model events
skey:writeToFile2(nil, params)
wth:writeToFile2(nil, params)
ectomic:writeToFile2(nil, params)
bomba:writeToFile2(nil, params)

--storyboard:writeToFile2(nil, {pool_sprites=sb.tri.file_set})
print(string.format("elapsed time: %.2f\n", os.clock() - x))
