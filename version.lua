local sb_log = require 'log'
local sb_config = require 'config'

local version =
{
	0, 1
}

function version:verify(ver)
	local function str(t)
		local result = ""
		for i,v in ipairs(t) do
			result=result..tostring(v)
			if i~=#t then result=result.."." end
		end
		return result
	end

	for i,v in ipairs(ver) do
		if v<version[i] then
			sb_log:warn(string.format("This storyboard script is written for an older version of Storyboard Helper %s, your version is %s.",
				str(ver), str(version)))
			return false
		end

		if v>version[i] and not sb_config["ignore-version"] then
			sb_log:error(string.format("This storyboard script is written for a newer version of Storyboard Helper %s, your version is %s. "..
			"Enable -ignore-version to run anyway.",
				str(ver), str(version)))
		elseif v>version[i] then
			return false
		end
	end

	return true
end

return version
