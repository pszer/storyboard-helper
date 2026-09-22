-- intermediate representation form
--
-- tables 1:1 with .osb form, 
--
local sb_config = require 'config'
local sb_ir={}
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

function sb_ir:out()
	local x=x or 360
	local y=y or 240

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
			local int,frac = math.modf(x)
			if frac==0 or math.abs(frac)<0.0001 then
				x=string.format("%d",int)
			else
				x=string.format("%f",x)
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
