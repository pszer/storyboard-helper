return function(p, t)
	local f = {}

	for i=#t,1,-1 do
		local v = t[i]
		if p(v) then
			table.remove(t,i)
			table.insert(f,v)
		end
	end

	return f
end
