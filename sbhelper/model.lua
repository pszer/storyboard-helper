local modules = (...):gsub('%.[^%.]+$', '') .. "."
local cpml = require (modules..'cpml')
local sb_log = require (modules..'log')
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

local __tempvec3_2 = cpml.vec3.new()
function m3d:rotateMatrix(mat, rot_type, rot)
	local mat4 = cpml.mat4

	if rot_type == "quaternion" then

		local R = mat4.from_quaternion(rot[1])
		mat:mul(R, mat)

	elseif rot_type == "lookat" then

		__tempvec3_2.x,__tempvec3_2.y,__tempvec3_2.z = rot[1],rot[2],rot[3]

		local LA = mat4.new()
		mat4.look_at(LA, __tempvec3_2, cpml.vec3.zero, __vec3up)
		mat:mul(LA, mat)

	elseif rot_type == "xyz" then

		local R = mat4.identity()
		R:rotate(R,rot[1],cpml.vec3.unit_x)
		R:rotate(R,rot[2],cpml.vec3.unit_y)
		R:rotate(R,rot[3],cpml.vec3.unit_z)
		mat:mul(R, mat)

	else
		sb_log:error("m3d.rotateMatrix(): expected rot_type of 'quaternion'/'lookat'/'xyz', got %s", rot_type)
	end

	return mat
end

local id = {1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1}
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
	local near = near or 0.5
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

	-- precalc offsets
	local count=1
	for i,v in ipairs(m_t.format) do
		v.offset = count
		m_t.format[v[1]] = {count,count+v[3]-1}
		count = count + v[3]
	end

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

local __pos_reg = {0,0,0,0}
local __norm_reg = {0,0,0,0}
local __screen_reg = {0,0,0,0}
local __norm_vec3 = cpml.vec3.new()

--
-- returns vec3 pos, vec3 normal, vec3, color, screen_x, screen_y
--
--
function m3d:vertexOut(vertex, format, model_m, view_m, proj_m, bone_mats)
	local Pos_i,Pos_j = m3d:getVertexAttributeIndex(format, 'VertexPosition')
	__pos_reg[1]=vertex[Pos_i]
	__pos_reg[2]=vertex[Pos_i+1]
	__pos_reg[3]=vertex[Pos_i+2]
	__pos_reg[4]=1.0

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

return m3d
