local sb = require 'sb-helper'

storyboard = sb:new("./sb.osb")

--         BPM, offset
redline = {120, 1000}

-- object definition
storyboard:newObject("test.png", "Background", "Center", 320, 240):add(


	-- Syntax for commands is very similar to .osb, but with
	-- extra flexibility for how easings and time is written.
	--
	-- this for example, is _M,0,0,1000,240,150,320,240
	--
	{"move" , "linear"     , {"0:00:0", "0:01:000"}, {240,150}, {320,240}},

	-- 
	-- Time can be in "mm:ss:mms", a single Lua number (milliseconds), or the n-th beat
	-- of a timing point, given as a table {{BPM,offset} , beat}
	--
	{"move" , "linear"     , { {redline, 0}, 2000}, {320,240}, {320,240}},

	-- 
	-- Each transformation has a relative version, which lets you transform
	-- based on some given vector/scalar, rather than using absolute units and
	-- manipulating state.
	--
	{"moverel", "elasticout" , {"0:01:000", "0:02:000"}, {0,0}, { 80,-10}},
	{"moverel", "elasticout" , {"0:03:000", "0:04:000"}, {0,0}, {100,-10}},
	{"moverel", "backout"    , {"0:05:000", "0:06:000"}, {0,0}, {0,-200}},

	--
	-- Relative transformations, unlike the transformations in native .osb, can
	-- overlap. Their expected final motion is evaluated during compilation.
	--
	--
	{"moverel", "elasticout" , {"0:07:000", "0:08:400"}, {0,0}, {-50,5}},
	{"moverel", "elasticout" , {"0:07:900", "0:08:900"}, {0,0}, {-30,-10}},
	{"move" , "linear"       , {"0:08:900", "0:10:000"}, {400,240}, {100,240}},
	{"move" , "linear"       , {"0:10:000", "0:11:000"}, {100,240}, {320,40}},

	--
	-- Scale and rotation examples
	--
	-- Each command natively has several aliases, and nothing is case sensitive,
	-- so you can remember whatever is easiest for you.
	--
	{"scale", 'linear' , { "0:12:000", "0:13:500" }, {0.5}, {1}},
	{"scaler", 'linear', { "0:13:000", "0:15:000" }, {1.2}, {1.7}},
	{"scalerelative", 'linear' ,{ "0:16:250", "0:16:300" }, {1.1}, {1.3}},
	{"scale_rel", 'linear', { "0:16:000", "0:16:500" }, {1.2}, {1.6}},
	{"sr", 'linear', { "0:16:000", "0:16:500"}, {1}, {-1}},

	{"rotate", 'linear' , {4000,5500}, 0, 7}

)--]]

--
-- Custom commands
--
--
-- Any animation can be turned into a custom command, either through Lua closures
-- such as this
--
local function wiggle(start_time, end_time, period)
	local start_time  = sb.time:convert( start_time ) -- convert 'mm:ss:mss' etc. to milliseconds
	local end_time    = sb.time:convert( end_time )

	--
	-- Inside this closure we create a function that returns the desired commands
	-- to be used in animation. They can either be returned directly, or passed
	-- into the table it gets as an argument to collect the results.
	--
	return function(out)
		local P = period/4.0
		for i= start_time, end_time, period do
			out{"moverel", "sineIn"  , {i    , i+P*1}, {0,0}, {0, 15}}
			out{"moverel", "sineIn"  , {i+P*1, i+P*3}, {0,0}, {0,-30}}
			out{"moverel", "sineIn"  , {i+P*3, i+P*4}, {0,0}, {0, 15}}
		end
	end
	--
end

--
--
-- ... or a custom command can be made through a definition, passed to, and integrated by the compiler.
--
--
sb.com:addDefinition(
{ 
	-- Command parameters, defining it's behaviour and arguments.
	easing = false,
	time_points = 2,
	dimension = 0,
	args = { "period" },
	varargs = false,

	-- 'eval' is the function for the custom command, which returns other commands.
	eval = function(easing, time, vector_a, vector_b, args, varargs)
		local P, result = args.period/4.0, {}

		for i = time[1],time[2],args.period do
			if i==time[2] then break end
			table.insert(result, {"moverel", "sineIn"  , {i       , i + P*1 }, {0,0}, {0, 15}})
			table.insert(result, {"moverel", "sineIn"  , {i + P*1 , i + P*3 }, {0,0}, {0,-30}})
			table.insert(result, {"moverel", "sineIn"  , {i + P*3 , i + P*4 }, {0,0}, {0, 15}})
		end

		return sb.unpack(result)
	end
	-- 
	--
}
	, 'wiggle', 'w' -- command names and alises
)

--
--  In action, here is how these custom commands can then be used. 
--
storyboard:newObject("test.png", "Background", "Center", 320, 240):add(

	wiggle("0:05:000", 2500, 1250),
	{"wiggle", {"0:05:000", "0:07:500"}, period = 1250 }

)

--
--
-- This architecture also supports arbitrary
-- recursion of compound commands.
-- Here is the compound command origin_scale that
-- applies a transformation to everything inside of itself, which includes
-- other compound commands including itself.
--
--
storyboard:newObject("test.png", "Background", "Center", 320, 240):add(

	{ "origin_scale", translate = { 10, 0 }, scale = {1,1}, rotate = math.pi,

		{"move", 0, {0, 0}, {10,0} },
		wiggle("0:05:000", 2500, 1250),
		{"wiggle", {"0:05:000", "0:07:500"}, period = 1250 },

		{ "origin_scale", translate = { 320, 240 }, scale = {1.0,1.0}, 

			{"move", 0, {"0:15:000", "0:20:000"}, {10,10}, {20,20}},
			wiggle("0:20:000", 25000, 1250),
		}
	}
)

storyboard:writeToFile()
