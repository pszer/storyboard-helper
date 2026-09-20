-- diagnoses commands overlapping in time
--
--

local sb_com       = require 'commands'
local sb_easing    = require 'easing'
local sb_config    = require 'config'
local sb_time      = require 'time'
local sb_log       = require 'log'
local sb_keyframe  = require 'keyframe'

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
				sb:warning("verify:sortedTimes(): types specified do not have matching dimensions (%s / %s, %d / %d).",
					types[1], v, dimensions, sb_com[v].dimension)
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

		local skip = false

		while m >= i do
			j=math.floor((i+m)*0.5)
			local j_t = times[j][1]

			if j_t == entry_t then

				-- if entries share time, and are both of type "point", then
				-- their two commands are to be combined to simplify processing.
				if times[j][2] == "point" and entry[2] == "point" then

					times[j].command = sb_com:createCommandAddition(times[j].command, entry.command)
					skip = true
					break
					
				elseif test_order(times[j][2], entry[2]) then
					m=j-1
				else
					i=j+1
				end

			elseif j_t < entry_t then
				i=j+1
			else
				m=j-1
			end
		end

		if not skip then
			table.insert(times, i, entry)
			times_c = times_c + 1
		end
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
	--[[print()
	for i,v in ipairs(times) do
		print(v[1],v[2],sb_com:toString(v.command))
	end
	print()--]]

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

	local linear_easing = sb_easing["linear"]

	-- {command, easing_func, time, vec1, vec2} are popped
	-- on and off here lasting from their start to end time
	local easing_stack = {}
	local function add_to_easing_stack(command, easing_func, time, vec1, vec2, easing)
		table.insert(easing_stack, {command, easing_func, time, vec1, vec2, easing})
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
					total_offset[j] = total_offset[j] + easing_stack[i][5][j] - easing_stack[i][4][j]
				end
			end
		end
	end
	--local function add_to_total_offset_abs_command(vec1, vec2)
	--	for i=1,dimension do
	--		total_offset[i] = total_offset[i] + vec2[i] - vec1[i]
	--	end
	--end

	local function get_from_stack(time)
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
					--result[i] = result[i] + v[4][i] + (v[2](tau) * D)
					result[i] = result[i] + (v[2](tau) * D)
				end
			end
		end

		return result
	end

	local function is_stack_overlapping()
		return #easing_stack > 1
	end

	local function is_stack_linear()
		for i,v in ipairs(easing_stack) do
			local easing = v[6]
			if easing ~= linear_easing then return false end
		end
		return true
	end

	local function get_keyframes_from_stack(time1, time2, interval)

		if interval==0 then sb_log:error("keyframe:simplify(): error in get_keyframes_from_stack, time step interval is 0.") end

		local result = {}

		local add_time2 = true
		for t=time1,time2,interval do
			if t==time2 then add_time2 = false end

			local vec = get_from_stack(t)
			local V = {t}
			for i=1,dimension do
				V[i+1] = vec[i]
			end
			table.insert(result, V)
		end

		-- in case step interval doesnt cleanly divide the given time interval.
		if add_time2 then
			local vec = get_from_stack(time2)
			local V = {time2}
			for i=1,dimension do
				V[i+1] = vec[i]
			end
			table.insert(result, V)
		end

		return result
	end

	-- converts keyframes to the final commands
	local function keyframes_to_command(keyframes)
	end

	while curr do
		local com_type = curr.command[1]

		local easing, time, vec1, vec2 = sb_com:parseCommand(curr.command)
		local easing_func = sb_easing.funcs[easing]

		-- in case there is a custom relative transformation command that makes use of the
		-- multiple time points feature, how motion is to be resolved
		-- cannot be deduced, using the minimum and maximum as time points
		-- is used as a fallback in this case.
		if #time > 2 then
			time = sb_time(sb_time:getMinMax(time))
		end
			
		local is_abs = sb_com:isAbsolute(curr.command)

		if curr[2]=="min" then
			add_to_easing_stack(curr.command, easing_func, time, vec1, vec2, easing)
		end

		--
		--
		local skip = false
		if curr[2]=="min" and not is_stack_overlapping() then
			skip = true
		elseif curr.prev then
			if curr.prev[1] == curr[1] then
				skip = true
			end
		elseif curr[2] ~= "point" then
			skip = true
		end

		if curr[2]=="point" then
			if not is_abs then
				add_to_easing_stack(curr.command, easing_func, time, vec1, vec2, easing)
				add_to_total_offset(curr.command)
				remove_from_easing_stack(curr.command)
			else
				for i=1,dimension do
					total_offset[i]=vec2[i]
				end
			end
			table.insert(final, sb_com:createCommand(abs_type, 0, {curr[1], curr[1]},
				get_from_stack(curr[1]), get_from_stack(curr[1]), nil, nil))

			last_point_time = time[2]
				
		elseif curr.prev and not skip then

			-- if previous point-like command can be removed, then remove it
			if last_point_time == curr[1] then
				table.remove(final, #final)
			else

				--
				-- if stack only has linear easings, the final result can be linear too.
				--
				-- if stack has no overlaps, then the current commands easing can be used without extra steps.
				--
				-- if stack has overlaps and non-linear easings, the easings must be sampled and keyframed to
				-- create the desired visual result.
				--

				if (not is_stack_overlapping() or is_stack_linear())
					and not (easing ~= linear_easing and curr.prev.command ~= curr.command) then 
					table.insert(final, sb_com:createCommand(abs_type, easing, {curr.prev[1], curr[1]},
						get_from_stack(curr.prev[1]), get_from_stack(curr[1]), nil, nil))
				elseif sb_config["disable-easing-keyframing"] then

					sb_log:warn(
						"verify:resolveTransformOverlaps(): overlap resolution with non-linear easings will result in "
					.."unexpected visuals. -disable-easing-keyframing has been set to true, so "
					.."'linear'/0 is recommended.")
					table.insert(final, sb_com:createCommand(abs_type, easing, {curr.prev[1], curr[1]},
						get_from_stack(curr.prev[1]), get_from_stack(curr[1]), nil, nil))
				else

					local frames = get_keyframes_from_stack(curr.prev[1], curr[1], sb_config["default-easing-keyframing-interval"])
					local s_frames = sb_keyframe:simplify(frames, {epsilon = sb_config["default-easing-keyframing-epsilon"]})
					
					for i=1,#s_frames-1 do
						local vec1,vec2 = {},{}
						for j=1,dimension do
							vec1[j]=s_frames[i][j+1]
							vec2[j]=s_frames[i+1][j+1]
						end

						table.insert(final, sb_com:createCommand(abs_type, linear_easing, {s_frames[i][1], s_frames[i+1][1]},
							vec1, vec2, nil, nil))
					end
				end
			end
		end

		if curr[2]~="point" then
			last_point_time = nil
		end

		if curr[2]=="min" then
			if is_abs then
				local current_p = get_from_stack(curr[1])
				local fix_p = {}

				for i = 1,dimension do
					fix_p[i] = current_p[i] - total_offset[i]
				end
				for i=1,dimension do
					total_offset[i] = vec1[i] - fix_p[i]
				end
			end
		end

		if curr[2]=="max" then
			--if not is_abs then
				add_to_total_offset(curr.command)
			--else
			--	add_to_total_offset_abs_command(vec1, vec2)
			--end
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

return verify
