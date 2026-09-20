local sb_easing = require 'easing'
local sb_config = require 'config'
local sb_log    = require 'log'

local easing_derivatives = {}

local tolerance = 0.0001
function easing_derivatives:find_root(easing, t1,t2, a,b)

	if (a < 0 and b < 0) or (a > 0 and b > 0) then
		sb_log("easing_derivatives:find_root(): %s and %s don't cross 0")
	elseif a == 0 then
		return t1
	elseif b == 0 then
		return t2
	end

	local derivative = easing_derivatives[easing]
	local easing_func = sb_easing.funcs[sb_easing[easing]]

	if not derivative then
		if sb_config["forbid-unsupported-negative-scale-easing"] then
			sb_log:error("avoid using easing %s if a scale/vector command crosses 0. aborting", easing)
		else
			local fallback
			sb_log:warn("avoid using easing %s if a scale/vector command crosses 0. reverting to fallbacks.", easing)
			if easing == sb_easing['backin'] then fallback = 'cubicin' end
			if easing == sb_easing['backout'] then fallback = 'cubicout' end
			if easing == sb_easing['backinout'] then fallback = 'cubicinout' end
			if easing == sb_easing['bouncein'] then fallback = 'sinein' end
			if easing == sb_easing['bounceout'] then fallback = 'sineout' end
			if easing == sb_easing['bounceinout'] then fallback = 'sineinout' end
			if easing == sb_easing['elasticin'] then fallback = 'expoin' end
			if easing == sb_easing['elasticout'] then fallback = 'expoout' end
			if easing == sb_easing['elasticinout'] then fallback = 'expoinout' end
			if easing == sb_easing['elasticout'] then fallback = 'expoout' end
			if easing == sb_easing['elastichalfout'] then fallback = 'expoout' end
			if easing == sb_easing['elasticquarterout'] then fallback = 'expoout' end

			derivative = easing_derivatives[sb_easing[fallback]]
			easing_func = sb_easing.funcs[sb_easing[fallback]]
		end
	end

	local function func(t)
		return easing_func(t)*(b-a) + a
	end

	local depth = 1

	local t = 0.8

	local low, high = 0, 1
	local vlow, vhigh = func(0), func(1)

	local v = func(t)
	while math.abs(v) > tolerance do
		depth = depth+1
		if depth==32 then return 0.5*(low+high)*(t2-t1) + t1 end

		local dd = derivative(t) * (b-a)

		if vlow * v <= 0.0 then
			high = t
			vhigh = v
		else
			low = t
			vlow = v
		end

		local newton

		if dd~=0 and dd~=math.huge and dd~=-math.huge then
			newton = t - v/dd
		end

		if not newton or newton <= low or newton >= high then
			t = (low + high)/2.0
		else
			t = newton
		end

		v=func(t)
	end

	local result = t * (t2-t1) + t1

	if math.abs(func(result)) then
		print(string.format("Easing %s, Returning %g, f(%g)=%f",sb_easing.names[easing], result,result,func(result)))
	end

	return result
end

easing_derivatives[sb_easing["linear"]] = function(x)
	return 1
end

easing_derivatives[sb_easing["out"]] = function(x)
	return 2 - 2*x
end

easing_derivatives[sb_easing["in"]] = function(x)
	return 2*x
end

easing_derivatives[sb_easing["quadin"]] = function(x)
	return 2*x
end

easing_derivatives[sb_easing["quadout"]] = function(x)
	return 2 - 2*x
end

easing_derivatives[sb_easing["quadinout"]] = function(x)
	return x < 0.5 and 4*x or 4 - 4*x
end


easing_derivatives[sb_easing["cubicin"]] = function(x)
	return 3*x^2
end

easing_derivatives[sb_easing["cubicout"]] = function(x)
	return 3*(1-x)^2
end

easing_derivatives[sb_easing["cubicinout"]] = function(x)
	return x < 0.5 and 12*x^2 or 12*(1-x)^2
end


easing_derivatives[sb_easing["quartin"]] = function(x)
	return 4*x^3
end

easing_derivatives[sb_easing["quartout"]] = function(x)
	return 4*(1-x)^3
end

easing_derivatives[sb_easing["quartinout"]] = function(x)
	return x < 0.5 and 32*x^3 or 32*(1-x)^3
end


easing_derivatives[sb_easing["quintin"]] = function(x)
	return 5*x^4
end

easing_derivatives[sb_easing["quintout"]] = function(x)
	return 5*(1-x)^4
end

easing_derivatives[sb_easing["quintinout"]] = function(x)
	return x < 0.5 and 80*x^4 or 80*(1-x)^4
end


easing_derivatives[sb_easing["sinein"]] = function(x)
	return (math.pi/2) * math.sin((math.pi*x)/2)
end

easing_derivatives[sb_easing["sineout"]] = function(x)
	return (math.pi/2) * math.cos((math.pi*x)/2)
end

easing_derivatives[sb_easing["sineinout"]] = function(x)
	return (math.pi/2) * math.sin(math.pi*x)
end


local ln2 = math.log(2)

easing_derivatives[sb_easing["expoin"]] = function(x)
	return x == 0 and 0
		or (10*ln2) * 2^(10*x - 10)
end

easing_derivatives[sb_easing["expoout"]] = function(x)
	return x == 1 and 0
		or (10*ln2) * 2^(-10*x)
end

easing_derivatives[sb_easing["expoinout"]] = function(x)
	return x == 0 and 0
		or x == 1 and 0
		or x < 0.5
			and ((10*ln2) * 2^(20*x - 10))
			or ((10*ln2) * 2^(-20*x + 10))
end


easing_derivatives[sb_easing["circin"]] = function(x)
	return x == 1 and math.huge
		or x / math.sqrt(1 - x*x)
end

easing_derivatives[sb_easing["circout"]] = function(x)
	return x == 1 and 0
		or (1-x) / math.sqrt(1 - (1-x)^2)
end

easing_derivatives[sb_easing["circinout"]] = function(x)
	if x == 0 or x == 1 then
		return 0
	elseif x < 0.5 then
		return 2*x / math.sqrt(1 - 4*x*x)
	elseif x == 0.5 then
		return 0/0
	else
		return (1 - 2*x) / math.sqrt(1 - (2*x - 1)^2)
	end
end

for i=0,34 do
	easing_derivatives:find_root(i, 0, 1, -9, 1)
end

return easing_root
