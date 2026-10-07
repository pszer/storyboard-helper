--
-- Figures out how sprites can be pooled to minimise sprite declaration count.
-- Can also be configured to preserve depth
--
local modules = (...):gsub('%.[^%.]+$', '') .. "."
local sb_log = require (modules..'log')
local sb_verify = require (modules..'verify')
local sb_com = require (modules..'commands')

local pool = {}
pool.__index = pool

--
-- if file_set is nil, every single object will be pooled.
-- ignores depth.
--
function pool:poolObjects(objs, file_set)
	local new_objs = {}

	-- populate file_set if one isn't provided
	--
	if file_set==nil then
		local S = {}
		for i,v in ipairs(objs) do
			S[v.file:out()] = true
		end

		file_set = {}
		for file,_ in pairs(S) do
			table.insert(file_set, file)
		end
	end

	local filter = require (modules..'filter')
	local extract = require (modules..'extract')

	local function get(X)
		-- sample objects can't be pooled, if any are found then output them directly
		--
		local extracted_samples = extract(function(a) return a.file:equal(X) and a.file_type~="image" end, objs)
		for i,v in ipairs(extracted_samples) do
			table.insert(new_objs, v) end

		return extract(function(a) return a.file:equal(X) end, objs)
	end

	-- the min and max times
	-- for an objects commands
	local obj_min = {}
	local obj_max = {}

	for obj_i, file in ipairs(file_set) do
		local f_objs = get(file)

		-- populate min and max data
		for _,v in ipairs(f_objs) do
			local min,max = sb_verify:getCommandsTimeSpan( v.commands )
			obj_min[v] = min
			obj_max[v] = max
		end

		-- sort based on start time for objects lifespan
		table.sort(f_objs, function(a,b) return obj_min[a] < obj_min[b] end)

		local bin_stack = { }

		-- if bin i is free, add to bin i.
		-- if not, add to bin i+1 and repeat check.
		local function insert_to_bins(i, A)
			if bin_stack[i]==nil then
				bin_stack[i] = {A, next_free = obj_max[A]}
				return
			end

			local A_min = obj_min[A]
			local bin = bin_stack[i]

			-- add to bin if it is free at time A_min
			if A_min > bin.next_free then
				bin.next_free = obj_max[A] -- reserve bin until objects lifespan end.
				table.insert(bin, A)
			else
				insert_to_bins(i+1, A)
			end
		end

		-- insert from sorted table
		for _,v in ipairs(f_objs) do
			insert_to_bins(1, v)
		end

		for _,bin in ipairs(bin_stack) do
			local level_object = bin[1]:cloneHeader()
			local max_height = 0

			for i,obj in ipairs(bin) do
				local next_obj = bin[i+1]
				max_height = math.max(max_height, obj.height or 0)
				local coms = obj.commands

				level_object:addTable(coms)
				-- if there is a gap in active timespans, such as
				--    a1         a2
				-- ||||||||.....||||
				-- then a1 will need a fade to 0 command appended to the
				-- end of its lifespan, otherwise it will persist.
				if (next_obj~=nil and (obj_min[next_obj] > obj_max[obj])) then
					local fade0 = sb_verify:getFade0(obj.commands)
					level_object:add(fade0)
				end
			end

			level_object:setHeight(max_height)
			table.insert(new_objs, level_object)
		end
	end

	for i,v in ipairs(new_objs) do
		table.insert(objs, v)
	end
	return new_objs
end

return pool
