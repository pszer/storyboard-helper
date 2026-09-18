require 'math'

local anchor = {}
anchor.__index = anchor

anchor.values = {
	"TopLeft",
	"Centre",
	"CentreLeft",
	"TopRight",
	"BottomCentre",
	"TopCentre",
	"CentreRight",
	"BottomLeft",
	"BottomRight",

	lower={
		"topleft",
		"centre",
		"centreleft",
		"topright",
		"bottomcentre",
		"topcentre",
		"centreright",
		"bottomleft",
		"bottomright",
	}
}
anchor.dict = {
	[0] =	"TopLeft",
	[1] =	"Centre",
	[2] =	"CentreLeft",
	[3] =	"TopRight",
	[4] =	"BottomCentre",
	[5] =	"TopCentre",
	[7] =	"CentreRight",
	[8] =	"BottomLeft",
	[9] =	"BottomRight",
	["TopLeft"] = 0,
	["Centre"] = 1,
	["CentreLeft"] = 2,
	["TopRight"] = 3,
	["BottomCentre"] = 4,
	["TopCentre"] = 5,
	["CentreRight"] = 7,
	["BottomLeft"] = 8,
	["BottomRight"] = 9,
}

local function top(a,b) return a end 
local function mid(a,b) return a+b*0.5 end 
local function bot(a,b) return a+b end 
anchor.func = {
	[0] = function(x,y,w,h) return top(x,w),top(y,h) end,
	[1] = function(x,y,w,h) return mid(x,w),mid(y,h) end,
	[2] = function(x,y,w,h) return top(x,w),mid(y,h) end,
	[3] = function(x,y,w,h) return bot(x,w),top(y,h) end,
	[4] = function(x,y,w,h) return mid(x,w),bot(y,h) end,
	[5] = function(x,y,w,h) return mid(x,w),top(y,h) end,
	[7] = function(x,y,w,h) return bot(x,w),mid(y,h) end,
	[8] = function(x,y,w,h) return top(x,w),bot(y,h) end,
	[9] = function(x,y,w,h) return bot(x,w),bot(y,h) end,
}

anchor.func["TopLeft"] = anchor.func[0]
anchor.func["Centre"] = anchor.func[1]
anchor.func["CentreLeft"] = anchor.func[2]
anchor.func["TopRight"] = anchor.func[3]
anchor.func["BottomCentre"] = anchor.func[4]
anchor.func["TopCentre"] = anchor.func[5]
anchor.func["CentreRight"] = anchor.func[7]
anchor.func["BottomLeft"] = anchor.func[8]
anchor.func["BottomRight"] = anchor.func[9]

function anchor:correctInput(str)
	if type(str)=="number" then
		if str == 6 then return 1 end
		if str < 0 then return 0 end
		if str > 9 then return 9 end
		return math.floor(str)
	end

	str = string.lower(str)
	local i,j = str:find("center") -- correct equivalent center/centre spellings
	if i then
		str = str:sub(1,i-1).."centre"..str:sub(j+1,-1)
	end
	for index,v in ipairs(anchor.values.lower) do
		if str==v then
			return anchor.values[index]
		end
	end
	return nil
end

function anchor:out(a)
	if type(a)=="string" then return anchor.dict[a] or 1 end
	return a
end

return anchor
