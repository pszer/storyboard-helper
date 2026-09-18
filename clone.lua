local function clone(t)
	local T = {}
	for i,v in pairs(t) do
		T[i]=v
	end
	return T
end
return clone
