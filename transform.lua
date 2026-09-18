-- transform object
-- used to keep track of transform state for objects,
-- one for absolute position and one for relative

local sb_log = require 'log'

local transform = {}
transform.__index = transform

-- either
--  x,y,z, sx,sy, r
-- or
--  pos, scale, r
-- where pos and scale are vec3 and vec2 respectively.
function transform:new(x,y,z, sx,sy, r)
	sb_log:assert(x,string.format("transform:new(): x argument required."))
	sb_log:assert(y,string.format("transform:new(): y argument required."))
	sb_log:assert(z,string.format("transform:new(): z argument required."))

	local t

	if type(x) == "number" then
		local t ={
			pos={x,y,z},
			scale={sx or 1,sy or 1},
			r=r or 0
		}
	elseif type(x) == "table" then
		local t ={
			pos={x[1],x[2],x[3]},
			scale={y[1],y[2]},
			r=z
		}
	end

	setmetatable(t,transform)
	return t
end

return transform
