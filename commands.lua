-- command definitions are made up of the following:
--
-- easing         - (a boolean for whether or not the command takes in an easing).
--
-- time_points    - (integer for how many time point arguments the command takes,
--                   all of the stock osu! storyboard commands take two time points, for the start
--                   point and the end point, with the exception of the Loop command which for the purpose
--                   of storyboard-helper only takes one start point, the loopCount argument being treated
--                   as a regular argument instead.
--                   Custom commands can in practice have any arbitrary number of time points.)
--
-- dimension      - (integer for how many dimensions the vector argument has,
--                   for example the stock osu! storyboard command Fade/Scale
--                   is 1 dimensional, Move/Vector Scale is 2, Color is 3
--                   0 dimensions is also allowed for other commands such as Parameter,
--                   which is equivalent to taking no vector argument at all.)
--
-- args           - (a table listing the names for all of the arguments the command takes in addition to
--                   the vector and time arguments, such as the parameter argument for the Parameter command).
-- args_valid     - (a table 1 to 1 with the arguments table containing functions to validate inputs.
--                   these return 'value', 'error'. if error is non-nil then an error is raised)
--
-- varargs        - (a boolean for whether or not the command takes in a variable unspecified number of arguments after
--                   the vector, time point and fixed arguments. these can be other commands. it's the
--                   varargs that compound commands like Loop operate on.)
-- eval           - (the function that evalutes the command, primitive commands have no eval function as they are
--                   the final step when evaluating a tree of compound commands.)
--
-- out            - (this is for the primitive commands only. function that outputs the intermediate representation form
--                   for the command (see ir.lua).
-- overlapping    - (this is a boolean for if this command is allowed to overlap with commands of the same type, used
--                   for things like relative transformations which can have their transformations combined in the overlap.)
-- absolute_equal - (this is a string specifying the name for the command which is the absolute (non-relative) version
--                   of this command if this is a relative command with the 'overlapping' flag on)
--

local sb_log  = require 'log'
local sb_time = require 'time'
local sb_easing = require 'easing'

local command = {
}

-- returns the easing, time, first vector, second vector, table of arguments, and table of variable arguments, of a command.
-- if target is a string ("easing", "time", "vec1", "vec2", "args", "varargs") only that
-- part is returned
function command:parseCommand(com, target)
	local clone = require 'clone'
	local step_easing, step_time, step_vec, step_args, step_varargs = false,false,false,false,false
	local target_easing, target_time, target_vec1, target_vec2, target_vec, target_args, target_varargs =
		false,false,false,false,false,false,false

	if target then
		local step_easing, step_time, step_vec, step_args, step_varargs = true,true,true,true,true
		if target=="easing" then step_easing=false target_easing = true end
		if target=="time" then step_time=false target_time = true end
		if target=="args" then step_args=false target_args = true end
		if target=="varargs" then step_varargs=false target_varargs = true end
		if target=="vec1" then step_vec=false target_vec1 = true end
		if target=="vec2" then step_vec=false target_vec2 = true end
		if target=="vec" then step_vec=false target_vec = true end
	end

	local com_type = com[1]
	local com_def = command[com_type]

	local i = 2
	local function step() i=i+1 end
	local function pop() i=i-1 end

	local ease
	local time
	local args
	local varargs
	local vec1,vec2 

	if step_easing and com_def.easing then
		step()
	elseif com_def.easing then
		ease = sb_easing[com[i]]
		sb_log:assert(ease and type(ease)=="number", "command '%s' expects an easing, got '%s'.", com_type, type(ease))

		step()
	end
	if target_easing then return ease end

	if step_time and com_def.time_points > 0 then
		step()
	elseif com_def.time_points > 0 then
		time = sb_time(table.unpack(com[i]))

		local count, err_str = sb_time:verify(time)

		if err_str then
			sb_log:error("command '%s' got a malformed time argument: %s", com_type, err_str)
		end

		sb_log:assert(count > 0,
			"command '%s' expects '%d' time point(s), got 0.", com_type, com_def.time_points)

		if count > com_def.time_points then
			sb_log:warn("command '%s' expects '%d' time point(s), got '%d'.", com_type, com_def.time_points, count)
		end

		local time_c = {}
		for j=1,math.min(com_def.time_points,count) do
			time_c[j] = time[j]
		end
		for j=count+1,com_def.time_points,1 do
			time_c[j] = time[count]
		end
		time = time_c

		step()
	end
	if target_time then return time end

	if step_vec and com_def.dimension > 0 then
		step()
		step()
	elseif com_def.dimension > 0 then
		vec1 = com[i]
		-- can be a table, or just a single number if dimension is 1
		sb_log:assert(vec1 and (type(vec1)=="table" or (type(vec1)=="number" and com_def.dimension==1)),
			"command '%s' expects a vector, argument is a '%s'.", com_type, type(vec1))
		if type(vec1) == "number" then vec1 = {vec1} end

		sb_log:assert(#vec1==com_def.dimension, "command '%s' expects a %dD vector, argument is %d.", com_type, com_def.dimension, #vec1)
		vec1 = clone(vec1)

		step()
		vec2 = com[i]

		-- shorthand, duplicate vector unless its a compound command/any command that takes in
		-- variable number of arguments afterwards
		if not vec2 and not com_def.varargs then
			vec2 = clone(vec1)
			pop()
		else
			-- can be a table, or just a single number if dimension is 1
			sb_log:assert(vec2 and (type(vec2)=="table" or (type(vec2)=="number" and com_def.dimension==1)),
				"command '%s' expects two vectors, second argument is a '%s'.", com_type, type(vec2))
			if type(vec2) == "number" then vec2 = {vec2} end
			sb_log:assert(#vec2==com_def.dimension, "command '%s' expects a %dD vector, argument is %d.", com_type, com_def.dimension, #vec2)
			vec2 = clone(vec2)
		end

		step()
	end

	if target_vec then return vec1, vec2 end
	if target_vec1 then return vec1 end
	if target_vec2 then return vec2 end

	if com_def.varargs then
		varargs = {}
		local k = 1
		for j=i,#com do
			varargs[k] = com[i]
			k=k+1
			step()
		end
	end
	if target_varargs then return varargs end

	if com_def.args then
		args={}
		for i,arg_name in ipairs(com_def.args) do
			local valid_func = com_def.args_valid[i]
			local A = com[arg_name]
			local err

			if valid_func then
				A,err = valid_func(A)

				sb_log:assert(err==nil,"invalid value for argument '%s' in command '%s', '%s'", arg_name, com_type, err)
			end
			
			args[arg_name] = A
		end
	end
	if target_args then return args end

	return ease, time, vec1, vec2, args, varargs
end

-- def - command definition
-- ... - (variable number of) string keys for the command.
command.___lock_out = false
function command:addDefinition(def, ...)
	sb_log:assert(def, "command.addDefinition(): missing command definition.")
	local keys = {...}
	sb_log:assert(#keys > 0, "command.addDefinition(): missing key names to assign to this command")

	local definition_str = " for \'"..keys[1].."\'"

	sb_log:assert(type(def.easing)=="boolean", "command.addDefinition(): malformed easing definition"..definition_str)
	sb_log:assert(type(def.time_points)=="number"
	              and math.type(def.time_points)=="integer"
								and def.time_points >= 0, "command.addDefinition(): malformed time points definition"..definition_str)
	sb_log:assert(type(def.dimension)=="number"
	              and math.type(def.dimension)=="integer"
								and def.time_points >= 0, "command.addDefinition(): malformed dimension(s) definition"..definition_str)

	sb_log:assert(type(def.args)=="table" or type(def.args)=="nil",
								"command.addDefinition(): malformed arg(s) table definition"..definition_str)
	for i,v in ipairs(def.args or {}) do
		sb_log:assert(type(v)=="string", "command.addDefinition(): malformed arg(s) table definition"..definition_str)
	end

	sb_log:assert(type(def.args_valid)=="table" or type(def.args_valid)=="nil",
								"command.addDefinition(): malformed arg(s) valid functions table definition"..definition_str)
	for i,v in pairs(def.args_valid or {}) do
		sb_log:assert(type(v)=="function" or type(v)=="nil", "command.addDefinition(): malformed arg(s) valod functions table definition"..definition_str)
	end
	sb_log:assert(type(def.varargs)=="boolean", "command.addDefinition(): malformed variable args definition"..definition_str)
	sb_log:assert(not (type(def.out)=="function" and command.___lock_out),
		"command.addDefinition(): the out function are fixed for primitives only.")


	sb_log:assert(type(def.overlapping)=="boolean" or def.overlapping==nil, "command.addDefinition(): malformed overlapping flag definition"..definition_str)
	def.overlapping = def.overlapping==true
	if def.overlapping then
		sb_log:assert(type(def.absolute_equal)=="string", "command.addDefinition(): malformed absolute_equal specifier definition"..definition_str)
	end

	sb_log:assert(type(def.eval)=="function" or type(def.eval)=="nil", "command.addDefinition(): malformed eval defintion"..definition_str)

	for i,v in ipairs(keys) do
		local str = v
		sb_log:assert(type(str)=="string",
			"command.addDefinition(): only strings are allowed to be used as keys for commands, got a '%s'.", type(str))
		str = str:lower()
		sb_log:assert(command[str]==nil, "command.addDefinition(): key [\"%s\"] is already in use.", str)
		command[str] = def
	end
end

command:addDefinition(require 'commands.root'       , '__root__', 'root')
command:addDefinition(require 'commands.move'       , 'm', 'move')
command:addDefinition(require 'commands.movex'      , 'mx', 'movex', 'move_x', 'm_x')
command:addDefinition(require 'commands.movey'      , 'my', 'movey', 'move_y', 'm_y')
command:addDefinition(require 'commands.fade'       , 'f', 'fade')
command:addDefinition(require 'commands.rotate'     , 'r', 'rotate', 'rot')
command:addDefinition(require 'commands.scale'      , 's', 'scale')
command:addDefinition(require 'commands.vector'     , 'v', 'vector', 'vectorscale', 'vector_scale')
command:addDefinition(require 'commands.parameter'  , 'p', 'parameter', 'param')
command:addDefinition(require 'commands.colour'     , 'c', 'col', 'color', 'colour')
command:addDefinition(require 'commands.originscale', 'originscale', 'os', 'origin_scale')
command:addDefinition(require 'commands.moverel'  , 'mr', 'mover', 'moverel', 'moverelative', 'm_r', 'move_r', 'move_rel', 'move_relative')
command:addDefinition(require 'commands.rotaterel', 'rr', 'rotr', 'rotrel', 'rotrelative', 'r_r', 'rot_r', 'rot_rel', 'rot_relative',
                                                    'rotater', 'rotaterel', 'rotaterelative', 'rotate_r', 'rotate_rel',
																										'rotate_relative')
command:addDefinition(require 'commands.scalerel' , 'sr', 'scaler', 'scalerel', 'scalerelative', 's_r', 'scale_r', 'scale_rel','scale_relative')
command:addDefinition(require 'commands.vectorrel', 'vr', 'vectorr', 'vectorrel', 'vectorrelative', 'v_r', 'vector_r', 'vector_rel',
                                                    'vector_relative')

command.___lock_out = true -- prevent future command definitions with an 'out' function

function command:type(c)
	sb_log:assert(c, "command.type(): no argument")
	local str = c[1]
	sb_log:assert(str, "command.type(): invalid command (no command type identifier)")
	return command[str]
end

-- checks if a command is of a given type, any equivalent alias for the command
-- can be used as an argument.
-- if multiple arguments are given, it checks if it is any one of the types
function command:equal(com, ...)
	local com_command = command[com[1]]
	local args = {...}
	for _,v in ipairs(args) do
		local C = command[v]
		sb_log:assert(C, "command:equal(): no such command '%s'", v)
		if C == com_command then
			return true
		end
	end
	return false
end

function command:isRelative(com)
	sb_log:assert(com, "command.isRelative(): no argument")
	local com_type = com[1]
	sb_log:assert(com_type, "command.isRelative(): malformed command, missing type?")
	return command[com_type].overlapping==true
end
function command:isAbsolute(com)
	sb_log:assert(com, "command.isAbsolute(): no argument")
	local com_type = com[1]
	sb_log:assert(com_type, "command.isAbsolute(): malformed command, missing type?")
	return command[com_type].overlapping~=true
end
function command:getAbsoluteVersion(com)
	if type(com) == "string" then
		return command[com].absolute_equal
	end

	if command:isRelative(com) then
		return command[com[1]].absolute_equal
	end
		return com[1]
end

function command:isRoot(com)
	sb_log:assert(com, "command.isRoot(): no argument")
	local com_type = com[1]
	sb_log:assert(com_type, "command.isRoot(): malformed command, missing type?")
	return command:equal(com, "__root__")
end

function command:out(com)
	sb_log:assert(com, "command.out(): no argument")
	local com_type = com[1]
	sb_log:assert(com_type, "command.out(): malformed command, missing type?")
	local out_func = command[com_type].out
	sb_log:assert(out_func,
		"command.out(): '%s' is not a primitive command, and cannot be outputted in a .osb format.", com_type)

	local easing, time, vec1, vec2, args, varargs = command:parseCommand(com)

	return out_func(time, easing, vec1, vec2, args, varargs)
end

-- creates a command based on the type.
-- this function does not support the normal shorthands for time and vectors since its
-- for internal logic use only.
function command:createCommand(com_type, easing, time, vec1, vec2, args, ...)
	local com_def = command[com_type]
	sb_log:assert(com_def, "command.createCommand(): unknown command '%s'.", (com_type))

	local result = {com_type}
	if com_def.easing then
		local c_easing = sb_easing[easing]
		sb_log:assert(c_easing, "command.createCommand(): command '%s' expects an easing, got '%s'.",
			com_type, (c_easing))
		table.insert(result, c_easing)
	end

	if com_def.time_points > 0 then
		local c_time, err = sb_time(table.unpack(time))
		sb_log:assert(not err, "command.createCommand(): command '%s' expects time, got an error: %s.",
			com_type, err)
		table.insert(result, time)
	end

	if com_def.dimension > 0 then
		sb_log:assert(vec1 and vec2, "command.createCommand(): command '%s' expects two vectors, got a '%s' and '%s'",
			com_type, type(vec1), type(vec2))
		sb_log:assert(#vec1 == com_def.dimension, "command.createCommand(): command '%s' expects vector of dimension %d, "..
			"start vector is dimension %d.",
			com_type, com_def.dimension, #vec1)
		sb_log:assert(#vec2 == com_def.dimension, "command.createCommand(): command '%s' expects vector of dimension %d, "..
			"end vector is dimension %d.",
			com_type, com_def.dimension, #vec2)
		table.insert(result, vec1)
		table.insert(result, vec2)
	end

	if com_def.varargs then
		for i,v in {...} do
			table.insert(result, v)
		end
	end

	if com_def.args then
		args = args or {}
		local valids = com_def.args_valid

		for i,v in ipairs(com_def.args) do
			local valid_func = valids[i] or function(x) return x end
			local value, err = valid_func(args[v])
			sb_log:assert(not err, "command.createCommand(): command '%s' got malformed argument for '%s': %s", com_type, v, err)
			result[v] = value
		end
	end

	return result
end

function command:scaleToVector(com)
	if command:equal(com, 's') then
		local easing,time,vec1,vec2 = command:parseCommand(com)
		return command:createCommand('v', easing, time, {vec1[1],vec[1]}, {vec2[1],vec2[1]})
	end
	if command:equal(com, 'sr') then
		local easing,time,vec1,vec2 = command:parseCommand(com)
		return command:createCommand('vr', easing, time, {vec1[1],vec[1]}, {vec2[1],vec2[1]})
	end
end

-- if two commands share the same type and timepoint,
-- this will create their combined result
--
-- this is only useful for relative commands
function command:createCommandAddition(c1,c2)
	local type1,type2 = c1[1],c2[1]
	sb_log:assert(type1==type2, "command:createCommandAddition(): expected same command types, got '%s' and '%s'", type1,type2)

	sb_log:assert(command[type1].overlapping, "command:createCommandAddition(): command '%s' doesn't support overlaps/addition.", type1)

	local time1 = command:parseCommand(c1, "time")
	local time2 = command:parseCommand(c2, "time")
	for i,v in ipairs(time1) do
		sb_log:assert(time1[i]==time2[i], "command:createCommandAddition(): expected same time points, got '%s' and '%s'", time1[i], time2[i])
	end

	local vec1_1,vec1_2 = command:parseCommand(c1, "vec")
	local vec2_1,vec2_2 = command:parseCommand(c2, "vec")

	local new_vec1, new_vec2 = {},{}
	for i = 1, #vec1_1 do
		new_vec1[i] = vec1_1[i] + vec2_1[i]
		new_vec2[i] = vec1_2[i] + vec2_2[i]
	end

	local easing = command:parseCommand(c1, "easing")

	local c = command:createCommand(type1, easing, time1, new_vec1, new_vec2)
	return c
end

function command:getTimeSpan(...)
end

-- 
-- not serialised (doesn't seriaise args or varargs), only for debugging purposes
--
function command:toString(com)
	if type(com)~="table" then
		return tostring(com)
	end

	local easing, time, vec1, vec2, args, varargs = command:parseCommand(com)
	local result = "{"..com[1]

	if easing then result=result..","..tostring(easing) end
	if time then
		local vec1s = "{"
		for i,v in ipairs(time) do
			vec1s=vec1s..v
			if i~=#vec1 then vec1s=vec1s.."," end
		end
		result=result..","..vec1s.."}"
	end
	if vec1 then
		local vec1s = "{"
		for i,v in ipairs(vec1) do
			vec1s=vec1s..v
			if i~=#vec1 then vec1s=vec1s.."," end
		end
		result=result..","..vec1s.."}"
	end
	if vec2 then
		local vec2s = "{"
		for i,v in ipairs(vec2) do
			vec2s=vec2s..v
			if i~=#vec2 then vec2s=vec2s.."," end
		end
		result=result..","..vec2s.."}"
	end
	if args then
		result=result.."{"

		for i,v in pairs(args) do
			result=result..string.format("%s=%s",tostring(i),tostring(v))
			result=result..","
		end
		result=result.."}"
	end
	if varargs then
		result=result..", ... " end
	result = result.."}"
	return result
end

local command_mt={}
function command_mt.__index(table,key)
	if type(key)=="string" then
		local r = rawget(table,key:lower())
		sb_log:assert(r, "command[]: unknown command '%s'",key)
		return r
	end
end
setmetatable(command,command_mt)

--command:parseCommand{	"m", 01, {"00:01:500"}, {320, 240}, {360, 280} }
--

return command
