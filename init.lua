local eval = require 'eval'
local object = require 'object'
local verify = require 'verify'

local testobj = object:new("slidez.png", "Background", "TopLeft", 320, 240)

local function do_the_wiggly_worm_lol (t,dur,period)
	return function(out)
		local P = period/4.0
		for i=t,dur,period do
			out{"mover", "sineIn"  , {i    , i+P}, {0,0}, {0,15}}
			out{"mover", "sineOut" , {i+P  , i+P*2}, {0,0}, {0,0}}
			out{"mover", "sineIn"  , {i+P*2, i+P*3}, {0,0}, {0,-15}}
			out{"mover", "sineOut" , {i+P*3, i+P*4}, {0,0}, {0,0}}
		end
	end
end

print(
 object:new("slidez.png", "Background", "TopLeft", 320, 240):out{
	 {"move" , "linear"     , {0, 5000}, {100,100}, {200,300}},
	 {"mover", "elasticout" , {1000, 2000}, {0,0}, {100,-10}},
	 {"mover", "elasticout" , {3000, 4000}, {0,0}, {100,-10}},
	 {"mover", "backout"    , {5000, 6000}, {0,0}, {0,-200}},

	 {"mover", "elasticout" , {7000,8400}, {0,0}, {-50,5}},
	 {"mover", "elasticout" , {7900,9000}, {0,0}, {-30,-10}},
	 {"move" , "linear"     , {8900, 10000}, {400,240}, {100,240}},
	 {"move" , "linear"     , {10000, 11000}, {100,240}, {300,40}},

	 do_the_wiggly_worm_lol(8900, 11000, 200)
})

--[[
local roottest = {
 'root', memo=false,

	 {"move" , "linear"     , {0, 5000}, {100,100}, {200,300}},
	 {"mover", "elasticout" , {1000, 2000}, {0,0}, {100,-10}},
	 {"mover", "elasticout" , {3000, 4000}, {0,0}, {100,-10}},
	 {"mover", "backout"    , {5000, 6000}, {0,0}, {0,-200}},

	 {"mover", "elasticout" , {7000,8400}, {0,0}, {-50,5}},
	 {"mover", "elasticout" , {7900,9000}, {0,0}, {-30,-10}},
	 {"move" , "linear"     , {8900, 10000}, {400,240}, {100,240}},
	 {"move" , "linear"     , {10000, 11000}, {100,240}, {300,40}},

	 do_the_wiggly_worm_lol(8900, 11000, 200)

}--]]

--print(testobj:out{roottest})
