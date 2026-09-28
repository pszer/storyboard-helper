-- intermediate representation form
--
-- tables 1:1 with .osb form, 
--
local modules = (...):gsub('%.[^%.]+$', '') .. "."
local sb_config = require (modules..'config')
local sb_ir={
	dont_floor_time = false
}
sb_ir.__index = sb_ir

function sb_ir:new(...)
	local t = {...}
	setmetatable(t,sb_ir)
	return t
end

aa="S,0,50,100,0,1"
aa="M,0,50,100,0,0,1,1"

function sb_ir:getStart()
	--if self[1]=="L" then return self[2] end
	return self[3]
end

function sb_ir:getEnd()
	return self[4]
end

local __base10 = {
}
for i=-2,8 do
	__base10[i] = 10^i
end
function sb_ir:limitDecimalPlaces(str, dp)
	local DP_i = str:find('%.')
	if not DP_i then return str end

	local result
	if dp==0 then result = str:sub(1,DP_i-1)
	else result = str:sub(1,DP_i+dp) end

	-- get rid of any trailing zeros
	for i=#result,DP_i+1,-1 do
		if result:byte(i) ~= string.byte('0') then
			if i~=#result then
				result = result:sub(1,i)
			end
			break
		end
	end
	return result
end

function sb_ir:floorTime(x)
	if sb_ir.dont_floor_time then
		return x end
	return math.floor(x)
end

function sb_ir:out()
	local x=x or 360
	local y=y or 240

	local decimal_points = 5

	local time_shortcut=false
	for i,v in ipairs{"F","M","S","V","MX","MY","R","C"} do
		if v==self[1] then time_shortcut=true break end end
	local vec1_shortcut=false
	local vec2_shortcut=false
	local vec3_shortcut=false
	for i,v in ipairs{"F","S","MX","MY","R"} do
		if v==self[1] then vec1_shortcut=true break end end
	for i,v in ipairs{"M","V"} do
		if v==self[1] then vec2_shortcut=true break end end
	for i,v in ipairs{"C"} do
		if v==self[1] then vec3_shortcut=true break end end

	if self[1]=='V' then decimal_points = sb_config['output-scale-decimal-points']
	elseif self[1]=='S' then decimal_points = sb_config['output-scale-decimal-points']
	elseif self[1]=='R' then decimal_points = sb_config['output-rotate-decimal-points']
	elseif self[1]=='M' then decimal_points = sb_config['output-move-decimal-points']
	elseif self[1]=='F' then decimal_points = sb_config['output-fade-decimal-points']
	elseif self[1]=='C' then decimal_points = sb_config['output-colour-decimal-points'] end

	if time_shortcut and self[3]~=self[4] then time_shortcut = false end
	if vec1_shortcut and self[6]~=self[7] then vec1_shortcut = false end
	if vec2_shortcut and (self[5]~=self[7] or self[6]~=self[8]) then vec2_shortcut = false end
	if vec3_shortcut and (self[5]~=self[8] or self[6]~=self[9] or self[7]~=self[10]) then vec3_shortcut = false end

	local c = #self
	local result = sb_config["whitespace"]
	if result~=" " and result~="_" then result = "_" end
	for i,v in ipairs(self) do
		local x = v

		local skip_comma = false
		if time_shortcut and i==4 then x="" end

		if vec1_shortcut and i==6 then x="" skip_comma = true end
		if vec1_shortcut and i==5 then skip_comma = true end

		if vec2_shortcut and i>=7 and i<=8 then x="" skip_comma = true end
		if vec2_shortcut and i==6 then skip_comma = true end

		if vec3_shortcut and i>=8 and i<=10 then x="" skip_comma = true end
		if vec3_shortcut and i==7 then skip_comma = true end

		if type(x)=="number" then
			if math.tointeger(x) then
				x=string.format("%d",math.tointeger(x))
			else
				x=string.format("%s", self:limitDecimalPlaces(tostring(x), decimal_points))
			end
		end

		result=result..x
		if i<c and not skip_comma then
			result=result..","
		end
	end

	return result
end

return sb_ir
