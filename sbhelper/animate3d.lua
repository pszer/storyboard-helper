local modules = (...):gsub('%.[^%.]+$', '') .. "."
local cpml = require (modules..'cpml')
local sb_log = require (modules..'log')
local sb_m3d = require (modules..'model')
local sb_tri = require (modules..'tri')
local sb_object = require (modules..'object')
local sb_config = require (modules..'config')

local anim3d = {
	default_camera = function()
		return {0,0,-2}, 'xy', {0,0,0}
	end,
	default_perspective = function()
		return 70, 'wide', 0.5, 5000
	end
}

local __id = {1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1}
local __last_fov = nil
function anim3d:animate3D(params)
	local start_time       = params.start_time
	local end_time         = params.end_time
	local sample_step      = params.sample_step or 1000/40 -- 25fps
	local shader           = params.shader

	local camera_func      = params.camera_func or anim3d.default_camera

	local function set_camera(t)
		local pos, rot_type, rot = camera_func(t)
		sb_m3d:setCamera(pos,rot_type,rot)
	end

	local perspective_func = params.perspective_func or anim3d.default_perspective

	__last_fov = nil -- only update on FOV change
	local function set_perspective(t)
		local fov, aspect, near, far = perspective_func(t)
		if fov~=__last_fov then
			sb_m3d:setPerspective(fov,aspect,near,far)
		else __last_fov = fov end
	end

	-- other params
	local absolute_time = params.absolute_time or false
	local dont_sort = params.dont_sort ~= nil


	--- actors
	--[[
	--   {model=..., mat_func=..., anim_func..., master_func=...}
	--
	--   mat_func   (time)
	--   	 return pos, scale, rot_type, rot...
	--
	--   anim_func  (time)
	--     return anim_name, anim_time, (anim_forceloop)
	--
	--   master_func(time, model, model_mat, bone_mats)
	--     return model_mat, bone_mats, shader
	--     return nil -- to hide model
	--
	--]]
	local actors = params.actors
	--local actor_model_funcs = params.actor_model_funcs
	--local actor_anim_funcs  = params.actor_anim_funcs

	local T = start_time

	local frame = 0
	local actor_tri_out = {}
	local tri_id_set = {}

	for i,v in ipairs(actors) do
		actor_tri_out[i] = {}
		tri_id_set[i] = {} end

	local progressB = sb_log:initProgressBar(0, 16)

	-- Iterate frames
	while T <= end_time do
		progressB(1.0 - (end_time-T)/(end_time-start_time))
		frame = frame+1

		local sample_time = T
		if not absolute_time then sample_time = sample_time - start_time end

		set_camera(sample_time)
		set_perspective(sample_time)

		local view,proj = sb_m3d:getViewAndProjMats()

		-- Calculate actor triangles
		for actor_i,actor in ipairs(actors) do
			local Model       = actor.model
			local mat_func    = actor.mat_func
			local anim_func   = actor.anim_func or function() end
			local master_func = actor.master_func

			-- Get sample info.
			local m_mat = mat_func(sample_time)
			local anim_name, anim_time, anim_forceloop = anim_func(sample_time)
			anim_forceloop = anim_forceloop or false

			-- Animations
			local bone_mats
			if anim_name then
				bone_mats = sb_m3d:getAnimationFrame(Model, anim_name, anim_time, anim_forceloop)
			else -- identity matrix fallback if no anim
				--bone_mats = cpml.mat4.new()
				--for i=1,16 do bone_mats[i]=__id[i] end
			end

			-- Master func
			local local_shader = nil
			if master_func then
				m_mat, bone_mats, local_shader = master_func(sample_time, model, m_mat, bone_mats)
			end
			local_shader = local_shader or shader
		
			--
			-- m_mat must be present, if nil is returned by master_func then
			-- the actor is disabled for the frame.
			--
			if m_mat then
				local Tris = sb_tri:get3DTrianglesOut(Model.vertices, Model.format, m_mat,
					view, proj, bone_mats, local_shader)

				local depthStack = sb_tri:calculateDepthStack(Tris)

				local out_table = actor_tri_out[actor_i]
				local id_set    = tri_id_set[actor_i]

				-- If a triangle doesn't appear this frame, (because of backwards culling, occlusion etc.)
				-- then the previous triangle should be marked as tri.final=true, to signal that
				-- no interpolation/keyframing should be done after it.
				--
				-- Mark each triangle ID as non-existent, if a triangle is found then
				-- its marked back to false.
				for tri_id, v in pairs(out_table) do
					v.cull_previous = true end

				--
				-- Process depth sorted and appropiately culled triangles.
				--
				for i,v in ipairs(depthStack) do
					if out_table[v.id] == nil then
						out_table[v.id] = {}
					end

					table.insert(out_table[v.id], v)
					out_table[v.id].cull_previous = false

					--add times to triangle data
					v.start_t = T
					v.end_t   = T + sample_step
					if v.end_t > end_time then v.end_t = end_time end

					--add to set of all triangle IDs that appear with this actor
					id_set[v.id] = true
				end

				-- Visible triangles have been determined, all triangles not presents will mark
				-- their previous frame as the final one
				for i,v in pairs(out_table) do
					if v.cull_previous==true then
						local top_tri = v[#v]
						top_tri.final = true
					end
				end
			end
			-- Frame for this actor end.

		end
		-- Actors end.

		T = T + sample_step
	end

	for actor_i,_ in ipairs(actors) do
		local out_frames = actor_tri_out[actor_i]
		for tri_id, data in pairs(out_frames) do
			local keyframe_result = anim3d:keyframeTriangles(data)
			out_frames[tri_id] = keyframe_result
		end
	end

	local objs = anim3d:outputActorTris(actor_tri_out, start_time, end_time, sample_step, frame)
	if not dont_sort then
		sb_object:sortByHeights(objs)
	end

	sb_log:clearProgressBar()

	return objs
end

function anim3d:outputActorTris(actor_tris, start_time, end_time, time_step, frame_count)
	local objects = {}

	for actor_i, Tris in ipairs(actor_tris) do

		-- Do Triangles
		for tri_id, data in pairs(Tris) do

			for i=1,#data-1 do
				local T1 = data[i]
				local T2 = data[i+1]

				if T1.start_t < T2.start_t and not T1.final then
					To1, To2 = sb_tri:getSpritesTwoFrames(T1, T1.cols, T2, T2.cols)
					To1.height = T1.height
					To2.height = T2.height

					if To1 then
						local O1,O2,O3 = sb_tri:convertTriDataToObjects(To1, To2, 'Foreground', T1.start_t, T2.start_t)

						if O1 then
							O1:setHeight(math.max(To1.height,To2.height))
							table.insert(objects, O1) end
						if O2 then
							O2:setHeight(math.max(To1.height,To2.height))
							table.insert(objects, O2) end
						if O3 then
							O3:setHeight(math.max(To1.height,To2.height))
							table.insert(objects, O3) end
					end
				elseif T1.start_t > T2.start_t then
					sb_log:error("anim3d.outputActorTris(): malformed triangles at indices %s-%s, their timepoints go backwards (%s,%s).",
						i,i+1, T1.start_t, T2.start_t)
				end
				--
				--
			end
		end
	end
	--
	--
	return objects
end

-- simple wrapper, not necessary
function anim3d:actor(model, mat_func, anim_func, master_func)
	local t = {
		model = model,
		mat_func = mat_func,
		anim_func = anim_func,
		master_func = master_func
	}
	return t
end

function anim3d:keyframeTriangles(out_frame)
	sb_log:assert(out_frame, "anim3d.keyframeTriangles(): missing argument.")	
	sb_log:assert(type(out_frame)=="table", "anim3d.keyframeTriangles(): expected table. got '%s'.", type(input))

	local epsilon  = sb_config['3d-default-triangle-epsilon'] or 2.0

	local function time_dist(t1, t2, t3, d)
		-- calculate D once 
		if not d[1] then
			d = {}
			for i=1,6 do
				d[i]= t2[i]-t1[i]
			end
		end

		local U = (t3.start_t - t1.start_t) / (t2.start_t - t1.start_t)

		local p_linear = {}
		for i=1,6 do
			p_linear[i] = (U * d[i]) + t1[i]
			p_linear[i] = p_linear[i] - t3[i]
		end

		--
		-- root mean square
		--
		--
		local dist = 0
		for i=0,2 do
			dist = dist + p_linear[i*2+1]*p_linear[i*2+1] + p_linear[i*2+2]*p_linear[i*2+2]
		end
		--
		return (dist/3) ^ 0.5
	end

	-- Ramer–Douglas–Peucker algorithm
	--
	local RDP
	-- 
	-- uses time interpolation
	--
	RDP = function(points, I, J)
		local result = {}

		local max_dist = -1/0
		local max_i = nil

		-- Keyframing across an interval of time where a triangle is meant to be culled
		-- will lead to broken visuals. Triangles that are culled next frame have
		-- ['final'] set to true, and these are to be given full priorty.
		local cull_found = false
		for i=I+1, J-1 do
			local P = points[i]
			-- Final visible triangle.
			if P.final then
				cull_found = true
				max_i = i
				max_dist = 1/0 --inf dist = inf priority
				break
			end
		end

		if not cull_found then
			-- If no triangle is culled, find least simplifiable triangle
			-- as normal.
			local d = {}
			for i = I+1, J-1 do
				local dist_i = time_dist(points[I],points[J], points[i], d)

				if dist_i > max_dist then
					max_dist = dist_i
					max_i = i
				end
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

	local result = RDP(out_frame, 1, #out_frame)

	--print()
	--print('simplified to '..#result..' from '..#out_frame)

	return result
end

return anim3d
