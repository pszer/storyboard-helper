require 'string'
local sb_anchor = require 'anchor'
local sb_file   = require 'file'
local sb_layer  = require 'layer'
local sb_log    = require 'log'
local sb_com    = require 'commands'
local sb_ir     = require 'ir'
local sb_eval   = require 'eval'
local sb_config = require 'config'
local sb_verify = require 'verify'

local object = {}
object.__index = object

-- ...
--
-- for Sprite,    anchor x y
-- for Animation, anchor x y frame_count frame_delay loop_type
-- for Sample,    time volume
function object:new(file,layer,...)
	local t = {
		layer = sb_layer:correctInput(layer),
		file = sb_file:new(file),

		file_type = nil,
		object_type = nil,

		x=nil,--sprite
		y=nil,--sprite
		frame_count=nil,--animation
		frame_delay=nil,--animation
		loop_type=nil,--animation
		time=nil,--sample
		volume=nil,--sample

		commands=nil
	}
	setmetatable(t, object)

	sb_log:assert(t.file, "object:new(): bad file '%s'.", file)
	sb_log:assert(t.layer, "object:new(): bad layer '%s'.", layer)
	t.file_type   = t.file:getFilenameType()
	t.object_type = t:getObjectType()

	local arg = {...}

	local function checkArgCount(otype, expected)
		if arg[expected+1] then
			local ct = tostring(file)..","..tostring(layer)..","
			for i,v in ipairs(arg) do
				ct=ct..tostring(v)
				if i~=#arg then ct=ct.."," end
			end
			sb_log:warn("object:new(): %s object got %d too many arguments, ensure this makes sense (%s)",
				otype, #arg-expected, ct)
		end
	end

	if t.file_type == "image" then
		sb_log:assert(arg[1], "object:new(): no anchor.")
		t.anchor = sb_anchor:correctInput(arg[1])
		sb_log:assert(t.anchor, "object:new(): bad anchor '%s'.", arg[1])

		sb_log:assert(type(arg[2])=="number",
			"object:new(): expected number for x position, got '%s'",arg[2])
		t.x = tonumber(arg[2]) or 320
		sb_log:assert(type(arg[3])=="number",
			"object:new(): expected number for y position, got '%s'",arg[2])
		t.y = tonumber(arg[3]) or 240

		if t.object_type == "Animation" then
			sb_log:assert(arg[4], "object:new(): Animation object expects a frame count.")
			t.frame_count = math.floor(tonumber(arg[4]))
			sb_log:assert(t.frame_count>=1,
				"object:new(): Animation object frame count should be 1 or higher, got '%s'.",
				arg[4])

			sb_log:assert(arg[5], "object:new(): Animation object expects a frame delay.")
			t.frame_delay = math.floor(tonumber(arg[5]))
			sb_log:assert(t.frame_delay >= 1,
				"object:new(): Animation frame delay should be 1 or higher, got '%s'.",
				arg[5])

			sb_log:assert(arg[6]:lower()=="looponce" or arg[6]:lower()=="loopforever",
				"object:new(): Animation object expects a loop_type of LoopOnce or LoopForever")
			if arg[6]:lower()=="looponce" then
				t.loop_type = "LoopOnce"
			else
				t.loop_type = "LoopForever"
			end

			-- check if too many arguments for an Animation
			checkArgCount("Animation",6)
			--
		else
			--
			checkArgCount("Sprite",3)
			--
		end
	else
			sb_log:assert(arg[1], "object:new(): Sample object expects a time.")
			t.time = math.floor(tonumber(arg[1]))

			sb_log:assert(arg[2], "object:new(): Sample object expects a volume.")
			t.volume = math.floor(tonumber(arg[2]))
			if t.volume<0 then t.volume=0 end
			if t.volume>100 then t.volume=100 end

			--
			checkArgCount("Sample",2)
			--
	end

	return t
end

function object:getObjectType()
	if self.object_type then return self.object_type end

	local ftype = self.file:getFilenameType()

	if ftype=="audio" then return "Sample" end
	if ftype=="image" then
		if anim_args then return "Animation" end
		return "Sprite"
	end

	sb_log:error("object:objectType(): cannot determine type")
end

function object:getImageSize()
	if self.file_type ~= "image" then
		sb_log:error("object:getImageSize(): not an image.")
	end

	return self.file.w, self.file.h
end

function object:getAnchorPosition(x,y)
	if self.file_type ~= "image" then
		sb_log:error("object:getImageSize(): not an image.")
	end

	local w,h = self:getImageSize()
	local anc = sb_anchor.func[self.anchor]

	return anc(x,y,w,h)
end

function object:add(...)
	local commands = {...}

	if commands[1] and not self.commands then self.commands = {} end

	for i,v in ipairs(commands) do
		table.insert(self.commands,v)
	end

	return self
end

function object:out(...)
	local header = self:getObjectType()

	if header=="Sample" then
		header=string.format("Sample,%d,%d,\"%s\",%d",
			self.time,sb_layer:out(self.layer),self.file:out(),self.volume)
	elseif header=="Sprite" then
		header=string.format("Sprite,%d,%d,\"%s\",%d,%d",
			sb_layer:out(self.layer),sb_anchor:out(self.anchor),self.file:out(),self.x,self.y)
	elseif header=="Animation" then
		header=string.format("Animation,%d,%d,\"%s\",%d,%d,%d,%d,%s",
			sb_layer:out(self.layer),sb_anchor:out(self.anchor),self.file:out(),self.x,self.y,
			 self.frame_count, self.frame_delay, self.loop_type)
	end

	local commands_concat = {table.unpack(self.commands or {})}
	for i,v in ipairs{...} do
		table.insert(commands_concat, v)
	end

	if commands_concat[1] then
		local evaluated = {
			sb_com:evalTop({
				start_x     = self.x,
				start_y     = self.y,
				start_sx    = self.sx or 1,
				start_sy    = self.sy or 1,
				start_r     = self.r or 0,
				start_col_r = self.col_r or 255,
				start_col_g = self.col_g or 255,
				start_col_b = self.col_b or 255},
				table.unpack(commands_concat))
		}

		if not sb_config["unsorted-output"] then
			sb_verify:sortCommandsByTime(evaluated)
		end

		for i,com in ipairs(evaluated) do
			local com_ir  = sb_com:out(com)
			local com_str = com_ir:out()
			header=header.."\n"..com_str
		end
	end

	return header
end

return object
