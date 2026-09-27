local modules = (...):gsub('%.[^%.]+$', '') .. "."
local cpml = require (modules..'cpml')
local sb_log = require (modules..'log')
require 'io'

local m3d = {

	-- storyboard dimensions
	Screen_X_Centre = 320,
	Screen_Y_Centre = 240,
	Screen_W = 640,
	Screen_H = 480,

}
m3d.__index = m3d

m3d.mat_camera      = nil
m3d.mat_perspective = nil
m3d.mat_viewproj    = cpml.mat4.new()

local CubeVerts = {
    -- Front (red)
    {-0.5, -0.5, -0.5, 1, 0, 0},
    { 0.5, -0.5, -0.5, 1, 0, 0},
    { 0.5,  0.5, -0.5, 1, 0, 0},

    {-0.5, -0.5, -0.5, 1, 0, 0},
    { 0.5,  0.5, -0.5, 1, 0, 0},
    {-0.5,  0.5, -0.5, 1, 0, 0},

    -- Back (green)
    {-0.5, -0.5,  0.5, 0, 1, 0},
    { 0.5,  0.5,  0.5, 0, 1, 0},
    { 0.5, -0.5,  0.5, 0, 1, 0},

    {-0.5, -0.5,  0.5, 0, 1, 0},
    {-0.5,  0.5,  0.5, 0, 1, 0},
    { 0.5,  0.5,  0.5, 0, 1, 0},

    -- Left (blue)
    {-0.5, -0.5, -0.5, 0, 0, 1},
    {-0.5,  0.5, -0.5, 0, 0, 1},
    {-0.5,  0.5,  0.5, 0, 0, 1},

    {-0.5, -0.5, -0.5, 0, 0, 1},
    {-0.5,  0.5,  0.5, 0, 0, 1},
    {-0.5, -0.5,  0.5, 0, 0, 1},

    -- Right (yellow)
    { 0.5, -0.5, -0.5, 1, 1, 0},
    { 0.5, -0.5,  0.5, 1, 1, 0},
    { 0.5,  0.5,  0.5, 1, 1, 0},

    { 0.5, -0.5, -0.5, 1, 1, 0},
    { 0.5,  0.5,  0.5, 1, 1, 0},
    { 0.5,  0.5, -0.5, 1, 1, 0},

    -- Top (magenta)
    {-0.5,  0.5, -0.5, 1, 0, 1},
    { 0.5,  0.5, -0.5, 1, 0, 1},
    { 0.5,  0.5,  0.5, 1, 0, 1},

    {-0.5,  0.5, -0.5, 1, 0, 1},
    { 0.5,  0.5,  0.5, 1, 0, 1},
    {-0.5,  0.5,  0.5, 1, 0, 1},

    -- Bottom (cyan)
    {-0.5, -0.5, -0.5, 0, 1, 1},
    { 0.5, -0.5,  0.5, 0, 1, 1},
    { 0.5, -0.5, -0.5, 0, 1, 1},

    {-0.5, -0.5, -0.5, 0, 1, 1},
    {-0.5, -0.5,  0.5, 0, 1, 1},
    { 0.5, -0.5,  0.5, 0, 1, 1},
}

function m3d:rotateMatrix(mat, rot_type, ...)
	local mat4 = cpml.mat4

	local rot = {...}

	if rot_type == "quaternion" then

		local R = mat4.from_quaternion(rot[1])
		mat:mul(R, mat)

	elseif rot_type == "lookat" then

		local LA = mat4.new()
		mat4.look_at(LA, cpml.vec3.new(rot[1],rot[2],rot[3]), cpml.vec3.zero, __vec3up)
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

local __tempvec3={}
local __vec3up = cpml.vec3.new(0,-1,0)
function m3d:setCamera(pos, rot_type, ...)
	local mat4 = cpml.mat4
	local M = mat4.identity()

	-- Position
	__tempvec3[1]=-pos[1]
	__tempvec3[2]=-pos[2]
	__tempvec3[3]=-pos[3]
	M:translate(M, pos)
	m3d:rotateMatrix(M, rot_type, ...)

	m3d.mat_camera = M
	return M
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
	sb_log:assert(type(fov)~='number' or fov<10 or fov>160, "m3d.genPerspectiveMatrix(): expected fov between [10,160], got %s", fov)
	sb_log:assert(near < far, "m3d.genPerspectiveMatrix(): near (%s) >= far (%s), invalid.", near, far)

	m3d.mat_perspective = cpml.mat4.from_perspective(fov, aspect, near, far)
	return m3d.mat_perspective
end

function m3d:getViewProj()
	sb_log:assert(m3d.mat_camera ~= nil, "m3d.getViewProj(): call setCamera first.")
	sb_log:assert(m3d.mat_perspective ~= nil, "m3d.getViewProj(): call setPerspective first.")

	cpml.mat4.mul(m3d.mat_viewproj, m3d.mat_perspective, m3d.mat_camera)
end

function m3d:modelMatrix(pos, scale, rot_type, ...)
	local M = mat4.identity()

	__tempvec3[1]=scale[1]
	__tempvec3[2]=scale[2]
	__tempvec3[3]=scale[3]
	M:scale(M, __tempvec3)
	m3d:rotateMatrix(M, rot_type, ...)
	M:translate(M, pos)

	return M
end

-- reads serialised model data
--
-- expected format is
--
-- {
--	model_name = string,
--	triangles = table of {v1,v2,v3},
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
		m_t.format[v[1]] = {count,v[2]}
		count = count + m_t.format[v[3]]
	end

	return m_t
end

function m3d:getVertexAttribute(vertex, format, attr)
	local offset = format[attr][1]
	local V = {}
	for i=offset, offset+format[attr][2], 1 do
		table.insert(V, i)
	end
	return V
end

function m3d:getVertexAttributeIndex(vertex, format, attr)
	local offset = format[attr][1]
	return offset, offset+formart[attr][2]
end

local __pos_reg = {0,0,0,0}
local __norm_reg = {0,0,0,0}
local __norm_vec3 = cpml.vec3.new()

--
-- returns vec3 pos, vec3 normal, screen_x, screen_y
--
--
function m3d:vertexOut(vertex, format, model_m, viewproj_m, bone_m)
	local Pos_i,Pos_j = m3d;getVertexAttribute(vertex, format, 'VertexPosition')
	__pos_reg[1]=vertex[Pos_i]
	__pos_reg[2]=vertex[Pos_i+1]
	__pos_reg[3]=vertex[Pos_i+2]
	__pos_reg[4]=1.0

	-- multiply by model matrix, then camera view+perspective matrix
	cpml.mat4.mul_vec(__pos_reg, model_m, __pos_reg)
	cpml.mat4.mul_vec(__pos_reg, viewproj_m, __pos_reg)

	local Norm_i,Norm_j = m3d;getVertexAttribute(vertex, format, 'VertexNormal')
	__norm_reg[1]=vertex[Norm_i]
	__norm_reg[2]=vertex[Norm_i+1]
	__norm_reg[3]=vertex[Norm_i+2]
	__norm_reg[4]=0.0

	-- multiply normal by model matrix
	cpml.mat4.mul_vec(__norm_reg, model_m, __norm_reg)

	__norm_vec3.x = __norm_reg[1]
	__norm_vec3.y = __norm_reg[2]
	__norm_vec3.z = __norm_reg[3]
	local length = __norm_vec3:len()
	__norm_vec3.x = __norm_vec3.x/length
	__norm_vec3.y = __norm_vec3.y/length
	__norm_vec3.z = __norm_vec3.z/length

	local x_NDC = __pos_reg[1] / __pos_reg[4]
	local y_NDC = __pos_reg[2] / __pos_reg[4]
	local z_NDC = __pos_reg[3] / __pos_reg[4]

	local x_screen = (x_NDC + 1) * m3d.Screen_W
	local y_screen = (y_NDC + 1) * m3d.Screen_H

	return cpml.vec3.new(__pos_reg[1], __pos_reg[2], __pos_reg[3]),
	       cpml.vec3.new(__norm_vec3.x, __norm_vec3.y, __norm_vec3.z),
				 x_screen, y_screen

end

function m3d:basicDiffuseColor(vertex, normal, light)
	return {255,255,255}
end

function m3d:newModel(verts)
	local model = {
		model_matrix = nil
	}
end

print(m3d:loadModelTable('nito.txt'))

return m3d
