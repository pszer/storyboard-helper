-- diagnoses commands overlapping in time
--
--

local sb_com    = require 'commands'
local sb_easing = require 'easing'

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
-- returns a doubly linked list table.
-- each entry is
-- {time, "min"/"max", ["next"], ["prev"], ["command"], ["offset"]}
--
-- optional types argument is a table of types like {"move","rotate"} to filter to these
-- commands only
function verify:sortedTimes(commands, types)
	if types and (types or {})[1] then

		-- commands with different dimensions cannot have
		-- their overlaps resolved, check they're the same
		local dimensions = sb_com[types[1]].dimension
		for i,v in ipairs(types) do
			if dimensions ~= sb_com[v].dimension then
				sb:warning(string.format("verify:sortedTimes(): types specified do not have matching dimensions (%s / %s, %d / %d).",
					types[1], v, dimensions, sb_com[v].dimension))
			end
		end

		commands = filter(commands, function(x) return sb_com:equal(x, table.unpack(types)) end)
	end

	local times_c = 0
	local times = {}

	-- binary insert
	local function insert(entry)
		local entry_t = entry[1]

		local i,j,m = 1, nil, times_c

		while m >= i do
			j=math.floor((i+m)*0.5)
			print(i,j,m)
			local j_t = times[j][1]

			if j_t == entry_t then
				if entry[2] == "max" and times[j][2]=="min" then
					i=j
					m=j-1
				elseif entry[2] == "min" and times[j][2]=="max" then
					i=j+1
					m=j
				else
					i=j
					m=j-1
				end
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

		insert{tmin,"min", ["command"] = v}
		insert{tmax,"max", ["command"] = v}
	end

	for i,v in ipairs(times) do
		v.prev = times[i-1]
		v.next = times[i+1]
	end

	return times
end

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

function verify:resolveOverlaps(times, overlaps)
	local curr = times[1]
	local curr_overlap_i = 1
	local curr_overlap = overlaps[1]
	local function next_overlap()
		curr_overlap_i=curr_overlap_i+1
		curr_overlap = overlaps[curr_overlap_i]
	end

	local function append_to(node, node2)
		local node_next = node.next
		node.next = node2
		node2.prev = node2
	end

	while curr do
		if curr_overlap[2] == "min" then

			if curr[1] <= curr_overlap[1] then
				curr=curr.next
			else
				local prev = curr.prev
			end

		else

			--

		end

		curr = curr.next
	end
end

function verify:checkTimeOverlaps(commands_list)
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
end

local test = verify:sortedTimes(
	{
		{"move", 0, {"00:00:500","00:05:000"}, {50,50}},
		--{"move", 0, {"00:00:500","00:09:000"}, {50,50}},
		{"move", 0, {"00:01:000","00:02:100"}, {50,50}},
		{"move", 0, {"00:02:000","00:04:000"}, {50,50}},
	}
)
local overlaps = verify:testSortedTimes(test)

for i,v in ipairs(overlaps) do
	print(v[1],v[2],sb_com:toString(v[3]),sb_com:toString(v[4]))
end

return verify
