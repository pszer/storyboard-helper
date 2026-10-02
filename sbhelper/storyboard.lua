require 'io'

local modules = (...):gsub('%.[^%.]+$', '') .. "."
local sb_layer = require (modules..'layer')
local sb_object = require (modules..'object')
local sb_log = require (modules..'log')

local storyboard = {

	layer = sb_layer,
	object = sb_object,
	log = sb_log,

	com = require (modules..'commands'),
	easing = require (modules..'easing'),
	keyframe = require (modules..'keyframe'),
	time = require (modules..'time'),
	file = require (modules..'file'),
	verify = require (modules..'verify'),
	eval = require (modules..'eval'),
	ir = require (modules..'ir'),
	clone = require (modules..'clone'),

	-- 3d functionality
	tri = require (modules..'tri'),
	m3d = require (modules..'model'),

	unpack = table.unpack or unpack,

	concadd = function(...)
		local args = {...}
		local result = {}
		for i,T in ipairs(args) do
			for j,v in ipairs(T) do
				table.insert(result, v)
			end
		end

		return table.unpack(result)
	end

}
storyboard.__index = storyboard

function storyboard:new(filename, ...)
	local sb = {
		filename = filename or "Storyboard.osb",
		objects = {...},
	}
	setmetatable(sb, storyboard)
	return sb
end

local function filter(t, predicate)
	local result = {}
	for i,v in ipairs(t) do
		if predicate(v) then
			table.insert(result, v)
		end
	end
	return result
end
function storyboard:filterObjectsToLayer(layer)
	layer = sb_layer:out(sb_layer:correctInput(layer))
	return filter(self.objects,
		function(obj)
			return sb_layer:out(obj.layer) == layer
		end)
end

function storyboard:newObject(...)
	local obj = sb_object:new(...)
	if obj then table.insert(self.objects, obj) end
	return obj
end
function storyboard:addObject(...)
	local args = {...}

	if args[1] then
		for i,v in ipairs(args) do
			table.insert(self.objects, v)
		end
	end
end

function storyboard:out()
	local backgrounds = self:filterObjectsToLayer(0)
	local foregrounds = self:filterObjectsToLayer(3)
	local fail = self:filterObjectsToLayer(1)
	local pass = self:filterObjectsToLayer(2)
	local overlays = self:filterObjectsToLayer(4)

	local function get(t)
		local str = ""
		for i,v in ipairs(t) do
			str = str .. v:out() .. "\n"
		end
		return str
	end

	local variables = "[Variables]\n"
	local header = [[[Events]
//Background and Video events
//Storyboard Layer 0 (Background)
]]..
	get(backgrounds) ..
"//Storyboard Layer 1 (Fail)\n"..
	get(fail)..
"//Storyboard Layer 2 (Pass)\n"..
	get(pass)..
"//Storyboard Layer 3 (Foreground)\n"..
	get(foregrounds)..
"//Storyboard Layer 4 (Overlays)\n"..
	get(overlays)

	return variables .. header
end

function storyboard:out_file(f)
	local backgrounds = self:filterObjectsToLayer(0)
	local foregrounds = self:filterObjectsToLayer(3)
	local fail = self:filterObjectsToLayer(1)
	local pass = self:filterObjectsToLayer(2)
	local overlays = self:filterObjectsToLayer(4)

	local function get(t)
		--local str = ""
		for i,v in ipairs(t) do
			local str = v:out()
			f:write(str,'\n')
			--str = str .. v:out() .. "\n"
		end
		--return str
	end

	f:write("[Variables]\n")
	f:write([[[Events]
//Background and Video events
//Storyboard Layer 0 (Background)
]])
	get(backgrounds) 
	f:write("//Storyboard Layer 1 (Fail)\n")
	get(fail)
	f:write("//Storyboard Layer 2 (Pass)\n")
	get(pass)
	f:write("//Storyboard Layer 3 (Foreground)\n")
	get(foregrounds)
	f:write("//Storyboard Layer 4 (Overlays)\n")
	get(overlays)
end

function storyboard:writeToFile(f, overwrite)
	f = f or self.filename
	local file, err_str, err_num = io.open(f, "w")
	if not file then
		sb_log:error("storyboard:writeToFile(): couldn't write to '%s', %s %d", f, err_str, err_num or 0)
	end

	local str_out = self:out()
	file:write(str_out)

	            -- subtract modulo 32 to simplify decimal points
	local kb = (#str_out - #str_out%64) / 1024.0
	sb_log:printf("storyboard:writeToFile(): Written %g KiB to %s", kb, f)
	file:close()
end

function storyboard:writeToFile2(f, overwrite)
	f = f or self.filename
	local file, err_str, err_num = io.open(f, "w")
	if not file then
		sb_log:error("storyboard:writeToFile(): couldn't write to '%s', %s %d", f, err_str, err_num or 0)
	end

	self:out_file(file)
	            -- subtract modulo 32 to simplify decimal points
	local size = file:seek('end')
	local kb = (size - size%64) / 1024.0
	sb_log:printf("storyboard:writeToFile(): Written %g KiB to %s", kb, f)
	file:close()
end

return storyboard
