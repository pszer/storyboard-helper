local loadModel = require 'assetload'
local serialise = require 'serialise'

local invert_triangles = true

function love.load()
	local model_name = 'derpyflatg.iqm'
	local M,A = loadModel(model_name)

	local vertices = {}
	for i=1, M.mesh:getVertexCount() do
		vertices[i] = {M.mesh:getVertex(i)}
	end
	--local vertices = M.mesh:getVertices()
	local v_map    = M.mesh:getVertexMap()
	local v_format = M.mesh:getVertexFormat()

	local verts_out = {}

	local count=1
	for i=1,#v_map,3 do
		if invert_triangles then
			verts_out[count+0] = vertices[ v_map[i+0] ]
			verts_out[count+1] = vertices[ v_map[i+2] ]
			verts_out[count+2] = vertices[ v_map[i+1] ]
		else
			verts_out[count+0] = vertices[ v_map[i+0] ]
			verts_out[count+1] = vertices[ v_map[i+1] ]
			verts_out[count+2] = vertices[ v_map[i+2] ]
		end
		count = count + 3
	end

	local anim_data = {}
	for i,v in ipairs(A or {}) do
		anim_data[i] = v
	end

	local result = {
		model_name = model_name,
		vertices = verts_out,
		format = v_format,
		skeleton  = A.skeleton,
		frames    = A.frames,
		anims     = anim_data,
		joint_map = A.joint_map,
	}

	print('return' .. serialise(result))
end

function love.update(dt)
	love.event.quit()
end

function love.draw()

end
