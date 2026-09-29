return function(p, t)
	local f = {}

	for i,v in ipairs(t) do
		if p(v) then table.insert(f,v) end
	end

	return f
end
