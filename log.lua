require 'table'
require 'string'
require 'io'

local log = {
	__out = io.stdout,
	__silent = false,
	__silent_stack = false,
}
log.__index = {}

log.history = {}
log.eval_stack = { [0]=0 }

function log:silent(b)
	self.__silent = (b~=nil)
end

function log:addToStack(command)
	log.eval_stack[0] = log.eval_stack[0] + 1
	log.eval_stack[ log.eval_stack[0] ] = command
end

function log:popStack()
	if log.eval_stack[0] == 0 then return end
	log.eval_stack[0] = log.eval_stack[0] - 1
	log.eval_stack[ log.eval_stack[0]+1 ] = nil
end

function log:evalStackTraceback()
	local result = ""

	-- TODO
end

function log:warn(fstr, ...)
	local str = "//[warning] "

	if fstr then
		str=str..string.format(fstr,...)
	end

	table.insert(log.history,str)

	local sb_config = require 'config'
	if not sb_config["-silent"] and self.__out then
		self.__out:write(str)
		self.__out:write('\n')
	end
end

function log:error(fstr, ...)
	local str = "//[error] "

	if fstr then
		str=str..string.format(fstr,...)
	end

	table.insert(log.history,str)

	local sb_config = require 'config'
	if not sb_config["-silent"] and self.__out then
		self.__out:write(str)
		self.__out:write('\n')
		error("Aborting.")
	else
		error(str)
	end
end

function log:assert(a, fstr, ...)
	if a then return end

	local str = "//[error] "

	if fstr then
		str=str..string.format(fstr,...)
	end

	table.insert(log.history,str)

	local sb_config = require 'config'
	if not sb_config["-silent"] and self.__out then
		self.__out:write(str)
		self.__out:write('\n')
		error("Aborting.")
	else
		error(str)
	end
end

return log
