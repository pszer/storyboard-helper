--
-- memorisable strings for easings, the easings table
-- index is case insensitive
--
-- eg. both are valid
-- easing.expoinout
-- easing.expoInOut

require 'math'
local sb_log = require 'log'

local easing = {}
easing.funcs = {}

local easing_mt = {}
easing_mt.__index = function(table,key)
	if type(key)=="number" then
		return key
	end
	if type(key)=="string" then
		local r = rawget(table,key:lower())
		sb_log:assert(r, string.format("easing[]: unknown easing '%s'",tostring(key)))
		return r
	end
end

setmetatable(easing,easing_mt)

easing["linear"]=0
easing.funcs[0]=function(x)
	return x
end

easing["out"]=1
easing.funcs[1]=function(x)
	return x * (2 - x)
end
easing["in"] =2
easing.funcs[2]=function(x)
	return x * x
end

easing["quadin"]=3
easing.funcs[3]=function(x)
	return x * x
end
easing["quadout"] =4
easing.funcs[4]=function(x)
	return 1 - (1 - x) * (1 - x)
end

easing["quadinout"]=5
easing.funcs[5]=function(x)
	return x < 0.5 and 2 * x * x or 1 - (-2 * x + 2)^2 / 2
end

easing["cubicin"]=6
easing.funcs[6]=function(x)
	return x * x * x
end
easing["cubicout"]=7
easing.funcs[7]=function(x)
	return 1 - (1 - x)^3
end
easing["cubicinout"]=8
easing.funcs[8]=function(x)
	return x < 0.5 and 4 * x * x * x or 1 - (-2 * x + 2)^3 / 2
end
easing["quartin"]=9
easing.funcs[9]=function(x)
		return x * x * x * x
end	
easing["quartout"]=10
easing.funcs[10]=function(x)
		return (1 - x)^4
end	
easing["quartinout"] =11
easing.funcs[11]=function(x)
	return x < 0.5 and 8 * x * x * x * x or 1 - (-2 * x + 2)^4 / 2
end
easing["quintin"]=12
easing.funcs[12]=function(x)
		return x * x * x * x * x
end	
easing["quintout"] =13
easing.funcs[13]=function(x)
		return (1 - x)^5
end	
easing["quintinout"]=14
easing.funcs[14]=function(x)
	return x < 0.5 and 16 * x * x * x * x or 1 - (-2 * x + 2)^8 / 2
end
easing["sinein"]=15
easing.funcs[15]=function(x)
	return 1 - math.cos((x * math.pi) / 2.0)
end
easing["sineout"] =16
easing.funcs[16]=function(x)
	return math.sin((x * math.pi) / 2.0)
end
easing["sineinout"] =17
easing.funcs[17]=function(x)
	return -(math.cos(math.pi * x) - 1) / 2.0
end
easing["expoin"]=18
easing.funcs[18]=function(x)
	return x == 0 and 0 or 2^(10 * x - 10)
end
easing["expoout"] =19
easing.funcs[19]=function(x)
	return x == 1 and 1 or 1 - 2^(-10 * x)
end
easing["expoinout"] =20
easing.funcs[20]=function(x)
	return x == 0 and 0 or x == 1 and 1 or x < 0.5 and 2 ^ (20 * x - 10) / 2 or (2 - 2 ^ (-20 * x + 10)) / 2
end
easing["circin"]=21
easing.funcs[21]=function(x)
	return 1 - math.sqrt(1 - x * x)
end
easing["circout"] =22
easing.funcs[22]=function(x)
	return math.sqrt(1 - (1 - x) ^ 2)
end
easing["circinout"]=23
easing.funcs[23]=function(x)
	return x < 0.5 and (1 - math.sqrt(1 - (2 * x)^2)) / 2	 or (math.sqrt(1 - (-2 * x + 2)^2) + 1) / 2
end
easing["elasticin"]=24
easing.funcs[24]=function(x)
	local c4 = (2 * math.pi) / 3
	return x == 0 and 0 or x == 1 and 1 or 2^(10 * x - 10) * math.sin((x * 10 - 10.75) * c4)
end

easing["elasticout"]=25
easing.funcs[25]=function(x)
	local c4 = (2 * math.pi) / 3.0 return x == 0 and 0 or x == 1 and 1 or 2^(-10 * x) * math.sin((x * 10 - 0.75) * c4) + 1
end

easing["elastichalfout"]=26
easing.funcs[26]=function(x)
	return 1 - 0.5 * math.pow(2, -10 * t) *
		math.sin((t - 0.075) * (2 * math.pi) / 0.3)
end

easing["elasticquarterout"]=27
easing.funcs[27]=function(x)
	return 1 - 0.5 * math.pow(2, -10 * t) *
		math.sin((t - 0.075) * (2 * math.pi) / 0.15)
end

easing["elasticinout"]=28
easing.funcs[28]=function(x)
	local c5 = (2 * math.pi) / 4.5 return x == 0 and 0 or x == 1 and 1 or x < 0.5 and -(2^(20 * x - 10) * math.sin((20 * x - 11.125) * c5)) / 2 or (2^(-20 * x + 10) * math.sin((20 * x - 11.125) * c5)) / 2 + 1;
end

easing["backin"]=29
easing.funcs[29]=function(x)
	local c1 = 1.70158 local c3 = c1 + 1 return c3 * x * x * x - c1 * x * x
end
easing["backout"]=30
easing.funcs[30]=function(x)
local c1 = 1.70158 local c3 = c1 + 1 return 1 + c3 * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2) end
easing["backinout"]=31

local function bout(x)
	local n1 = 7.5625
	local d1 = 2.75
	if x < 1 / d1 then
		return n1 * x * x
	elseif x < 2 / d1 then
		x = x - 1.5 / d1
		return n1 * x * x + 0.75
	elseif x < 2.5 / d1 then
		x = x - 2.25 / d1
		return n1 * x * x + 0.9375
	else
		x = x - 2.625 / d1
		return n1 * x * x + 0.984375
	end
end
easing["bouncein"]=32
easing.funcs[32]=function(x)
	return 1 - bout(1 - x)
end
easing["bounceout"]=33
easing.funcs[33]=function(x)
	return bout(x)
end
easing["bounceinout"] =34
easing.funcs[34]=function(x)
	return x < 0.5 and (1 - easeOutBounce(1 - 2 * x)) / 2 or (1 + easeOutBounce(2 * x - 1)) / 2;
end

return easing
