--
-- a command is a table containing a command type and arguments for the given command,
-- what arguments are needed depend on the command.
--
-- it is similar to how commands are written in the regular osu! storyboard format,
-- with more freedom to how some arguments, namely the easing and time, can be written:
-- for example easings can be written by names like 'linear' or 'cubicIn', and time points in "mm:ss:mss"
-- format.
--
-- Example:
-- { "move", "linear", {"00:01:000", "00:01:500"}, {10,10}, {50,50} }
-- { "rotate", 0, {50,500}, 0.0, 3.142 }
--
--
-- some commands require arguments passed through a key value in the table,
-- and can also take in variable number of arguments, which is how compound commands are made.
-- for example the powerful keyframe command used for animating sequential/complex transformations
-- takes in the command it animates as an argument ["action"], and a list of time point and vectors after it.
--
-- { "keyframe", action = "move",
--   {"0:00:100", 200, 300},
--   {"0:00:200", 230, 280},
--   {"0:00:300", 260, 260},
--   ...
--
-- the value of this system is that it simplifies the creation of commands programmatically, and enables
-- the making of new and more customisable commands later on, such as movement of sprites in 3D space or
-- paper animation style flipping of sprites, the keyframer, and importantly: relative transformations.
--
-- the stock commands support the same 'Start and End Values/Times are the Same' shorthands
-- as described in _ https://osu.ppy.sh/wiki/en/Storyboard/Scripting/Shorthand _ for the .osb format,
-- but not 'Same Event, Same Duration, Sequentially', since the same thing can be done with
-- much more powerful and programmable compound commands.
-- 
-- example
-- { "move", 0, {500,500}, {320,240}, {320,240} }
-- can be written as
-- { "move", 0, {500}, {320,240} }
--
--
-- list of commands
--

local modules = (...):gsub('%.[^%.]+$', '') .. "."
local sb_command = require (modules..'commands')
local sb_log = require (modules..'log')

local out_table_mt = {}
function out_table_mt.__call(t, ...)
	local args = {...}
	for _,v in ipairs(args) do
		table.insert(t, v)
	end
end

local function eval(t)
	-- evaluate Lua functions.
	-- allows Lua commands that return commands to be a
	-- type of evaluatable command by themselves
	--
	--
	-- since
	--
	--```
	-- function()
	--   local out = {}
	--   ...
	--   table.insert(out, [[command 1]])
	--   table.insert(out, [[command 2]])
	--   table.insert(out, [[command 3]])
	--   ...
	--   return table.unpack(out)
	-- end
	--```
	--
	-- is a common pattern, the function is passed a table
	-- in which to output commands into, as an argument.
	--
	-- furthermore, this table has a __call metamethod, which
	-- will automatically insert any arguments it gets into
	-- the table, so there is no need to write out table.insert
	-- calls.
	--
	-- the above becomes
	--
	--```
	-- function(out)
	--   ...
	--   out( [[command 1]] )
	--   out( [[command 2]] )
	--   out( [[command 3]] )
	--   ...
	-- end
	--```
	

	if type(t)=="function" then
		local collect_out = {}
		setmetatable(collect_out, out_table_mt)

		local eval_pass = {t(collect_out)}
		local eval_result = {}

		for i,v in ipairs(eval_pass) do
			local v_eval = {eval(v)}
			for j,w in ipairs(v_eval) do
				table.insert(eval_result, w)
			end
		end
		for i,v in ipairs(collect_out) do
			local v_eval = {eval(v)}
			for j,w in ipairs(v_eval) do
				table.insert(eval_result, w)
			end
		end
		return table.unpack(eval_result)
	end
	--
	
	-- evaluate commands
	local com_type = t and t[1]
	sb_log:assert(com_type, "eval(): malformed command, missing type? t[1] got %s", t[1])

	if not sb_command[com_type].eval then
		return t
	end

	sb_log:addToStack(t)

	local ease, time, vec1, vec2, args, varargs = sb_command:parse(t)
	local eval_pass = { sb_command[com_type].eval(ease, time, vec1, vec2, args, varargs, t) }
	local eval_result = {}

	for i,v in ipairs(eval_pass) do
		if v == t then
			table.insert(eval_result, t)
		else
			local v_eval = {eval(v)}
			for j,w in ipairs(v_eval) do
				table.insert(eval_result, w)
			end
		end
	end

	sb_log:popStack(t)

	return table.unpack(eval_result)
end

return eval
