-- camera data from blender can be used in 3d animations
--
local modules = (...):gsub('%.[^%.]+$', '') .. "."
local cpml = require (modules..'cpml')
local sb_log = require (modules..'log')
local sb_m3d = require (modules..'model')

local c3d = {}
c3d.__index = c3d

function c3d:loadFile(filename)
	local ct = dofile(filename)
	
	table.sort(ct.frames, function(a,b) return a.frame < b.frame end)

	local camera_frames = {}
	local min_i =  1.0/0.0
	local max_i = -1.0/0.0

	for i,v in ipairs(ct.frames) do
		local frame = v.frame

		if min_i>frame then min_i=frame end
		if max_i<frame then max_i=frame end

		camera_frames[frame] = v
		v.fov_x = v.fov_x * (180/math.pi)
		v.fov_y = v.fov_y * (180/math.pi)
	end

	camera_frames.fps = ct.fps
	camera_frames.first = min_i
	camera_frames.last  = max_i

	return camera_frames
end

function c3d:getCameraFrame(c_t, time, loop)
	local dT = 1.0 / c_t.fps  -- time per frame

	local frame_t = time / dT

	local start_i = c_t.first
	local end_i   = c_t.last

	local frame_i = start_i + frame_t

	local fi1, fi2

	if not loop and frame_i < start_i then frame_i = start_i end
	if not loop and frame_i > end_i   then frame_i = end_i end
	if not loop then
		fi1 = math.floor(frame_i)
		fi2 = math.ceil(frame_i)

		if fi1==fi2 then fi2=fi1+1 end
		if fi2 > end_i then fi2 = end_i end
	else
		local wrap = math.fmod(frame_t, end_i-start_i)
		if wrap<0 then wrap = wrap + end_i-start_i end -- ensure positive

		frame_i = start_i + wrap
		fi1 = math.floor(frame_i)
		fi2 = math.ceil(frame_i)

		if fi1==fi2 then fi2=fi1+1 end
		if fi2 > end_i then fi2 = start_i end
	end

	if fi1 < start_i then fi1=start_i end
	if fi2 > end_i then fi2=end_i end

	local interp_i = frame_i - fi1
	return c3d:interpolateFrames(c_t, c_t[fi1], c_t[fi2], interp_i)
end

-- returns position, rotation (quaternion) and fov
function c3d:interpolateFrames(m_t, frame1, frame2, interp)
	local frame_interp   = interp
	local frame_interp_i = 1.0 - interp

	local Pos, Fov, Quat

	Pos = {
		frame1.position[1]*frame_interp + frame2.position[1]*frame_interp_i ,
		frame1.position[2]*frame_interp + frame2.position[2]*frame_interp_i ,
		frame1.position[3]*frame_interp + frame2.position[3]*frame_interp_i
	}
	Fov = frame1.fov_y * frame_interp + frame2.fov_y * frame_interp_i

	local quat1,quat2 = cpml.quat.new(frame1.rotation[2], frame1.rotation[3], frame1.rotation[4], frame1.rotation[1]),
	                    cpml.quat.new(frame2.rotation[2], frame2.rotation[3], frame2.rotation[4], frame2.rotation[1])
	Quat = cpml.quat.slerp(quat1,quat2,frame_interp)

	return Pos,Quat,Fov
end

return c3d
