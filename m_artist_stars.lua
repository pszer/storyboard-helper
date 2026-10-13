package.path = "./?.lua;./?/init.lua;" .. package.path
local sb = require('sbhelper')
redline = {138.37, -25}

local Phases = require 'm_artist_anims'

local times1 = { sb.time:convert{redline,8.5*4},sb.time:convert{redline,15*4} }
local times2 = { sb.time:convert{redline,15*4  },sb.time:convert{redline,15*4+1} }
local times3 = { sb.time:convert{redline,15*4+1},sb.time:convert{redline,15*4+2} }
local times4 = { sb.time:convert{redline,15*4+2},sb.time:convert{redline,15*4+3.2} }

local __Format = 
{
	{
	'VertexPosition', 'float', 3
	},
	{
	'VertexNormal', 'float', 3
	},
	{
	'VertexColor', 'byte', 3
	},

	['VertexPosition'] = {1,3},
	['VertexNormal'] = {4,6},
	['VertexColor'] = {7,9},
}
local __temp_vert = {}
local function CreateVertex(x,y,z)
	return { x,y,z, 0,1,0, 255,255,255 }
end

local Stars1 = {out={}}
local Stars2 = {out={}}
local Stars3 = {out={}}
local Stars4 = {out={}}

local function CreateStarAt(time, pos, vector, end_time)
	return {time, pos, vector, time=time, pos=pos, vector=vector, end_time=end_time}
end

local SampleRate = 80

local Near = -25*4.5
local Far  =  25*4.5
local Phase1Vel = 42
local Trail = -0.40
local Radius = 12

math.randomseed(32318352800)
for t=times1[1]-2200,times1[2],60 do
	local Rand = math.random() * math.pi*16
	local Rand2 = math.random() * Radius + 9
	local end_time = (Far-Near)/Phase1Vel
	table.insert(Stars1, CreateStarAt(t-times1[1], { math.sin(Rand)*Rand2, math.cos(Rand)*Rand2, Near}, {0,0,Phase1Vel},
	                                  t-times1[1] + end_time*1000 ))
end

local Phase2X = 18
local Phase2Vel = 19*2
for t=times2[1]-3000,times2[2]+1500,100 do
	local Rand = (math.random()*15-7.5)*1.3
	local end_time = (Phase2X-(-Phase2X))/Phase2Vel
	table.insert(Stars2, CreateStarAt(t-times2[1], {-Phase2X,Rand,40}, {Phase2Vel,0,0}, t + end_time*1000-times2[1]))
end

for t=times3[1]-1500,times3[2],100 do
	local Rand = (math.random()*15-7.5)*1.3
	local end_time = (Phase2X-(-Phase2X))/Phase2Vel
	table.insert(Stars3, CreateStarAt(t-times3[1], {Phase2X,Rand,40}, {-Phase2Vel,0,0}, t + end_time*1000-times3[1]))
end

for t=times4[1]-8000,times4[2]+1500,50 do
	local Rand = math.random() * math.pi*16
	local Rand2 = math.random() * Radius + 9
	local end_time = (Far-Near)/Phase1Vel
	table.insert(Stars4, CreateStarAt(t-times4[1], { math.sin(Rand)*Rand2, math.cos(Rand)*Rand2, Near}, {0,0,Phase1Vel},
	                                  t-times4[1] + end_time*1000 ))
end

sb.m3d:setPerspective(70, 'wide')
local id = {1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1}
local id_mat = sb.cpml.mat4.new()
for i=1,16 do id_mat[i] = id[i] end
local function DoStars(stars, time)
	local TTTT = time
	time=time/1000
	local cam, proj = sb.m3d:getViewAndProjMats()

	for _,Star in ipairs(stars) do
			if not stars.out[Star] then stars.out[Star]={} end
		if time*1000 >= Star.time and time*1000 <= Star.end_time then
			local Pos = {Star.pos[1], Star.pos[2], Star.pos[3]}
			Pos[1] = Pos[1] + Star.vector[1] * (time - Star.time/1000)
			Pos[2] = Pos[2] + Star.vector[2] * (time - Star.time/1000)
			Pos[3] = Pos[3] + Star.vector[3] * (time - Star.time/1000)
			local Vert = CreateVertex(Pos[1], Pos[2], Pos[3])

			local Vpos, _, _, star_x, star_y = sb.m3d:vertexOut(Vert, __Format, id_mat, cam, proj, nil)

			Pos[1] = Star.pos[1] + Star.vector[1] * (time - Star.time/1000) + Star.vector[1] * Trail
			Pos[2] = Star.pos[2] + Star.vector[2] * (time - Star.time/1000) + Star.vector[2] * Trail
			Pos[3] = Star.pos[3] + Star.vector[3] * (time - Star.time/1000) + Star.vector[3] * Trail
			Vert = CreateVertex(Pos[1], Pos[2], Pos[3])

			local V_tpos, _, _, trail_x, trail_y = sb.m3d:vertexOut(Vert, __Format, id_mat, cam, proj, nil)

			local Keyframe_Data = { TTTT, star_x, star_y, ['z'] = Vpos.z, trail_x=trail_x, trail_y=trail_y, trail_z = V_tpos.z }

			table.insert(stars.out[Star], Keyframe_Data)
		end
	end
end
--
--
--

for t=times1[1],times1[2],SampleRate do
	local pos, rt, rot = Phases.cams[1](t-times1[1])
	--sb.m3d:setCamera( {0,0,0}, rt, rot )
	--sb.m3d:setCamera( {0,2.5,0}, rt, rot )
	--print(rt, rot[1], rot[2], rot[3])
	sb.m3d:setCamera( pos, rt, rot )
	--sb.m3d:setCamera( {Radius,0,0}, 'xyz', {0,(t/300) *math.pi/2,0} )
	--sb.m3d:setCamera( {0,0,0}, 'xyz', {0, -1.9 * (t-times1[1])/2000.0, 0} )
	DoStars(Stars1, t-times1[1])
end
for t=times2[1],times2[2],SampleRate do
	local pos, rt, rot = Phases.cams[2](t-times2[1])
	sb.m3d:setCamera( {0,0,0}, rt, rot )
	DoStars(Stars2, t-times2[1])
end
for t=times3[1],times3[2],SampleRate do
	local pos, rt, rot = Phases.cams[3](t-times3[1])
	sb.m3d:setCamera( {0,0,0}, rt, rot )
	DoStars(Stars3, t-times3[1])
end
for t=times4[1],times4[2],SampleRate do
	local pos, rt, rot = Phases.cams[4](t-times4[1])
	sb.m3d:setCamera( {0,0,0}, rt, rot )
	DoStars(Stars4, t-times4[1])
end


local function OutStars(stars, start_time, out, out_trails)
	for _,Star in ipairs(stars) do
		local Coms = {}
		local ComsTrail = {}

		local outframe = stars.out[Star]
		outframe = sb.keyframe:simplify(outframe, { epsilon = 9.0 })

		local rendered = false
		local faded = true
		local last_angle = nil
		local last_length = nil
		for i=1,#outframe-1 do
			local o1, o2 = outframe[i],outframe[i+1]

			-- ignore stars behind camera or outside screen, and append a fade to zero
			if (o1.z < 3.5 or o2.z < 3.5 or o1.trail_z < 3.5 or o2.trail_z < 3.5) or
				 ( ( o1[2]< -107 or o1[2]>640 or o1[3] < 0 or o1[3] > 480 )
			 		  and
				   ( o2[2]< -107 or o2[2]>640 or o2[3] < 0 or o2[3] > 480)
					 and
					 ( o1.trail_x< -107 or o1.trail_x>640 or o1.trail_y < 0 or o1.trail_y > 480 )
			 		  and
				   ( o2.trail_x< -107 or o2.trail_x>640 or o2.trail_y < 0 or o2.trail_y > 480)

				 )
			then
				if rendered then
					table.insert(Coms, {'fade', 0, {o1[1]+start_time}, 0,0})
					table.insert(ComsTrail, {'fade', 0, {o1[1]+start_time}, 0,0})
				end
				rendered = false
				faded = true
				last_angle = nil
				last_length = nil
			elseif o1[1]~=o2[1] then
				-- Make visible
				if not rendered then
					table.insert(Coms, {'fade', 0, {o1[1]+start_time}, 0.8,0.8})
					table.insert(ComsTrail, {'fade', 0, {o1[1]+start_time}, 0.65})
					rendered = true
					faded = false
				end

				table.insert(Coms, {'move', 0, {o1[1]+start_time, o2[1]+start_time},
					{o1[2], o1[3]},
					{o2[2], o2[3]}})
				table.insert(Coms, {'scale', 0, {o1[1]+start_time, o2[1]+start_time},
					{22.0 / o1.z},
					{22.0 / o2.z}})

				table.insert(ComsTrail, {'move', 0, {o1[1]+start_time, o2[1]+start_time},
					{o1[2], o1[3]},
					{o2[2], o2[3]}})
				--local Dx = o2[2] - o1[2]
				--local Dy = o2[3] - o1[3]
				--local Dx = o2.trail_x - o1.trail_x
				--local Dy = o2.trail_y - o1.trail_y
				local Dx = o1[2] - o1.trail_x
				local Dy = o1[3] - o1.trail_y
				local length = math.sqrt(Dx*Dx + Dy*Dy)
				local sprite_length = 64.0

				local Dx2 = o2[2] - o2.trail_x
				local Dy2 = o2[3] - o2.trail_y
				local length2 = math.sqrt(Dx2*Dx2 + Dy2*Dy2)
				local sprite_length = 64.0

				local angle = math.atan(-Dy,-Dx)
			--	
	
				if last_angle then
					if angle > last_angle+math.pi then
						angle = angle - 2*math.pi
					elseif angle < last_angle - math.pi then
						angle = angle + 2*math.pi
					end
				end

				table.insert(ComsTrail, {'rot', 0, {o1[1]+start_time, o2[1]+start_time},
					{(last_angle or angle)},
					{angle}})
				table.insert(ComsTrail, {'vector', 0, {o1[1]+start_time, o2[1]+start_time},
					{ length/sprite_length, 22.0 / o1.z },
					{ length2/sprite_length, 22.0 / o2.z}})

				last_angle = angle
				last_length = length
			end
		end

		-- force fade to 0 at end, if not already faded
		if not faded then
			table.insert(Coms, {'fade', 0, { outframe[#outframe][1] + start_time }, 0,0})
			table.insert(ComsTrail, {'fade', 0, { outframe[#outframe][1] + start_time }, 0,0})
		end
		table.insert(out, Coms)
		table.insert(out_trails, ComsTrail)
	end

	return out, out_trails
end

local stars_coms, trails_coms = {}, {}
OutStars(Stars1, times1[1], stars_coms, trails_coms)
OutStars(Stars2, times2[1], stars_coms, trails_coms)
OutStars(Stars3, times3[1], stars_coms, trails_coms)
OutStars(Stars4, times4[1], stars_coms, trails_coms)

local s_objs, t_objs = {},{}
for _,Star_out in ipairs(stars_coms) do
	table.insert(s_objs,
		sb.object:new(
			"sb/Star.png",
			"Background",
			"Centre",0,0
		):add(sb.unpack(Star_out))
	)
end
for _,Trail_out in ipairs(trails_coms) do
	table.insert(t_objs,
		sb.object:new(
			"sb/StarTrail.png",
			"Background",
			"CentreLeft",0,0
		):add(sb.unpack(Trail_out))
	)
end

local view,proj = sb.m3d:getViewAndProjMats()
return { stars = s_objs, trails = t_objs }
