local modules = (...) and (...):gsub('%.init$', '') .. ".modules." or ""

local sb = {
	_LICENSE = "",
	_URL = "https://github.com/pszer/storyboard-helper",
	_VERSION = "1.2.9",
	_DESCRIPTION = "Lua compiler for scripting 'osu!' .osb storyboards."
}

for i,v in pairs(require 'storyboard') do
	sb[i] = v
end
require 'load_commands'

return sb
