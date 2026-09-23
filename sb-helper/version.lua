local modules = (...):gsub('%.[^%.]+$', '') .. "."
local sb_log = require (modules..'log')
local sb_config = require (modules..'config')

local version =
{
	0, 1
}

function version:toString()
	return string.format("%d.%d", version[1], version[2])
end

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
			sb_log:warn("This storyboard script is written for an older version of Storyboard Helper %s, your version is %s.",
				str(ver), str(version))
			return false
		end

		if v>version[i] and not sb_config["ignore-version"] then
			sb_log:error("This storyboard script is written for a newer version of Storyboard Helper %s, your version is %s. "..
			"Enable -ignore-version to run anyway.",
				str(ver), str(version))
		elseif v>version[i] then
			return false
		end
	end

	return true
end

return version
