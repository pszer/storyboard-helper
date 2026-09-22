local eval = require 'eval'
local object = require 'object'
local verify = require 'verify'
local sb = require 'storyboard'

--local testobj = object:new("slidez.png", "Background", "TopLeft", 320, 240)

local function do_the_wiggly_worm_lol (t,dur,period)
	return function(out)
		local P = period/4.0
		for i=t,dur,period do
			out{"moverel", "sineIn"  , {i    , i+P}, {0,0}, {0,15}}
			out{"moverel", "sineOut" , {i+P  , i+P*2}, {0,0}, {0,0}}
			out{"moverel", "sineIn"  , {i+P*2, i+P*3}, {0,0}, {0,-15}}
			out{"moverel", "sineOut" , {i+P*3, i+P*4}, {0,0}, {0,0}}
		end
	end
end

--[[
print(
 object:new("slidez.png", "Background", "Center", 320, 240):out(

	 --{"moverel", "linear", {'-0:00:500', '-0:00:250'}, {0,0}, {50,50}},

	 {"move" , "linear"     , {0, 5000}, {100,100}, {200,300}},
	 {"moverel", "elasticout" , {1000, 2000}, {0,0}, {100,-10}},
	 {"moverel", "elasticout" , {3000, 4000}, {0,0}, {100,-10}},
	 {"moverel", "backout"    , {5000, 6000}, {0,0}, {0,-200}},

	 {"moverel", "elasticout" , {7000,8400}, {0,0}, {-50,5}},
	 {"moverel", "elasticout" , {7900,8900}, {0,0}, {-30,-10}},
	 {"move" , "linear"     , {8900, 10000}, {400,240}, {100,240}},
	 {"move" , "linear"     , {10000, 11000}, {100,240}, {320,40}},

	 do_the_wiggly_worm_lol(8900, 11000, 500),

	 {"scale" , "circout", {0, 2000}, {0.3}, {0.9}},
	 {"scalerel" , "elasticout", {1000, 2000}, {1.0}, {2.0}}

	 --{"moverel", "linear", {'-0:00:500', '0:01:500'}, {10,10}, {50,50}}
 ))--]]


storyboard = sb:new("./sb.osb")

storyboard:newObject("slidez.png", "Background", "Center", 320, 240):add(
	{"move" , "linear"     , {0, 5000}, {100,100}, {200,300}},
	{"moverel", "elasticout" , {1000, 2000}, {0,0}, {100,-10}},
	{"moverel", "elasticout" , {3000, 4000}, {0,0}, {100,-10}},
	{"moverel", "backout"    , {5000, 6000}, {0,0}, {0,-200}},
	{"move" , "linear"     , {8900, 10000}, {400,240}, {100,240}},

	{"moverel", "elasticout" , {7000,8400}, {0,0}, {-50,5}},
	{"moverel", "elasticout" , {7900,8900}, {0,0}, {-30,-10}},
	{"move" , "linear"     , {8900, 10000}, {400,240}, {100,240}},
	{"move" , "linear"     , {10000, 11000}, {100,240}, {320,40}},--]]

	do_the_wiggly_worm_lol(8900, 11000, 500),--]]

	{"vector" , "linear", {0, 2000}, {1,1}, {-1,-1}},
	{"vector" , "linear", {3000, 5000}, {1,1}, {-1,-1}},
	{"vector" , "linear", {6000, 8000}, {2,2}, {-1,-1}},
	{"vector" , "linear", {9000, 11000}, {2,2}, {-1,-1}},
	{"scalerel" , "elasticout", {1000, 1500}, {1.0}, {1.5}},
	{"vector" , "linear", {12000, 13000}, {-1,-1}, {-2,-2}}
)

--print(storyboard:out())
storyboard:writeToFile()
