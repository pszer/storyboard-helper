require 'table'
require 'string'
require 'io'

local log = {
	__out = io.stdout,
	__silent = false,

	["-ignore-large-time-points"] = false,
	["-allow-no-leading-zeroes"] = false,
	["-allow-non-linear-easing-overlaps"] = false,
}
log.__index = {}

log.history = {}

function log:silent(b)
	self.__silent = (b~=nil)
end

function log:warn(...)
	local arg = {...}
	local str = "//[warning] "
	for i,v in ipairs(arg) do
		str=str..tostring(v)
	end

	table.insert(log.history,str)

	local sb_config = require 'config'
	if not sb_config["-silent"] and self.__out then
		self.__out:write(str)
		self.__out:write('\n')
	end
end

function log:error(...)
	local arg = {...}
	local str = "//[error] "
	for i,v in ipairs(arg) do
		str=str..tostring(v)
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

function log:assert(a, ...)
	if a then return end

	local arg = {...}
	local str = "//[error] "
	for i,v in ipairs(arg) do
		str=str..tostring(v)
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
