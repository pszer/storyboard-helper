local eval = require 'eval'
local object = require 'object'
local verify = require 'verify'

local testobj = object:new("slidez.png", "Background", "TopLeft", 320, 240)

local roottest = {
 'root', memo=false,
 {"move", "quadout", {0, 10000}, {100,0}, {0,0}},
 {"mover", "linear", {0, 1000}, {50,0}, {100,50}},
 {"mover", "linear", {0, 1000}, {50,0}, {100,50}},
 {"mover", "linear", {0, 5000}, {0,0}, {0,50}},
 {"mover", "linear", {2500, 7500}, {0,0}, {0,-20}},
 {"mover", "linear", {8500, 8500}, {5,-20}},
}

print(testobj:out{roottest})
