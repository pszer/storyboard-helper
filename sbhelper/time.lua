-- time information is stored in ordered sets, for the
-- stock osu! storyboard commands these will always be
-- a start and end point pair such as time(50,100)
--
-- time points can be millisecond integers, such
-- as 135950, a string integer like "135950", in a
-- minute, second and millisecond time formatted string like
-- "02:15:950", (seconds or milliseconds in this string must be positive,
-- but negative minutes turns the whole time point negative)
--
-- or an {{offset, BPM}, nth_beat} table which
-- specifies the time for the Nth 1/1 beat for a timing point
-- with a given offset and BPM.
--
-- floating point milliseconds are also accepted and work in
-- calculations, such as 135950.511 or "02:15:950.511", but
-- these time points will become truncated for the final
-- storyboard.

local modules = (...):gsub('%.[^%.]+$', '') .. "."
local sb_log = require (modules..'log')
local sb_config = require (modules..'config')

local time = {}
local time_mt = {}
time_mt.__call = function(t,...)
	local arg = {...}
	local points = {}

	for i,v in ipairs(arg) do
		table.insert(points, time:convert(v))
	end

	return points
end
setmetatable(time, time_mt)

-- verifies a table is a table of numbers, in increasing or equal order.
-- returns number of time points, and nil if correct
-- otherwise returns a number, and an error string
function time:verify(t)
	local last = -1/0.0
	local count
	if type(t)=="number" then
		count = 1
	elseif type(t)=="table" then
		count = 0
		for i,v in ipairs(t) do

			if type(v)~="number" then
				return count, string.format("time has to be a number (got '%s').",type(v))
			end

			count = count + 1
			if v < last then
				return count, string.format("time points points can't go backwards ('%g' '%g').",last,v)
			end
			last = v

		end
	else
		count = 0, string.format("got no time points.")
	end

	return count, nil
end

function time:getMinMax(t)
	local min,max= 1.0/0.0, -1.0/0.0
	for i,v in ipairs(t) do
		if v < min then min = v end
		if v > max then max = v end
	end
	return min,max
end

function time:convert(x)
	local large_number_warning = 
		"large time point '%s' greater than 1.5 hours detected, "..
		"suppress warning with -ignore-large-time-points if this makes sense."

	if type(x)=="number" then
		if x > 5400000 and not sb_config["ignore-large-time-points"] then
			sb_log:warn(large_number_warning,x)
		end
		return x
	end

	local mm_ss_mms = {nil,nil,nil}

	if type(x)=="string" then
		local first_colon_i,first_colon_j = x:find(":")

		-- if no colon, treat it as a single millisecond number
		if not first_colon_i then
			local result = tonumber(x)
			if not result then
				return sb_log:error("'%s' is a malformed millisecond time point.", x)
			end

			if result > 5400000 and not sb_config["ignore-large-time-points"] then
				sb_log:warn(large_number_warning,x)
			end
			return result
		end

		local second_colon_i,second_colon_j = x:find("%:[^%:]*$")

		local Ms,Ss,MSs =
			x:sub(1,first_colon_i-1),
			x:sub(first_colon_i+1,second_colon_i-1),
			x:sub(second_colon_i+1,-1)

		local M,S,MS=
			tonumber(Ms),
			tonumber(Ss),
			tonumber(MSs)

		-- if M is -0 instead of 0, the time point should still be negated
		local negate = false

		--ms
		sb_log:assert(MS,"'%s' is a malformed mm:ss:mms time point. (%s)", x, MSs)
		sb_log:assert(MS>=0 and MS<=999,
			"'%s' is a malformed mm:ss:mms time point. (%s milliseconds is outside bound [0,999])", x, MSs)
		--

		--s
		sb_log:assert(S,"'%s' is a malformed mm:ss:mms time point. (%s)", x, Ss)
		sb_log:assert(S>=0 and S<=59,
			"'%s' is a malformed mm:ss:mms time point. (%s seconds is outside bound [0,59])", x, Ss)
		sb_log:assert(math.type(S)=="integer",
			"'%s' is a malformed mm:ss:mms time point. (%s seconds is not an integer)", x, Ss)
		--

		--m
		sb_log:assert(M,"'%s' is a malformed mm:ss:mms time point. (%s)", x, Ms)
		sb_log:assert(math.type(M)=="integer",
			"'%s' is a malformed mm:ss:mms time point. (%s minutes is not an integer)", x, Ms)
		if M==0 and Ms:byte(1) == string.byte('-') then
			negate = true
		end

		--
		--
		-- count leading zeros in the millisecond string,
		-- to reduce misinputs things like 00:00:10 instead of 00:00:010 should be warned.
		-- unless sb_log["-allow-no-leading-zeros"] is true, it will raise an error.
		local first_non_leading_zero_char =
			MSs:find("[^0^%-]")

		-- if input is 0, or 00, or 000 etc., this value will be nil
		-- and the warning is safe to skip
		if first_non_leading_zero_char then
			local count = first_non_leading_zero_char
			if MS<100 then count = count - 1 end
			if MS<10 then count = count - 1 end

			if count <= 0 then
				local leading1 = MSs
				local leading2 = MS
				for i=count,0 do
					leading1="0"..leading1
					leading2=leading2*10
				end

				if sb_config["allow-no-leading-zeros"] then
					sb_log:warn ("'%s' is missing leading zeros, clarify if this is %s or %g milliseconds",
						x, leading1, leading2)
				else
					sb_log:error("'%s' is missing leading zeros, clarify if this is %s or %g milliseconds",
						x, leading1, leading2)
				end
			end
		end
		--

		local result
		if M < 0 or negate then
			result = -(MS + S*1000 + M*-60000)
		else
			result = MS + S*1000 + M*60000
		end

		if result > 5400000 and not sb_config["ignore-large-time-points"] then
			sb_log:warn(large_number_warning,x)
		end

		return result
	end

	if type(x)=="table" then
		local metronome = x[1]
		local beat = x[2]

		sb_log:assert(metronome, "{metronome,beat} time point is missing the metronome argument.")
		sb_log:assert(type(metronome)=="table",
			"{metronome,beat} time point expected {BPM, offset} table for metronome argument, got %s.",type(metronome))
		sb_log:assert(type(metronome[1])=="number",
			"{metronome,beat} time point expected number for metronome BPM, got %s.",type(metronome[1]))
		sb_log:assert(metronome[1]~=0,"time(metronome,beat) 0 BPM is not allowed")
		sb_log:assert(type(metronome[2])=="number",
			"{metronome,beat} time point expected number for metronome offset, got %s.",type(metronome[2]))

		sb_log:assert(beat, "{metronome,beat} time point is missing the beat argument.")

		local interval = 60000.0 / metronome[1]
		local result = interval*beat + metronome[2]
		
		if result > 5400000 and not sb_config["ignore-large-time-points"] then
			sb_log:warn(large_number_warning,result)
		end

		return result
	end

	sb_log:error("Unknown time point '%s' of type '%s'",x,type(x))
end

return time
