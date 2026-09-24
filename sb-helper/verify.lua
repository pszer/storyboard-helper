-- diagnoses commands overlapping in time
--
--

local modules = (...):gsub('%.[^%.]+$', '') .. "."
local sb_com        = require (modules..'commands')
local sb_easing     = require (modules..'easing')
local sb_easingroot = require (modules..'easingroot')
local sb_config     = require (modules..'config')
local sb_time       = require (modules..'time')
local sb_log        = require (modules..'log')
local sb_keyframe   = require (modules..'keyframe')

local verify = {}
verify.__index = verify

local function filter(t, predicate)
	local result = {}
	for i,v in ipairs(t) do
		if predicate(v) then
			table.insert(result, v)
		end
	end
	return result
end

function verify:filterToCommand(commands, ...)
	local types = {...}
	return filter(commands, function(x) return sb_com:equal(x, table.unpack(types)) end)
end
function verify:extractCommands(commands, ...)
	local types = {...}
	local out = {}
	for i= #commands,1,-1 do
		if sb_com:equal(commands[i], ...) then
			table.insert(out, commands[i])
			table.remove(commands, i)
		end
	end
	return out
end
function verify:containsCommand(commands, ...)
	for i,v in ipairs(commands) do
		if sb_com:equal(v, ...) then return true end
	end
	return false
end
function verify:getCommandsTypeSet(commands)
	local set = {}

	for i,v in ipairs(commands) do
		local c_type = v[1]

		local add = true
		for j,z in ipairs(set) do
			if sb_com:equal(v, z) then
				add = false
				break
			end
		end

		if add then
			table.insert(set, c_type)
		end
	end

	return set
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
	else
		return {}, 0
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
		local t = sb_com:parse(v, "time")
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
-- if none, then return nil
--
--
function verify:testSortedTimes(times)
	if not times then return nil end
	if #times==0 then return nil end

	local overlaps = {}

	local stack = require (modules..'stack')
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

	if overlaps[1] then
		return overlaps
	else
		return nil
	end
end

--
--
-- resolves overlapping relative transformations into non-overlapping commands
--
-- overlapping times is for relative transformations like 'move_relative' ONLY.
-- absolute transformation commands like 'move' should not be resolved this way,
-- any time overlap is undefined behaviour error.
--
-- if rel_type is non-nil, then any of the relative commands are collapsed into
-- their absolute versions. if nil then relative commands stay as relative commands
--
function verify:resolveTransformOverlaps(times, dimension, rel_type, start_vec)
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
		return nil
	end
	local start_vec = start_vec or {}

	local final = {}

	local com_type = rel_type or times[1].command[1]
	local abs_type
	local out_type
	if com_type then
		abs_type = sb_com:getAbsoluteVersion(com_type)
		if abs_type then out_type = abs_type end
	end
	local curr = times[1]

	local linear_easing = sb_easing["linear"]

	local operator = sb_com[com_type].overlap_operator or '+'
	local identity = 0

	if operator == '*' then identity = 1 end

	local operator_func = operator == '*'
	                      and function(a,b) return a*b end
												 or function(a,b) return a+b end
	local inverse_func  = operator == '*'
	                      and function(a,b) return a/b end
												 or function(a,b) return a-b end

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

	for i=1,dimension do
		total_offset[i]=start_vec[i] or identity 
	end
	--print("total_offset", table.unpack(total_offset))

	local function add_to_total_offset(command)
		for i=#easing_stack,1,-1 do
			if command == easing_stack[i][1] then
				--print("Before....", table.unpack(total_offset))
				for j=1,dimension do
					--print(string.format("operator_func(%s, inverse(%s, %s) = %s)", total_offset[j], easing_stack[i][5][j], easing_stack[i][4][j],
					--	inverse_func(easing_stack[i][5][j], easing_stack[i][4][j]) ))
					--                                             + *                                - /
					if operator == '+' then
						total_offset[j] = operator_func(total_offset[j], inverse_func(easing_stack[i][5][j], easing_stack[i][4][j]))
					else
						total_offset[j] = operator_func(total_offset[j], easing_stack[i][5][j])
					end
				end
				--print("After....", table.unpack(total_offset))
				return
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
			local is_abs = sb_com:isAbsolute(v[1])

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

					result[i] = operator_func(result[i], (v[4][i] + v[2](tau) * D))
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

		local easing, time, vec1, vec2 = sb_com:parse(curr.command)
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

			if curr[2]=="min" then
				remove_from_easing_stack(curr.command)
			end

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
					and not (easing ~= linear_easing and curr.prev.command ~= curr.command)
					then 
					table.insert(final, sb_com:createCommand(abs_type, easing, {curr.prev[1], curr[1]},
						get_from_stack(curr.prev[1]), get_from_stack(curr[1]), nil, nil))


				-- keyframe

				elseif sb_config["disable-easing-keyframing"] then

					sb_log:warn(
						"verify:resolveTransformOverlaps(): overlap resolution with non-linear easings will result in "
					.."unexpected visuals. -disable-easing-keyframing has been set to true, so "
					.."'linear'/0 is recommended.")
					table.insert(final, sb_com:createCommand(abs_type, easing, {curr.prev[1], curr[1]},
						get_from_stack(curr.prev[1]), get_from_stack(curr[1]), nil, nil))
				else

					local epsilon = sb_config["default-easing-keyframing-epsilon"]

					if sb_com:equal(curr.command, 'scale', 'scalerel', 'vector', 'vectorrel') then
						epsilon = sb_config["default-easing-keyframing-epsilon-scale"]
					elseif sb_com:equal(curr.command, 'rotate', 'rotaterel') then
						epsilon = sb_config["default-easing-keyframing-epsilon-rotate"]
					elseif sb_com:equal(curr.command, 'col', 'coladd', 'colmul') then
						epsilon = sb_config["default-easing-keyframing-epsilon-col"]
					end

					local frames = get_keyframes_from_stack(curr.prev[1], curr[1], sb_config["default-easing-keyframing-interval"])
					local s_frames = sb_keyframe:simplify(frames, {epsilon = epsilon})
					
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

			if curr[2]=="min" then
				add_to_easing_stack(curr.command, easing_func, time, vec1, vec2, easing)
			end
		end

		if curr[2]~="point" then
			last_point_time = nil


			if curr[2]=="min" and is_abs then
				--print("")
				--print("Setting total offset, currently ", table.unpack(total_offset))


				local current_p = get_from_stack(curr[1])
				local fix_p = {}

				for i = 1,dimension do
					fix_p[i] = inverse_func(current_p[i] , total_offset[i])
				end

			--	print("current_p is ", table.unpack(current_p))
			--	print("fix_p is ", table.unpack(fix_p))

				for i=1,dimension do
					local x = fix_p[i]
					--[[if (x ~= 0 and (x == x and x ~= math.huge and x ~= -math.huge)) or operator == '+' then
						total_offset[i] = inverse_func(vec1[i] , fix_p[i])
					else
						total_offset[i] = vec1[i]
						if total_offset[i] == 0 then
						--	total_offset[i] = 1
						end
					end--]]
					if operator == '+' then
						total_offset[i] = inverse_func(vec1[i] , fix_p[i])
					else
						total_offset[i] = 1
					end
				end

			--print("Set total offset to ", table.unpack(total_offset))
			--elseif curr[2] == "min" and operator == '+' then
			elseif operator == '+' then
				for i=1,dimension do
					total_offset[i] = operator_func(total_offset[i] , vec1[i])
				end
			end

			if curr[2]=="max" then
				add_to_total_offset(curr.command)
				remove_from_easing_stack(curr.command)
			end

		end

		curr = curr.next
	end

	return table.unpack(final)
end

-- expects non-overlapping vector commands
function verify:resolveNegativeScales(coms)
	if not coms or not coms[1] then
		return {}, {}
	end

	--
	local converted = {}
	for i,v in ipairs(coms) do
		table.insert(converted, sb_com:scaleToVector( v ))
		table.sort(converted, function(a,b)
			local time1 = sb_com:parse(a, "time")
			local time2 = sb_com:parse(b, "time")
			return time1[1] < time2[1]
		end)
	end

	local result_s_v = {}
	local result_p   = {}

	local function pos(x) return x >= 0 end
	local function neg(x) return x  < 0 end

	local h_flip_markers = {}
	local v_flip_markers = {}

	local function append_h_flip(time, val)
		local top = h_flip_markers[#h_flip_markers]
		if not top then
			if val then
				table.insert(h_flip_markers, {time, val})
			end
		elseif top[2]~= val then
			table.insert(h_flip_markers, {time, val})
		end
	end
	local function append_v_flip(time, val)
		local top = v_flip_markers[#v_flip_markers]
		if not top then
			if val then
				table.insert(v_flip_markers, {time, val})
			end
		elseif top[2]~= val then
			table.insert(v_flip_markers, {time, val})
		end
	end

	if converted[1] then
		local vec1,vec2 = sb_com:parse(converted[1], "vec")
		if neg(vec1[1]) then
			table.insert(h_flip_markers, {vec1[1], true} )
		end
		if neg(vec1[2]) then
			table.insert(v_flip_markers, {vec1[2], true} )
		end
	end

	local function linear_root(t1,t2, a,b)
		if a*b > 0 then return nil end
		if a==0 then return t1 end
		if b==0 then return t2 end

		return t1 + (-a/(b-a))*(t2-t1)
	end

	local tolerance = sb_config["minimum-scale-tolerance"]

	for i,v in ipairs(converted) do
		local easing, time, vec1, vec2 = sb_com:parse(v)

		local is_linear = easing == sb_easing['linear']

		local function get_root(i)
			if is_linear then
				return linear_root(time[1], time[2], vec1[i], vec2[i])
			end

			return sb_easingroot:find_root(easing, time[1], time[2], vec1[i], vec2[i])
		end

		-- if nothing needs to be done
		if pos(vec1[1]) and pos(vec1[2]) and pos(vec2[1]) and pos(vec2[2]) then
			table.insert(result_s_v, v)
		end

		if neg(vec1[1]) and neg(vec1[2]) then
			append_h_flip(time[1], true)
		end
		if neg(vec2[1]) and neg(vec2[2]) then
			append_v_flip(time[1], true)
		end

		local x_root, y_root

		--
		-- positive to negative
		--
		if pos(vec1[1]) and neg(vec2[1]) then
			append_h_flip(time[1], false)
			x_root = get_root(1)
			table.insert(h_flip_markers, {x_root, true} ) end

		if pos(vec1[2]) and neg(vec2[2]) then
			append_v_flip(time[1], false)
			y_root = get_root(2)
			table.insert(v_flip_markers, {y_root, true} ) end

		--
		-- negative to positive
		--
		if neg(vec1[1]) and pos(vec2[1]) then
			append_h_flip(time[1], true)
			x_root = get_root(1)
			table.insert(h_flip_markers, {x_root, false} ) end

		if neg(vec1[2]) and pos(vec2[2]) then
			append_v_flip(time[1], true)
			y_root = get_root(2)
			table.insert(v_flip_markers, {y_root, false} ) end

		local function clamp(a)
			if math.abs(a) < tolerance then return 0 end
			return math.abs(a)
		end
		local function gen_frames(a, b)
			local frames = {}
			local easing_func = sb_easing.funcs[easing]
			local dx = vec2[1] - vec1[1]
			local dy = vec2[2] - vec1[2]

			local add_time_b = true
			for i=a,b,sb_config["default-easing-keyframing-interval"] do
				if i==b then add_time_b = false end

				local t = (i-time[1])/(time[2]-time[1])
				if (t~=t or t==math.huge or t==-math.huge) then t=1 end
				local e = easing_func(t)

				table.insert(frames, {i, clamp((e * dx)+vec1[1]), clamp((e * dy)+vec1[2]) })
			end

			if add_time_b then
				local t = (b-time[1])/(time[2]-time[1])
				local e = easing_func(t)
				table.insert(frames, {b, clamp((e * dx)+vec1[1]), clamp((e * dy)+vec1[2]) })
			end
			return frames
		end

		--
		if x_root or y_root then

			--
			--
			-- if the easing is non_linear, the resulting scale commands
			-- are approximated using keyframing.
			-- when linear, an exact solution can be created easily.
			--

			local split_a = math.min(x_root or y_root, y_root or x_root)
			local split_b = math.max(x_root or y_root, y_root or x_root)

			if not is_linear then

				local function do_frames(a,b)
					local frames = gen_frames(a,b)
					local K = sb_keyframe:simplify(frames, {epsilon = sb_config["default-easing-keyframing-epsilon-scale"]})
					for i=1,#K-1 do
						local Ki = K[i]
						local Ky = K[i+1]
						local vector_out = sb_com:createCommand('vector', 0, {Ki[1], Ky[1]}, {Ki[2], Ki[3]}, {Ky[2], Ky[3]})
						table.insert(result_s_v, vector_out)
					end
				end

				-- non linear
				-- avoid 0-length segment
				if time[1] ~= split_a then
					do_frames(time[1], split_a)
				end

				-- avoid 0-length segment
				if split_a ~= split_b then
					do_frames(split_a, split_b)
				end

				-- avoid 0-length segment
				if time[2] ~= split_b then
					do_frames(split_b, time[2])
				end

				--
				-- non linear end
				--

			else
				-- linear start
				local d_vec = {
					vec2[1]-vec1[1],
					vec2[2]-vec1[2],
				}

				if split_a ~= split_b then
					local tau = (split_a - time[1])/(time[2] - time[1])
					if time[2]==time[1] then tau = 1.0 end

					if split_a ~= time[1] then
						table.insert(result_s_v, sb_com:createCommand('vector', 0,
							{time[1],split_a},                       -- t1___a   b   t2
							{math.abs(vec1[1]), math.abs(vec1[2])},  -- 
							{math.abs(vec1[1] + tau*d_vec[1]), math.abs(vec1[2] + tau*d_vec[2])} --
						))
					end

					local tau_b = (split_b - time[1])/(time[2] - time[1])
					if time[2]==time[1] then tau_b = 1.0 end
					table.insert(result_s_v, sb_com:createCommand('vector', 0,
						{split_a, split_b},                      -- t1   a___b   t2
						{math.abs(vec1[1] + tau*d_vec[1])  , math.abs(vec1[2] + tau*d_vec[2])},  -- 
						{math.abs(vec1[1] + tau_b*d_vec[1]), math.abs(vec1[2] + tau_b*d_vec[2])} --
					))

					if split_b ~= time[2] then
						table.insert(result_s_v, sb_com:createCommand('vector', 0,
							{split_b, time[2]},                      -- t1   a   b___t2
							{math.abs(vec1[1] + tau_b*d_vec[1]), math.abs(vec1[2] + tau_b*d_vec[2])},  -- 
							{math.abs(vec2[1])                 , math.abs(vec2[2])} --
						))
					end

				-- if one root
				elseif split_a == split_b then

					local tau = (split_a - time[1])/(time[2] - time[1])
					if time[2]==time[1] then tau = 1.0 end

					-- check if tau is 0.0 or 1.0, to avoid 0ms length commands that do nothing
					if tau > 0.0 then
						table.insert(result_s_v, sb_com:createCommand('vector', 0,
							{time[1],split_a},                       -- t1___a   t2
							{math.abs(vec1[1]), math.abs(vec1[2])},  -- 
							{math.abs(vec1[1] + tau*d_vec[1]), math.abs(vec1[2] + tau*d_vec[2])} --
						))
					end

					if tau < 1.0 then
						table.insert(result_s_v, sb_com:createCommand('vector', 0,
							{split_a, time[2]},                      -- t1   a___t2
							{math.abs(vec1[1] + tau*d_vec[1]), math.abs(vec1[2] + tau*d_vec[2])},  -- 
							{math.abs(vec2[1])               , math.abs(vec2[2])} --
						))
					end

				end

				--linear end

			end

		elseif neg(vec1[1]) or neg(vec1[2]) or neg(vec2[1]) or neg(vec2[2]) then

			table.insert(result_s_v, sb_com:createCommand('vector', easing, time,
				{math.abs(vec1[1]), math.abs(vec1[2])}, {math.abs(vec2[1]), math.abs(vec2[2])}))

		end
	end

	local h_start = nil
	for i,v in ipairs(h_flip_markers) do
		if v[2] == true then
			h_start = hstart or v[1]
		elseif v[2] == false then
			local v_time = v[1]
			if h_start ~= v_time then
				table.insert(result_p, sb_com:createCommand('param', nil, {h_start, v_time}, nil, nil, {value = "h"}))
			end
			h_start = nil
		end
	end
	if h_start then
		table.insert(result_p, sb_com:createCommand('protract', nil, nil, nil, nil, nil,
		 sb_com:createCommand('param', nil, {h_start, h_start}, nil, nil, {value = "h"})
		 )
		)
	end

	local v_start = nil
	for i,v in ipairs(v_flip_markers) do
		if v[2] == true then
			v_start = v_start or v[1]
		elseif v[2] == false then
			local v_time = v[1]
			if v_start ~= v_time then
				table.insert(result_p, sb_com:createCommand('param', nil, {v_start, v_time}, nil, nil, {value = "v"}))
			end
			v_start = nil
		end
	end
	if v_start then
		table.insert(result_p, sb_com:createCommand('protract', nil, nil, nil, nil, nil,
		  sb_com:createCommand('param', nil, {v_start, v_start}, nil, nil, {value = "v"})
	 	))
	end

	return result_s_v, result_p
end

function verify:sortCommandsByTime(coms)
	if not coms then return nil end
	sb_log:assert(type(coms)=="table", "verify.sortCommandsByTime(): expected a table.")
	table.sort(coms,
		function(a,b)
			local time1,time2
			time1 = sb_com:parse(a, "time")
			time2 = sb_com:parse(b, "time")
			if not time1 or not time2 then return true end
			return time1[1]<time2[1]
		end
	)
end

function verify:getCommandsTimeSpan(coms)
	if not coms or #coms==0 then return nil, nil end

	local min= 1/0
	local max=-1/0

	for i,v in ipairs(coms) do
		local time = sb_com:parse(v, "time")
		local v_min,v_max

		if time then
			v_min,v_max = sb_time:getMinMax(time)
			
			min = math.min(min, v_min)
			max = math.max(max, v_max)
		end
	end

	return min,max
end

function verify:commandTimeLessThan(a,b)
	local time1 = sb_com:parse(a, "time")
	local time2 = sb_com:parse(b, "time")
	return time1 < time 
end

--
-- overlapping H or V parameters will cancel each other out
--
function verify:resolveParameterOverlaps(coms)
	if not coms or not coms[1] then
		return {},{},{} end
	for i,v in ipairs(coms) do
		sb_log:assert(sb_com:equal(v,'param'), "verify:resolveParameterOverlaps(): got non-parameter command.") end

	local H_coms = filter(coms, function(x) return x.value == "h" end)
	local V_coms = filter(coms, function(x) return x.value == "v" end)
	local A_coms = filter(coms, function(x) return x.value == "a" end)

	local H_points = verify:sortedTimes(H_coms)
	local V_points = verify:sortedTimes(V_coms)
	local A_points = verify:sortedTimes(A_coms)

	local result = {}

	local H_flip_start=nil
	for i,v in ipairs(H_points) do
		if v[2] == "min" or v[2] == "max" then
			if H_flip_start then
				table.insert(result,
					{'param', {H_flip_start,v[1]}, value='h'})
				h_flip_start = nil
			else
				H_flip_start = v[1]
			end
		end
	end

	local V_flip_start=nil
	for i,v in ipairs(V_points) do
		if v[2] == "min" or v[2] == "max" then
			if V_flip_start then
				table.insert(result,
					{'param', {V_flip_start,v[1]}, value='v'})
				h_flip_start = nil
			else
				H_flip_start = v[1]
			end
		end
	end

	-- additive blend parameter commands are combined
	-- and simplified, instead of toggling flips like H and V
	local A_count_start = nil
	local A_count=nil
	for i,v in ipairs(A_points) do
		if v[2] == "min" then
			A_count_start = A_count_start or v[1]
			A_count = A_count + 1
		elseif v[2] == "max" then
			A_count = A_count - 1
		end

		if A_count and A_count == 0 then
			table.insert(result,
				{'param', {A_count_start, v[1]}, value='a'})
			A_count = nil
			A_count_start = nil
		end
	end

	return H_coms,V_coms,A_coms
end

function verify:checkTimeOverlaps(commands_list)
	local set = verify:getCommandsTypeSet(commands_list)
	set = filter(set, function (x) return sb_com[x].overlapping == false end)

	for i,v in ipairs(set) do
		local times = verify:sortedTimes(filter(commands_list, function(x) return sb_com:equal(x,v) end))
		local test  = verify:testSortedTimes(times)

		if test then
			local header = string.format("Overlapping '%s' commands:\n", v)

			for com,info in pairs(test) do
				if type(com)=="table" then
					header = header .. string.format("%s at time points ",
						sb_com:toString(com, {time=true,vec=true,easing=false,args=false,varargs=false}))


					for j,p in ipairs(info) do

						-- limit output to 9 overlaps, then ..., then last overlap

						if j == 9 and #info > 9 then
							header = header .. "(...)"
						elseif j < 9 or #info == j then
							header = header .. p[1]
						end

						if j ~= #info and j <= 9 then
							header = header .. ', '
						end
					end
					header = header .. '\n'
				end
			end

			return header
		end
	end

	--[[
	local move_coms   = filter(commands_list, function(x) return sb_com:equal(x, "move", "movex", "movey") end)
	local rot_coms   = filter(commands_list, function(x) return sb_com:equal(x, "rotate") end)
	local scale_coms = filter(commands_list, function(x) return sb_com:equal(x, "scale", "vector") end)
	local colour_coms = filter(commands_list, function(x) return sb_com:equal(x, "colour") end)
	local fade_coms = filter(commands_list, function(x) return sb_com:equal(x, "fade") end)

	local move = verify:sortedTimes(move_coms)
	move = verify:testSortedTimes(move)
	if move then return string.format("Overlapping 'move' commands.") end

	local rot = verify:sortedTimes(rot_coms)
	local scale = verify:sortedTimes(scale_coms)
	local colour = verify:sortedTimes(colour_coms)
	local fade = verify:sortedTimes(fade_coms)--]]

	return nil
end

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
