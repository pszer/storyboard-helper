local triangle = {}
triangle.__index = triangle

function triangle:new(x1,y1, x2,y2, x3,y3)
	local T = {x1,y1, x2,y2, x3,y3}
	setmetatable(T, triangle)
	return T
end

return triangle
