-- clone
local function clone(t)
	if type(t) ~= "table" then return t end
	local T = {}
	for i,v in pairs(t) do
		T[i]=clone(v)
	end
	return T
end
return clone
