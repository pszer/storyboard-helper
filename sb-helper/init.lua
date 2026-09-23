local modules = (...) and (...):gsub('%.init$', '') .. "." or ""

local sb = {
	_LICENSE = "",
	_URL = "https://github.com/pszer/storyboard-helper",
	_DESCRIPTION = "Lua compiler for scripting 'osu!' .osb storyboards."
}

for i,v in pairs(require (modules .. 'storyboard')) do
	sb[i] = v
end
sb._VERSION = (require (modules .. 'version')):toString()
require (modules .. 'load_commands')

return sb
