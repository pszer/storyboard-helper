local modules = (...):gsub('%.[^%.]+$', '') .. "."
local cpml = require (modules..'cpml')
local sb_log = require (modules..'log')
local sb_clone = require (modules..'clone')
require 'io'

local m3d = {

	-- storyboard dimensions
	Screen_X_Off = -107,
	Screen_Y_Off = 0,
	Screen_W = 854,
	Screen_H = 480,

}
m3d.__index = m3d

m3d.mat_camera      = nil
m3d.mat_perspective = nil
m3d.mat_viewproj    = cpml.mat4.new()

m3d.CubeVerts_Format = {
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
m3d.CubeVerts = {
    -- Front (red)
    {-0.5, -0.5, -0.5, 0, 0, -1, 255, 125, 0},
    { 0.5, -0.5, -0.5, 0, 0, -1, 255, 125, 0},
    { 0.5,  0.5, -0.5, 0, 0, -1, 255, 0, 0},

    {-0.5, -0.5, -0.5, 0, 0, -1, 255, 125, 0},
    { 0.5,  0.5, -0.5, 0, 0, -1, 255, 0, 0},
    {-0.5,  0.5, -0.5, 0, 0, -1, 255, 0, 0},

    -- Back (green)
    {-0.5, -0.5,  0.5, 0, 0, 1, 0, 255, 0},
    { 0.5,  0.5,  0.5, 0, 0, 1, 0, 255, 0},
    { 0.5, -0.5,  0.5, 0, 0, 1, 0, 255, 0},

    {-0.5, -0.5,  0.5, 0, 0, 1, 0, 255, 0},
    {-0.5,  0.5,  0.5, 0, 0, 1, 0, 255, 0},
    { 0.5,  0.5,  0.5, 0, 0, 1, 0, 255, 0},

    -- Left (blue)
    {-0.5, -0.5, -0.5, -1,0,0, 0, 0, 255},
    {-0.5,  0.5, -0.5, -1,0,0, 0, 0, 255},
    {-0.5,  0.5,  0.5, -1,0,0, 0, 0, 255},

    {-0.5, -0.5, -0.5, -1,0,0, 0, 0, 255},
    {-0.5,  0.5,  0.5, -1,0,0, 0, 0, 255},
    {-0.5, -0.5,  0.5, -1,0,0, 0, 0, 255},

    -- Right (yellow)
    { 0.5, -0.5, -0.5, 1,0,0,  50, 255, 0},
    { 0.5, -0.5,  0.5, 1,0,0,  50, 255, 0},
    { 0.5,  0.5,  0.5, 1,0,0,  255, 255, 0},

    { 0.5, -0.5, -0.5, 1,0,0,  50, 255, 0},
    { 0.5,  0.5,  0.5, 1,0,0,  255, 255, 0},
    { 0.5,  0.5, -0.5, 1,0,0,  255, 255, 0},

    -- Top (magenta)
    {-0.5,  0.5, -0.5, 0,1,0, 255, 0, 255},
    { 0.5,  0.5, -0.5, 0,1,0, 255, 0, 255},
    { 0.5,  0.5,  0.5, 0,1,0, 255, 0, 255},

    {-0.5,  0.5, -0.5, 0,1,0, 255, 0, 255},
    { 0.5,  0.5,  0.5, 0,1,0, 255, 0, 255},
    {-0.5,  0.5,  0.5, 0,1,0, 255, 0, 255},

    -- Bottom (cyan)
    {-0.5, -0.5, -0.5, 0,-1,0, 0, 255, 255},
    { 0.5, -0.5,  0.5, 0,-1,0, 0, 255, 255},
    { 0.5, -0.5, -0.5, 0,-1,0, 0, 255, 255},

    {-0.5, -0.5, -0.5, 0,-1,0, 0, 255, 255},
    {-0.5, -0.5,  0.5, 0,-1,0, 0, 255, 255},
    { 0.5, -0.5,  0.5, 0,-1,0, 0, 255, 255},
}

-- Each vertex is given a unique identifier, the first vertex in a triangle
-- is the triangles ID. these are used to keep track of individual triangles
-- for complex purposes like keyframing, interpolation, depth resolution etc.
--
-- triangles which are culled are split into triangles with unique identifiers of their own
--
local VERTEX_ID = 0
m3d.SPLIT_MAGIC_VALUE = 9999999
function m3d:getNewVertexID()
	VERTEX_ID = VERTEX_ID + 1
	return VERTEX_ID-1
end

-- when a triangle gets clipped by a plane, it either gets two vertices clipped, resulting in a triangle,
-- or it gets one vertex clipped resulting in a quadrilateral (two triangles).
--
-- when the latter happens, the resulting triangles are to be treated as entirely new triangles, with different IDs,
-- so that inappropiate interpolation with the unclipped triangle from last frame doesn't happen, and the two clipped triangles
-- can interpolate between themselves for as long as the source triangle stays clipped in the plane.
--
-- for any triangle with an ID X, the two triangles reserved for when it gets clipped to a quad is
-- X + SPLIT_MAGIC_VALUE
-- and X + SPLIT_MAGIC_VALUE*2
-- the magic value offset is sufficiently large for no ID collisions to realistically happen.
--
function m3d:getSplitVertexIDs(id)
	return id + m3d.SPLIT_MAGIC_VALUE, id + m3d.SPLIT_MAGIC_VALUE*2
end

local id = {1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1}
local __tempvec3_2 = cpml.vec3.new()
local __vec3up = cpml.vec3.new(0,1,0)
function m3d:rotateMatrix(mat, rot_type, rot)
	local mat4 = cpml.mat4

	if rot_type == "quaternion" then

		local R = mat4.from_quaternion(rot[1])
		mat:mul(R, mat)

	elseif rot_type == "lookat" then

		__tempvec3_2.x,__tempvec3_2.y,__tempvec3_2.z = rot[1],rot[2],rot[3]

		local LA = mat4.new()
		for i=1,16 do LA[i]=id[i] end
		mat4.look_at(LA, cpml.vec3.zero, __tempvec3_2, __vec3up)
		mat:mul(LA, mat)

	elseif rot_type == "xyz" then

		local R = mat4.new()
		for i=1,16 do R[i]=id[i] end
		R:rotate(R,rot[1],cpml.vec3.unit_x)
		R:rotate(R,rot[2],cpml.vec3.unit_y)
		R:rotate(R,rot[3],cpml.vec3.unit_z)
		mat:mul(R, mat)

	else
		sb_log:error("m3d.rotateMatrix(): expected rot_type of 'quaternion'/'lookat'/'xyz', got %s", rot_type)
	end

	return mat
end

local __tempvec3=cpml.vec3.new()
local __vec3up = cpml.vec3.new(0,-1,0)
function m3d:setCamera(pos, rot_type, rot)
	local mat4 = cpml.mat4
	local M = mat4.new()
	for i=1,16 do M[i]=id[i] end

	-- Position
	__tempvec3.x=-pos[1]
	__tempvec3.y=-pos[2]
	__tempvec3.z=-pos[3]
	M:translate(M, __tempvec3)
	m3d:rotateMatrix(M, rot_type, rot)

	m3d.mat_camera = M
	return m3d.mat_camera
end

-- fov
-- widescreen - either 'wide' or 'standard'
local __16_9 = 16/9
local __4_3 = 4/3
function m3d:setPerspective(fov, widescreen, near, far)
	local fov = fov or 70
	local widescreen = widescreen or 'wide'
	local near = near or 0.1
	local far = far or 5000
	local aspect = __16_9
	if widescreen:lower()=='standard' then
		aspect=__4_3
	end
	sb_log:assert(type(fov)=='number' and fov>=10 and fov<=160, "m3d.genPerspectiveMatrix(): expected fov between [10,160], got %s", fov)
	sb_log:assert(near < far, "m3d.genPerspectiveMatrix(): near (%s) >= far (%s), invalid.", near, far)

	m3d.mat_perspective = cpml.mat4.from_perspective(fov, aspect, near, far)
	return m3d.mat_perspective
end

function m3d:getViewAndProjMats()
	return m3d.mat_camera, m3d.mat_perspective
end

--[[function m3d:getViewProj()
	sb_log:assert(m3d.mat_camera ~= nil, "m3d.getViewProj(): call setCamera first.")
	sb_log:assert(m3d.mat_perspective ~= nil, "m3d.getViewProj(): call setPerspective first.")

	cpml.mat4.mul(m3d.mat_viewproj, m3d.mat_perspective, m3d.mat_camera)
	return m3d.mat_viewproj
end--]]

function m3d:modelMatrix(pos, scale, rot_type, ...)
	local M = cpml.mat4.new()
	for i=1,16 do M[i]=id[i] end

	__tempvec3.x=scale[1]
	__tempvec3.y=scale[2]
	__tempvec3.z=scale[3]

	M:scale(M, __tempvec3)
	m3d:rotateMatrix(M, rot_type, ...)
	__tempvec3.x=pos[1]
	__tempvec3.y=pos[2]
	__tempvec3.z=pos[3]
	M:translate(M, __tempvec3)

	return M
end

-- reads serialised model data
--
-- expected format is
--
-- {
--	model_name = string,
--	vertices = table,
--	format = vertex format table
--	anims = A
--}
--
-- typical format attributes are 
--
-- VertexPosition
-- VertexTexCoord
-- VertexNormal
-- VertexTangent
-- VertexBone
-- VertexWeight
--
function m3d:loadModelTable(filename)
	local test_file = io.open(filename, 'r')
	sb_log:assert(io.type(test_file)=="file", "m3d.loadModelTable(): couldn't open '%s'.", filename)
	test_file:close()

	local m_t = dofile(filename)
	sb_log:assert(type(m_t)=="table", "m3d.loadModelTable(): table expected, '%s' is a '%s'.", filename, type(m_t))

	m_t.filename = filename

	-- precalc offsets
	local count=1
	for i,v in ipairs(m_t.format) do
		v.offset = count
		m_t.format[v[1]] = {count,count+v[3]-1}
		count = count + v[3]
	end

	for i,v in ipairs(m_t.vertices) do
		v.id = m3d:getNewVertexID()
	end

	for i,v in ipairs(m_t.anims) do
		m_t.anims[v.name] = v
	end
	if m_t.frames and m_t.skeleton then
		m3d:setupAnimations(m_t)
	end

	sb_log:printf("Loaded model '%s'", filename)
	sb_log:printf("* %s triangles'", math.floor(#m_t.vertices/3.0))
	sb_log:printf("* %s bones'", (m_t.skeleton and #m_t.skeleton) or 0)
	sb_log:printf("* %s animation frames'", (m_t.frames and #m_t.frames) or 0)
	sb_log:printf("* %s animation defs'", (m_t.anims and #m_t.anims) or 0)
	for i,v in ipairs(m_t.anims) do
		sb_log:printf("  - '%s' [%s,%s] @%sfps%s", v.name, v.first, v.last, v.framerate, v.loop and (" (looping)") or "")
	end

	self:fixAttribute(m_t, 'VertexColor', 0, 255)
	return m_t
end

function m3d:addAttributeToModel(m_t, attribute, data_type, dim, default_v)
	local count=1
	for i,v in ipairs(m_t.format) do
		count = count + v[3]
	end

	local I,J = count+1, count+dim
	table.insert(m_t.format, {attribute, data_type, dim})
	m_t.format[attribute] = {I,J}

	for i,v in ipairs(m_t.vertices) do
		for j=I,J do
			v[j] = default_v[j-I+1]
		end
	end
end

function m3d:fixAttribute(m_t, attribute, add, mul)
	local I,J = m3d:getVertexAttributeIndex(m_t.format, attribute)

	for _,v in ipairs(m_t.vertices) do
		for i=I,J do
			v[i] = v[i]*mul + add
		end
	end
end

function m3d:getVertexAttributeData(vertex, format, attr)
	local offset = format[attr][1]
	local V = {}
	for i=offset, offset+format[attr][2], 1 do
		table.insert(V, i)
	end
	return V
end

function m3d:getVertexAttributeIndex(format, attr)
	sb_log:assert(format[attr], "m3d.getVertexAttributeIndex(): attribute ['%s'] doesn't exist", attr)

	local offset = format[attr][1]
	return offset, format[attr][2]
end

function m3d:hasAttribute(format, attr)
	return format[attr] ~= nil
end


-- clips triangle to be within depth >= z.
--
-- returns
--
-- nil,nil,true               - triangle fully behind plane
-- {v1,v2,v3},nil,false       - triangle fully in front of plane
-- {v1,v2,v3},nil,true        - two vertices clipped.
-- {v1,v2,v3},{v1,v2,v3},true - one vertex behind plane, triangle gets clipped to a quad.
--

-- CLIP
function m3d:clipTriangleZPlane(t1,t2,t3, z)
	local v1,v2,v3 = t1.pos, t2.pos, t3.pos

	-- if fully behind / in front
	if v1.z <= z and v2.z <= z and v3.z <= z then
		return nil, nil, true end
	if v1.z > z and v2.z > z and v3.z > z then
		return {t1,t2,t3}, nil, false end

	-- interps ['pos'],['norm'],['col']
	local function interp(vA,vB, r)
		local d_pos  = vB.pos - vA.pos
		local d_norm = vB.norm - vA.norm
		local d_R    = vB.col[1] - vA.col[1]
		local d_G    = vB.col[2] - vA.col[2]
		local d_B    = vB.col[3] - vA.col[3]

		return {
			pos = vA.pos + d_pos*r,
			norm = vA.norm + d_norm*r,
			col = {
				vA.col[1] + d_R*r,
				vA.col[2] + d_G*r,
				vA.col[3] + d_B*r,
			}
		}
	end

	-- clip A and B. C is in front of z-plane
	local function ClipTwoVerts(a,b,c)
		return interp(a,c, (z-a.pos.z) / (c.pos.z - a.pos.z)),
		       interp(b,c, (z-b.pos.z) / (c.pos.z - b.pos.z)),
					 c
	end
	-- clip A. B and C are in front of z-plane
	local function ClipOneVert(a,b,c)
		return interp(a,b, (z-a.pos.z) / (b.pos.z - a.pos.z)),
					 b,
		       interp(a,c, (z-a.pos.z) / (c.pos.z - a.pos.z)),
		       interp(a,c, (z-a.pos.z) / (c.pos.z - a.pos.z)),
					 b,c
	end
	-- two vertices clipped.
	if v1.z <= z and v2.z <= z and v3.z > z then
		local a,b,c = ClipTwoVerts(t1, t2, t3)
		return {a,b,c}, nil, true
		--
	elseif v1.z <= z and v2.z > z and v3.z <= z then
		--
		local a,b,c = ClipTwoVerts(t3, t1, t2)
		return {b,c,a}, nil, true
		--
	elseif v1.z > z and v2.z <= z and v3.z <= z then
		local a,b,c = ClipTwoVerts(t2, t3, t1)
		return {c,a,b}, nil, true

	end
	-- one vertex to clip.
	if v1.z <= z then

		local a1,b1,c1, a2,b2,c2 = ClipOneVert(t1, t2, t3)
		return {a1,b1,c1},{a2,b2,c2}, true
		--
	elseif v2.z <= z then
		--
		local a1,b1,c1, a2,b2,c2 = ClipOneVert(t2, t3, t1)
		return {c1,a1,b1},{c2,a2,b2}, true
		--
	elseif v3.z <= z then
		--
		local a1,b1,c1, a2,b2,c2 = ClipOneVert(t3, t1, t2)
		return {b1,c1,a1},{b2,c2,a2}, true

	end
	return {t1,t2,t3}, nil, false
end

local __pos_reg = {0,0,0,0}
local __norm_reg = {0,0,0,0}
local __screen_reg = {0,0,0,0}
local __norm_vec3 = cpml.vec3.new()

--
-- returns vec3 pos, vec3 normal, vec3, color, screen_x, screen_y
--
--
local deform_mat = cpml.mat4.new()
function m3d:vertexOut(vertex, format, model_m, view_m, proj_m, bone_mats)
	local Pos_i,Pos_j = m3d:getVertexAttributeIndex(format, 'VertexPosition')
	__pos_reg[1]=vertex[Pos_i]
	__pos_reg[2]=vertex[Pos_i+1]
	__pos_reg[3]=vertex[Pos_i+2]
	__pos_reg[4]=1.0

	if bone_mats then
		local VertexBone_i, VertexBone_j = m3d:getVertexAttributeIndex(format, 'VertexBone')
		local VertexWeight_i, VertexWeight_j = m3d:getVertexAttributeIndex(format, 'VertexWeight')

		--[[
		local deform_mat =
			bone_mats[ math.floor(vertex[VertexBone_i+0]*255.0) ] * vertex[VertexWeight_i+0] +
			bone_mats[ math.floor(vertex[VertexBone_i+1]*255.0) ] * vertex[VertexWeight_i+1] +
			bone_mats[ math.floor(vertex[VertexBone_i+2]*255.0) ] * vertex[VertexWeight_i+2] +
			bone_mats[ math.floor(vertex[VertexBone_i+3]*255.0) ] * vertex[VertexWeight_i+3]--]]
		for i=1,16 do
			deform_mat[i]=0 end

		for i=0,3 do
			local bm = bone_mats[ math.floor(vertex[VertexBone_i+i]*255.0)+1 ]
			local scalar = vertex[VertexWeight_i+i]

			for j=1,16 do
				deform_mat[j] = deform_mat[j] + bm[j]*scalar
			end
		end
		cpml.mat4.mul_vec4(__pos_reg, deform_mat, __pos_reg)
	end

	-- multiply by model matrix, then camera view+perspective matrix
	cpml.mat4.mul_vec4(__pos_reg, model_m, __pos_reg)
	cpml.mat4.mul_vec4(__pos_reg, view_m, __pos_reg)

	cpml.mat4.mul_vec4(__screen_reg, proj_m, __pos_reg)

	local Norm_i,Norm_j = m3d:getVertexAttributeIndex(format, 'VertexNormal')
	__norm_reg[1]=vertex[Norm_i]
	__norm_reg[2]=vertex[Norm_i+1]
	__norm_reg[3]=vertex[Norm_i+2]
	__norm_reg[4]=0.0

	-- multiply normal by model matrix
	cpml.mat4.mul_vec4(__norm_reg, model_m, __norm_reg)
	-- multiply normal by skin
	if bone_mats and deform_mat then
		cpml.mat4.mul_vec4(__norm_reg, deform_mat, __norm_reg)
	end

	-- normalise
	__norm_vec3.x = __norm_reg[1]
	__norm_vec3.y = __norm_reg[2]
	__norm_vec3.z = __norm_reg[3]
	local length = __norm_vec3:len()
	__norm_vec3.x = __norm_vec3.x/length
	__norm_vec3.y = __norm_vec3.y/length
	__norm_vec3.z = __norm_vec3.z/length
	--

	-- transform to final screen xy coordinates
	local x_NDC = __screen_reg[1] / __screen_reg[4]
	local y_NDC = __screen_reg[2] / __screen_reg[4]
	local z_NDC = __screen_reg[3] / __screen_reg[4]

	local x_screen = (x_NDC + 0.5) * m3d.Screen_W + m3d.Screen_X_Off
	local y_screen = (y_NDC + 0.5) * m3d.Screen_H + m3d.Screen_Y_Off

	local VCol_i, VCol_j = m3d:getVertexAttributeIndex(format, 'VertexColor')

	return cpml.vec3.new(__pos_reg[1], __pos_reg[2], __pos_reg[3]),
	       cpml.vec3.new(__norm_vec3.x, __norm_vec3.y, __norm_vec3.z),
				 {vertex[VCol_i], vertex[VCol_i+1], vertex[VCol_i+2]},
				 x_screen, y_screen
end

function m3d:triangleOut(v1,v2,v3, format, model_m, view_m, proj_m, bone_mats, clip_z)
	local clip_z = clip_z or 0.1
	local function getVertex(vertex)
		local Pos_i,Pos_j = m3d:getVertexAttributeIndex(format, 'VertexPosition')
		__pos_reg[1]=vertex[Pos_i]
		__pos_reg[2]=vertex[Pos_i+1]
		__pos_reg[3]=vertex[Pos_i+2]
		__pos_reg[4]=1.0
		if bone_mats then
			local VertexBone_i, VertexBone_j = m3d:getVertexAttributeIndex(format, 'VertexBone')
			local VertexWeight_i, VertexWeight_j = m3d:getVertexAttributeIndex(format, 'VertexWeight')
			for i=1,16 do
				deform_mat[i]=0 end
			for i=0,3 do
				local bm = bone_mats[ math.floor(vertex[VertexBone_i+i]*255.0)+1 ]
				local scalar = vertex[VertexWeight_i+i]
				for j=1,16 do
					deform_mat[j] = deform_mat[j] + bm[j]*scalar
				end
			end
			cpml.mat4.mul_vec4(__pos_reg, deform_mat, __pos_reg)
		end
		-- multiply by model matrix, then camera view+perspective matrix
		cpml.mat4.mul_vec4(__pos_reg, model_m, __pos_reg)
		cpml.mat4.mul_vec4(__pos_reg, view_m, __pos_reg)
		local screen_space={0,0,0,0}
		cpml.mat4.mul_vec4(screen_space, proj_m, __pos_reg)
		local Norm_i,Norm_j = m3d:getVertexAttributeIndex(format, 'VertexNormal')
		__norm_reg[1]=vertex[Norm_i]
		__norm_reg[2]=vertex[Norm_i+1]
		__norm_reg[3]=vertex[Norm_i+2]
		__norm_reg[4]=0.0
		-- multiply normal by model matrix
		cpml.mat4.mul_vec4(__norm_reg, model_m, __norm_reg)
		-- multiply normal by skin
		if bone_mats and deform_mat then
			cpml.mat4.mul_vec4(__norm_reg, deform_mat, __norm_reg)
		end
		-- normalise
		__norm_vec3.x = __norm_reg[1]
		__norm_vec3.y = __norm_reg[2]
		__norm_vec3.z = __norm_reg[3]
		local length = __norm_vec3:len()
		__norm_vec3.x = __norm_vec3.x/length
		__norm_vec3.y = __norm_vec3.y/length
		__norm_vec3.z = __norm_vec3.z/length
		local VCol_i, VCol_j = m3d:getVertexAttributeIndex(format, 'VertexColor')
		return { pos  = cpml.vec3.new(__pos_reg[1], __pos_reg[2], __pos_reg[3]),
					   norm = cpml.vec3.new(__norm_vec3.x, __norm_vec3.y, __norm_vec3.z),
					 screen = screen_space,
					    col = {vertex[VCol_i], vertex[VCol_i+1], vertex[VCol_i+2]} }
	end
	local function toScreen(pos)
		local sc_reg = {}
		local reg = {}
		reg[1] = pos.x
		reg[2] = pos.y
		reg[3] = pos.z
		reg[4] = 1.0
		cpml.mat4.mul_vec4(sc_reg, proj_m, reg)
		return sc_reg
	end
	local function getXY(screen)
		local v_x, v_y
		local x_NDC = screen[1] / screen[4]
		local y_NDC = screen[2] / screen[4]
		v_x = (x_NDC + 0.5) * m3d.Screen_W + m3d.Screen_X_Off
		v_y = (y_NDC + 0.5) * m3d.Screen_H + m3d.Screen_Y_Off
		return v_x,v_y
	end

	local function screenToXY(screen)
	-- transform to final screen xy coordinates
		local x_NDC = screen[1] / screen[4]
		local y_NDC = screen[2] / screen[4]
		--local z_NDC = __screen_reg[3] / __screen_reg[4]
		local x_screen = (x_NDC + 0.5) * m3d.Screen_W + m3d.Screen_X_Off
		local y_screen = (y_NDC + 0.5) * m3d.Screen_H + m3d.Screen_Y_Off
		return x_screen, y_screen
	end

	local t1,t2,t3 = getVertex(v1),getVertex(v2),getVertex(v3)
	local c_t1,c_t2,clipped = m3d:clipTriangleZPlane(t1,t2,t3, clip_z)

	-- clipped outside of view
	if not c_t1 then return nil end

	-- triangle/clipped to triangle
	if not c_t2 then
		-- if clipping has occured, the screen co-ordinates have to be recalculated,
		-- and position updated.
		if clipped then
			t1.pos = c_t1[1]
			t2.pos = c_t1[2]
			t3.pos = c_t1[3]
			t1.screen = toScreen(t1.pos)
			t2.screen = toScreen(t2.pos)
			t3.screen = toScreen(t3.pos)
		end
		t1.sx, t1.sy = screenToXY(t1.screen)
		t2.sx, t2.sy = screenToXY(t2.screen)
		t3.sx, t3.sy = screenToXY(t3.screen)
		return t1,t2,t3
	end

	-- clipped to quad (two triangles, six vertices)
	local q1,q2,q3,q4,q5,q6
	q1 = sb_clone(c_t1[1])
	q2 = sb_clone(c_t1[2])
	q3 = sb_clone(c_t1[3])
	q4 = sb_clone(c_t1[4])
	q5 = sb_clone(c_t1[5])
	q6 = sb_clone(c_t1[6])
	q1.screen = toScreen(q1.pos)
	q2.screen = toScreen(q2.pos)
	q3.screen = toScreen(q3.pos)
	q4.screen = toScreen(q4.pos)
	q5.screen = toScreen(q5.pos)
	q6.screen = toScreen(q6.pos)
	q1.sx,q1.sy = screenToXY(q1.screen)
	q2.sx,q2.sy = screenToXY(q2.screen)
	q3.sx,q3.sy = screenToXY(q3.screen)
	q4.sx,q4.sy = screenToXY(q4.screen)
	q5.sx,q5.sy = screenToXY(q5.screen)
	q6.sx,q6.sy = screenToXY(q6.screen)

	return q1,q2,q3,q4,q5,q6
end

function m3d:basicDiffuseColor(vertex, normal, color, light)
	local light_dir  = light.dir
	local light_col  = light.col
	local amb        = light.ambient

	-- diffuse component
	local dot = math.max(0.0, light_dir[1]*normal.x + light_dir[2]*normal.y + light_dir[3]*normal.z)

	local R_x = (dot * (light_col[1]/255) + amb[1]/255) * color[1]
	local G_x = (dot * (light_col[2]/255) + amb[2]/255) * color[2]
	local B_x = (dot * (light_col[3]/255) + amb[3]/255) * color[3]

	return {R_x, G_x, B_x}
end
function m3d:basicNormalShader(vertex, normal, color, light)
	return {math.abs(math.floor(norm.x*255.0)),
	        math.abs(math.floor(norm.y*255.0)),
					math.abs(math.floor(norm.z*255.0)) }
end

function m3d:setupAnimations(m_t)
	m3d:generateBaseFrames(m_t)
	m3d:generateAnimationFrames(m_t)

	m_t.outframe_buffer = {}
	for i=1,#m_t.skeleton do
		m_t.outframe_buffer[i] = cpml.mat4.new()
	end
end

function m3d:generateBaseFrames(m_t)
	local skeleton = m_t.skeleton

	m_t.baseframe = {}
	m_t.inversebaseframe = {}

	for bone_id,bone in ipairs(skeleton) do
		local position_v = bone.position
		local rotation_q = bone.rotation
		local scale_v = bone.scale

		local bone_pos_v = cpml.vec3.new(position_v[1], position_v[2], position_v[3])
		local bone_rot_q = cpml.quat.new(rotation_q[1], rotation_q[2], rotation_q[3], rotation_q[4])
		bone_rot_q = bone_rot_q:normalize()
		local bone_scale_v = cpml.vec3.new(scale_v[1], scale_v[2], scale_v[3])

		local rotation_u = cpml.mat4.from_quaternion( bone_rot_q )
		local position_u = cpml.mat4.new(1)
		local scale_u    = cpml.mat4.new(1)

		position_u:translate(position_u, bone_pos_v)
		scale_u:scale(scale_u, bone_scale_v)

		local matrix = position_u * rotation_u * scale_u
		local invmatrix = cpml.mat4():invert(matrix)

		m_t.baseframe[bone_id] = matrix
		m_t.inversebaseframe[bone_id] = invmatrix

		if bone.parent > 0 then -- if bone has a parent
			m_t.baseframe[bone_id] = m_t.baseframe[bone.parent] * m_t.baseframe[bone_id]
			m_t.inversebaseframe[bone_id] = m_t.inversebaseframe[bone_id] * m_t.inversebaseframe[bone.parent]
		end

		bone.offset = matrix
	end
end

function m3d:generateAnimationFrames(m_t)
	local Frames = m_t.frames
	m_t.old_frames = m_t.frames
	m_t.frames = {}

	for frame_i, frame in ipairs(Frames) do
		m_t.frames[frame_i] = {}
		local output_frames = m_t.frames[frame_i]

		for pose_i, pose in ipairs(frame) do
			
			local position = pose.translate
			local rotation = pose.rotate
			local scale = pose.scale

			local pos_v = cpml.vec3.new(position[1], position[2], position[3])
			local rot_q = cpml.quat.new(rotation[1], rotation[2], rotation[3], rotation[4])
			rot_q = rot_q:normalize()
			local scale_v = cpml.vec3.new(scale[1], scale[2], scale[3])

			local position_u = cpml.mat4.new(1)
			local rotation_u = cpml.mat4.from_quaternion( rot_q )
			local scale_u    = cpml.mat4.new(1)

			position_u:translate(position_u, pos_v)
			scale_u:scale(scale_u, scale_v)

			--local matrix = scale_u * rotation_u * position_u
			local matrix = position_u * rotation_u * scale_u
			local invmatrix = cpml.mat4():invert(matrix)

			local bone = m_t.skeleton[pose_i]

			if bone.parent > 0 then -- if bone has a parent
				output_frames[pose_i] = m_t.baseframe[bone.parent] * matrix * m_t.inversebaseframe[pose_i]
			else
				output_frames[pose_i] = matrix * m_t.inversebaseframe[pose_i]
			end
		end
	end
end

function m3d:getAnimation(m_t, anim_name)
	sb_log:assert(anim_name, "m3d.getAnimation(): expected animation name.")
	local A = m_t.anims[anim_name]	
	sb_log:assert(A, "m3d.getAnimation(): no animation '%s' in '%s'.", anim_name, m_t.filename)
	return A
end

function m3d:getAnimationFrame(m_t, anim_name, time, force_loop)
	local anim = m3d:getAnimation(m_t, anim_name)
	local dT = 1.0 / anim.framerate -- time per frame

	local frame_t = time / dT

	local start_i = anim.first
	local end_i   = anim.last
	local looping = anim.loop

	if force_loop then looping = true end

	local frame_i = start_i + frame_t

	local fi1, fi2

	if not looping and frame_i < start_i then frame_i = start_i end
	if not looping and frame_i > end_i   then frame_i = end_i end
	if not looping then
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
	return m3d:interpolateTwoFrames(m_t, m_t.frames[fi1], m_t.frames[fi2], interp_i)
end

function m3d:interpolateTwoFrames(m_t, frame1, frame2, interp)
	local skeleton = m_t.skeleton

	local mat4 = cpml.mat4
	local mat4new = mat4.new
	local mat4mul = mat4.mul

	local frame_interp   = interp
	local frame_interp_i = 1.0 - interp

	local temp_mat = mat4new()

	local outframe = m_t.outframe_buffer

	for i,pose1 in ipairs(frame1) do
		pose2 = frame2[i]
		for j=1,16 do
			local A = (frame_interp_i)*pose1[j]
			local B = frame_interp*pose2[j]
			outframe[i][j] = A+B
		end

		local parent_i = skeleton[i].parent
		if parent_i > 0 then
			mat4mul(outframe[i], outframe[parent_i], outframe[i])
		else
			--outframe[i] = outframe[i]
		end
	end

	return outframe
end

return m3d
