package.path = "./?.lua;./?/init.lua;" .. package.path
local sb = require('sbhelper')

local view,proj = sb.m3d:getViewAndProjMats()
local light_dir = {0,1/2^0.5,-1/2^0.5}

local camera_func_1 = function(t)
	local pos = {0,15.5,-25}
	pos[3] = pos[3] + 10* math.min(1, (1 - (2 - t/1000)/2)^3)
	pos[2] = pos[2] - 13 * math.min(1, (1 - (2 - t/1000)/2)^3)
									+ (t>2000 and -5.0 * math.sin((t-2000)/1150) or 0.0)
	t = 1.9 * t / 2000
	local rot_x = math.sin(t)*pos[3] - math.cos(t)*pos[1]
	local rot_z = math.cos(t)*pos[3] + math.sin(t)*pos[1]
	pos[1] = rot_x
	pos[3] = rot_z
	return pos, 'lookat', {pos[1],pos[2],pos[3]} end
local camera_func_2 = function(t)
	local pos = {0,0,-12}
	pos[3] = pos[3]
	pos[2] = pos[2]
	return pos, 'xyz', {0,0,0}
end
local camera_func_3 = function(t)
	local pos = {0,0,-12}
	pos[3] = pos[3]
	pos[2] = pos[2]
	return pos, 'xyz', {0,0,0}
end
local camera_func_4 = function(t)
	local pos = {0, 0.8, -9 + (-16)*(1 - t/500)}
	pos[3] = pos[3]
	pos[2] = pos[2]
	return pos, 'xyz', {0,0,0}
end

local function Phase1(m, scale, cam_y_off, resolution, anim, anim_s)
	local resolution = resolution or 40
	local anim_s = anim_s or 1.0
	local anim_func
	if anim then
		anim_func = function(t) return anim, anim_s*(t/1000), true end
	end

	return sb.a3d:animate3D{
		start_time = sb.time:convert{redline,8.5*4},
		end_time = sb.time:convert{redline,15*4},
		sample_step = resolution,
		shader = function(vert,norm,col) return sb.m3d:basicDiffuseColor(vert,norm,col,
					{dir = light_dir, col={180,180,180}, ambient={85,85,85}}) end,
		camera_func = camera_func_1,
		actors = {
			{ model = m,

				mat_func = function(t)
					t=t/2000.0
					return sb.m3d:modelMatrix(
						{0,-cam_y_off,0}, 
						{scale,scale,scale}, 
						'xyz', {-math.pi/2, -math.pi,0})
				end,
				anim_func = anim_func,
				master_func = nil
			}
		}
	}
end
local function Phase2(m, scale, cam_y_off)
	return sb.a3d:animate3D{
		start_time = sb.time:convert{redline,15*4},
		end_time = sb.time:convert{redline,15*4+1},
		sample_step = 10,
		shader = function(vert,norm,col) return sb.m3d:basicDiffuseColor(vert,norm,col,
					{dir = light_dir, col={180,180,180}, ambient={85,85,85}}) end,
		camera_func = camera_func_2,
		actors = {
			{ model = m,
				mat_func = function(t)
					t=t/2000.0
					return sb.m3d:modelMatrix(
						{-15 * ((2000/433) * t) + 7.5, -cam_y_off,0}, 
						{scale,scale,scale}, 
						'xyz', {-math.pi/2, -math.pi/2, 0})
				end,

				master_func = nil
			}
		}
	}
end
local function Phase3(m, scale, cam_y_off)
	return sb.a3d:animate3D{
		start_time = sb.time:convert{redline,15*4+1},
		end_time = sb.time:convert{redline,15*4+2},
		sample_step = 10,
		shader = function(vert,norm,col) return sb.m3d:basicDiffuseColor(vert,norm,col,
					{dir = light_dir, col={180,180,180}, ambient={85,85,85}}) end,
		camera_func = camera_func_3,
		actors = {
			{ model = m,
				mat_func = function(t)
					t=t/2000.0
					return sb.m3d:modelMatrix(
						{15 * ((2000/433) * t) - 7.5, -cam_y_off,0}, 
						{scale,scale,scale}, 
						'xyz', {-math.pi/2, math.pi/2, 0})
				end,

				master_func = nil
			}
		}
	}
end
local function Phase4(m, scale, cam_y_off)
	return sb.a3d:animate3D{
		start_time = sb.time:convert{redline,15*4+2},
		end_time = sb.time:convert{redline,15*4+3.3},
		sample_step = 10,
		shader = function(vert,norm,col) return sb.m3d:basicDiffuseColor(vert,norm,col,
					{dir = light_dir, col={180,180,180}, ambient={85,85,85}}) end,
		camera_func = camera_func_4,
		actors = {
			{ model = m,
				mat_func = function(t)
					t=t/2000.0
					return sb.m3d:modelMatrix(
						{0, -cam_y_off,0}, 
						{scale,scale,scale}, 
						'xyz', {-math.pi/2, math.pi, 0})
				end,

				master_func = nil
			}
		}
	}
end

return {Phase1,Phase2,Phase3,Phase4,
	cams = {camera_func_1,camera_func_2,camera_func_3,camera_func_4},
	cams_still = {}}
