local layer = {}
layer.__index = layer

layer.values = {
	"Background",
	"Fail",
	"Pass",
	"Foreground",
	"Overlay",

	lower = {
		"background",
		"fail",
		"pass",
		"foreground",
		"overlay",
	}
}
layer.dict = {
	[0] =	"Background",
	[1] =	"Fail",
	[2] =	"Pass",
	[3] =	"Foreground",
	[4] =	"Overlay",
	["Background"] = 0,
	["Fail"] = 1,
	["Pass"] = 2,
	["Foreground"] = 3,
	["Overlay"] = 4,
}

function layer:correctInput(str)
	if type(str)=="number" then
		if str < 0 then return 0 end
		if str > 4 then return 4 end
		return math.floor(str)
	end

	str = string.lower(str)
	for index,v in ipairs(layer.values.lower) do
		if str==v then
			return layer.values[index]
		end
	end
	return nil
end

function layer:out(a)
	if type(a)=="string" then return layer.dict[a] or 0 end
	return a
end

return layer
