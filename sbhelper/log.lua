local modules = (...):gsub('%.[^%.]+$', '') .. "."

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

--function log:()
--end

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
	local sb_com = require (modules..'commands')
	local result = "\nCommand eval traceback:\n"

	for i=log.eval_stack[0], 1, -1 do
		result = result.."["..tostring(i).."]   "..sb_com:toStringSafe(log.eval_stack[i]).."\n"
	end

	return result
end

function log:printf(fstr, ...)
	local sb_config = require (modules..'config')
	if not sb_config["-silent"] and self.__out then
		self.__out:write(string.format(fstr, ... ))
		self.__out:write('\n')
	end
end

function log:initProgressBar(r, width)
	local result = ""
	for i=1,width do
		if (width-i)/width < (1.0-r) then
			result = result..'-'
		else
			result = result..'#'
		end
	end
	result = result.." "..math.floor(r*100).."%"
	--log:printf(result)
	self.__out:write(result)

	return function(r)
		local result = "\r"
		for i=1,width do
			if (width-i)/width < (1.0-r) then
				result = result..'-'
			else
				result = result..'#'
			end
		end
	result = result.." "..math.floor(r*100).."%     "
		self.__out:write(result)
	end
end

function log:clearProgressBar()
	self.__out:write('\r\rDone.                   \n')
end

function log:warn(fstr, ...)
	local str = "//[warning] "

	if fstr then
		str=str..string.format(fstr,...).."\n"
	end

	table.insert(log.history,str)

	local sb_config = require (modules..'config')
	if not sb_config["-silent"] and self.__out then
		self.__out:write(str)
		self.__out:write('\n')
	end
end

function log:error(fstr, ...)
	local str = "//[error] "

	if fstr then
		str=str..string.format(fstr,...).."\n"
	end

	str = str..log:evalStackTraceback()

	table.insert(log.history,str)

	local sb_config = require (modules..'config')
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
		str=str..string.format(fstr,...).."\n"
	end

	str = str..log:evalStackTraceback()

	table.insert(log.history,str)

	local sb_config = require (modules..'config')
	if not sb_config["-silent"] and self.__out then
		self.__out:write(str)
		self.__out:write('\n')
		error("Aborting.")
	else
		error(str)
	end
end

return log
