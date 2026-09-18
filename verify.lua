-- diagnoses commands overlapping in time
--
--

local sb_com       = require 'commands'
local sb_easing    = require 'easing'
local sb_config    = require 'config'
local sb_transform = require 'transform'
local sb_time      = require 'time'
local sb_log       = require 'log'

local verify = {}
verify.__index = verify

local sb_time = require 'time'
local sb_com = require 'commands'

function verify:isPrimitive(com)
	return sb_com:equal(com,
		"move","movex","movey","scale","vector","fade","rotate","parameter","colour")
end

local function filter(t, predicate)
	local result = {}
	for i,v in ipairs(t) do
		if predicate(v) then
			table.insert(result, v)
		end
	end
	return result
end

--
-- returns a doubly linked list table (and dimensions).
-- each entry is
-- { time, "min"/"max"/"point", ["next"], ["prev"], ["command"] }
--
-- optional types argument is a table of types like {"move","rotate"} to filter to these
-- commands only
--
function verify:sortedTimes(commands, types)
	local dimensions=0
	if types and (types or {})[1] then

		-- commands with different dimensions cannot have
		-- their overlaps resolved, check they're the same
		dimensions = sb_com[types[1]].dimension
		for i,v in ipairs(types) do
			if dimensions ~= sb_com[v].dimension then
				sb:warning(string.format("verify:sortedTimes(): types specified do not have matching dimensions (%s / %s, %d / %d).",
					types[1], v, dimensions, sb_com[v].dimension))
			end
		end

		commands = filter(commands, function(x) return sb_com:equal(x, table.unpack(types)) end)
	elseif commands[1] then
		dimensions = sb_com[commands[1][1]].dimension
	end

	local times_c = 0
	local times = {}

	-- min < max <= point
	local order = {min=0,max=1,point=1}
	local function test_order(a,b)
		return order [a] < order [b]
	end

	-- binary insert
	local function insert(entry)
		local entry_t = entry[1]

		local i,j,m = 1, nil, times_c

		while m >= i do
			j=math.floor((i+m)*0.5)
			local j_t = times[j][1]

			if j_t == entry_t then
				if test_order(times[j][2], entry[2]) then
					--i=j+1
					m=j-1
				else
					--m=j-1
					i=j+1
				end

				--[[if entry[2] == "max" and times[j][2]=="min"then
					i=j
					m=j-1
				elseif entry[2] == "min" and times[j][2]=="max" then
					i=j+1
					m=j
				else
					i=j
					m=j-1
				end--]]
			elseif j_t < entry_t then
				i=j+1
			else
				m=j-1
			end
		end

		table.insert(times, i, entry)
		times_c = times_c + 1
	end

	for i,v in ipairs(commands) do
		local t = sb_com:parseCommand(v, "time")
		local tmin,tmax = sb_time:getMinMax(t)

		if tmin==tmax then
			insert{tmin,"point", ["command"] = v}
		else
			insert{tmin,"min", ["command"] = v}
			insert{tmax,"max", ["command"] = v}
		end
	end

	for i,v in ipairs(times) do
		v.prev = times[i-1]
		v.next = times[i+1]
	end

	return times, dimensions
end

--
--
-- tests for and outputs any overlaps found in an informational table
--
--
function verify:testSortedTimes(times)
	local overlaps = {}

	local stack = require 'stack'
	local s = stack:newStack()

	local curr = times[1]
	while curr do
		if curr[2] == "min" then

			-- if overlap(s)
			if s:peek() then
				for i,v in ipairs(s) do

					-- cases like times {0, 50} and {50, 100}
					-- where max=50 and min=50
					-- should not count as overlaps
					--
					-- otherwise, add this "min" point as the
					-- start of an overlap
					if curr[1]~=v[1] or curr[2]==v[2] then

						local overlap_info = {curr[1], "min", curr.command, v.command}
						table.insert(overlaps, overlap_info)
						
						if not overlaps[curr.command] then overlaps[curr.command]={} end
						if not overlaps[v.command] then overlaps[v.command]={} end
						table.insert(overlaps[curr.command], {curr[1], "min", v.command})
						table.insert(overlaps[v.command], {curr[1], "min", curr.command})
					end
				end
			end

			s:push(curr)
		elseif curr[2] == "max" then

			-- search for and record any overlaps
			for i,v in ipairs(s) do

				-- cases like times {0, 50} and {50, 100}
				-- where max=50 and min=50
				-- should not count as overlaps
				--
				-- otherwise, add this "max" point as the
				-- start of an overlap
				if (curr[1]~=v[1] or curr[2]==v[2]) and (v.command ~= curr.command) then

					local overlap_info = {curr[1], "max", curr.command, v.command}
					table.insert(overlaps, overlap_info)
					
					--if not overlaps[curr.command] then overlaps[curr.command]={} end
					--if not overlaps[v.command] then overlaps[v.command]={} end
					table.insert(overlaps[curr.command], {curr[1], "max", v.command})
					table.insert(overlaps[v.command], {curr[1], "max", curr.command})
				end
			end

			-- remove from stack
			for i=s:count(),1,-1 do
				if s[i].command == curr.command then
					s:remove(i)
				end
			end
		end

		curr = curr.next
	end

	return overlaps
end

--
--
-- resolves overlapping relative transformations into non-overlapping commands
--
-- overlapping times is for relative transformations like 'move_relative' ONLY.
-- absolute transformation commands like 'move' should not be resolved this way,
-- any time overlap is undefined behaviour error.
--
--
function verify:resolveTransformOverlaps(times, dimension, rel_type)

	print()
	for i,v in ipairs(times) do
		print(v[1],v[2],sb_com:toString(v.command))
	end
	print()

	local dimensions=0
	if times[1] then
		dimensions = sb_com[times[1].command[1]].dimension
	end

	if not times or #times==0 then
		return {}
	end

	local clone = require 'clone'
	local final = {}
	local com_type = rel_type
	local abs_type = sb_com:getAbsoluteVersion(com_type)
	local curr = times[1]


	-- {command, easing_func, time, vec1, vec2} are popped
	-- on and off here lasting from their start to end time
	local easing_stack = {}
	local function add_to_easing_stack(command, easing_func, time, vec1, vec2)
		table.insert(easing_stack, {command, easing_func, time, vec1, vec2})
	end
	local function remove_from_easing_stack(command)
		for i=#easing_stack,1,-1 do
			if command == easing_stack[i][1] then
				table.remove(easing_stack, i)
				return
			end
		end
	end


	--
	-- when commands evaluate to cases like
	-- {"command", {0,0} , ... }
	-- {"command", {0,10} , ... }
	--
	-- the point-like command can be removed, with it's resulting transformation
	-- being incorporated into the following command
	--
	-- not all point-link commands can be removed, because the first command in this
	-- case will still have an effect, only when the next command starts at the same time
	-- can it be removed.
	-- {"command", {0,0} , ... }
	-- {"command", {1,10} , ... }
	--
	local last_point_time = nil

	local total_offset = {}
	for i=1,dimension do total_offset[i]=0 end
	local function add_to_total_offset(command)
		for i=#easing_stack,1,-1 do
			if command == easing_stack[i][1] then
				for j=1,dimension do
					total_offset[j] = total_offset[j] + easing_stack[i][5][j]
				end
			end
		end
	end
	local function add_to_total_offset_abs_command(vec1, vec2)
		for i=1,dimension do
			total_offset[i] = total_offset[i] + vec2[i] - vec1[i]
		end
	end

	function get_from_stack(time)
		local result = {}
		for i=1,dimension do result[i]=total_offset[i] end

		for i,v in ipairs(easing_stack) do
			local intersects =
			 time >= v[3][1] and time <= v[3][2]

			if intersects then
				local tau
				if v[3][1] ~= v[3][2] then
					tau = (time - v[3][1]) / (v[3][2] - v[3][1])
				else
					tau = 1.0
				end
				for i=1,dimension do
					local D = v[5][i] - v[4][i]
					result[i] = result[i] + v[4][i] + (v[2](tau) * D)
				end
			end
		end

		return result
	end

	while curr do
		local com_type = curr.command[1]

		local easing, time, vec1, vec2 = sb_com:parseCommand(curr.command)

		local easing_func = sb_easing.funcs[easing]
		if easing~= 0 then
			if not sb_config["allow-non-linear-easing-overlaps"] then
			sb_log:warn(string.format(
				"verify:resolveTransformOverlaps(): overlap resolution with non-linear easings may result in "
			.."unexpected visuals, got '%s'. 'linear'/0 is recommended.", tostring(easing)))
			end

			--
			--
			-- TODO create keyframes to emulate easing motion.
			--
			--
		end

		-- in case there is a custom relative transformation command that makes use of the
		-- multiple time points feature, how motion is to be resolved
		-- cannot be deduced, using the minimum and maximum as time points
		-- is used as a fallback in this case.
		if #time > 2 then
			time = sb_time(sb_time:getMinMax(time))
		end
			
		local is_abs = sb_com:isAbsolute(curr.command)

		if curr[2]=="min" then
			add_to_easing_stack(curr.command, easing_func, time, vec1, vec2)

			if is_abs then
				for i=1,dimension do
					total_offset[i]=0
				end
			end
		end

		--
		-- if two commands have the same end points, there is no need
		-- to create point-like commands at the end of these time intervals.
		-- ignore.
		--
		local skip = false
		if curr.prev then
			if curr.prev[1] == curr[1] and curr.prev[2]=="max" and curr[2]=="max" then
				skip = true
			end
		end

		if curr[2]=="point" then
			if not is_abs then
				add_to_easing_stack(curr.command, easing_func, time, vec1, vec2)
				add_to_total_offset(curr.command)
				remove_from_easing_stack(curr.command)
			else
				for i=1,dimension do
					total_offset[i]=vec2[i]
				end
				--add_to_total_offset_abs_command(vec1, vec2)
			end

			last_point_time = time[2]

			table.insert(final, sb_com:createCommand(abs_type, 0, {curr[1], curr[1]},
				get_from_stack(curr[1]), get_from_stack(curr[1]), nil, nil))
				
		elseif curr.prev and not skip then

			-- if previous point-like command can be removed, then remove it
			print("umm",last_point_time,curr[1])
			if last_point_time == curr[1] then
				print("die")
				table.remove(final, #final)
			else
				table.insert(final, sb_com:createCommand(abs_type, 0, {curr.prev[1], curr[1]},
					get_from_stack(curr.prev[1]), get_from_stack(curr[1]), nil, nil))
			end
		end

		if curr[2]~="point" then
			last_point_time = nil
		end

		if curr[2]=="max" then
			if not is_abs then
				add_to_total_offset(curr.command)
			else
				add_to_total_offset_abs_command(vec1, vec2)
			end
			remove_from_easing_stack(curr.command)
		end

		curr = curr.next
	end

	return final
end

--[[function verify:checkTimeOverlaps(commands_list)
	local abs_move_coms   = filter(commands_list, function(x) return sb_com:equal(x, "move", "movex", "movey") end)
	local rel_move_coms   = filter(commands_list, function(x) return sb_com:equal(x, "move_relative") end)
	local rot_coms   = filter(commands_list, function(x) return sb_com:equal(x, "rotate") end)
	local scale_coms = filter(commands_list, function(x) return sb_com:equal(x, "scale", "vector") end)
	local colour_coms = filter(commands_list, function(x) return sb_com:equal(x, "colour") end)
	local fade_coms = filter(commands_list, function(x) return sb_com:equal(x, "fade") end)
	local param_coms = filter(commands_list, function(x) return sb_com:equal(x, "parameter") end)

	local abs_move_times = verify:sortedTimes(abs_move_coms)
	local rel_move_times = verify:sortedTimes(rel_move_coms)
	local rot_times = verify:sortedTimes(rot_coms)
	local scale_times = verify:sortedTimes(scale_coms)
	local colour_times = verify:sortedTimes(colour_coms)
	local fade_times = verify:sortedTimes(fade_coms)
	local param_times = verify:sortedTimes(param_coms)
end--]]

function verify:resolve(commands_list)
	if not sb_config["no-overlap-checks"] then
		local abs_move_coms   = filter(commands_list, function(x) return sb_com:equal(x, "move") end)
		local abs_rot_coms   = filter(commands_list, function(x) return sb_com:equal(x, "rotate") end)
		local abs_scale_coms = filter(commands_list, function(x) return sb_com:equal(x, "scale", "vector") end)
		local colour_coms = filter(commands_list, function(x) return sb_com:equal(x, "colour") end)
		local fade_coms = filter(commands_list, function(x) return sb_com:equal(x, "fade") end)
		local param_coms = filter(commands_list, function(x) return sb_com:equal(x, "parameter") end)

		local abs_move_overlaps   = verify:sortedTimes(abs_move_coms)
		local abs_rot_overlaps    = verify:sortedTimes(abs_rot_overlaps) 
		local abs_scale_overlaps  = verify:sortedTimes(abs_scale_overlaps)
		local colour_overlaps     = verify:sortedTimes(colour_overlaps) 
		local fade_overlaps       = verify:sortedTimes(fade_overlaps)    
		local param_overlaps      = verify:sortedTimes(param_overlaps)
	end
end

--[[local test, dim = verify:sortedTimes(
	{
		{"mover", 0, {"-00:01:000","00:09:000"}, {0,0}, {10000,10000}},
		{"mover", 0, {"-00:00:200","00:00:000"}, {0,0}, {-20,-20}},
		{"mover", 0, {"00:00:000","00:00:000"}, {0,0}, {10,10}},
		{"mover", 0, {"00:00:000","00:05:000"}, {0,0}, {1000,1000}},
		{"mover", 0, {"00:01:000","00:05:000"}, {0,0}, {1000,1000}},
		{"mover", 0, {"00:02:000","00:05:000"}, {0,0}, {1000,1000}},
		{"mover", 0, {"00:07:000","00:07:000"}, {0,0}, {1000,1000}},
		--{"move", 0, {"00:06:000","00:07:100"}, {0,0}, {1000, 1000}},
		--{"move", 0, {"00:02:000","00:04:000"}, {0,0}, {10, 10}},
	}
)--]]

--[[for i,v in ipairs(test) do
	print(table.unpack(v))
end
print()

--local overlaps = verify:testSortedTimes(test)
local resolved = verify:resolveTransformOverlaps(test, dim)

for i,v in ipairs(resolved) do
	print(sb_com:toString(v))
end--]]

return verify
