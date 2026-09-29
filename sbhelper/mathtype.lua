local mathtype ={}

function mathtype.type(x)
	if type(x) ~= "number" then
			return nil
	end

	if x % 1 == 0 then
			return "integer"
	end

	return "float"
end

function mathtype.tointeger(x)
	local t = mathtype.type(x)

	if t=="float" then return nil end
	return math.floor(x)
end

return mathtype
