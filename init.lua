local eval = require 'eval'
local object = require 'object'

local testobj = object:new("slidez.png", "Background", "TopLeft", 320, 420)
print(testobj:out{
 {"move", "cubicout", {0, 5}, {50,50}, {250,250}}
})

local roottest = {
 'root', memo=true,
 {"move", "cubicout", {0, 5}, {50,50}, {250,250}},
 {"move", "cubicout", {0, 5}, {50,50}, {250,250}}
}

print(testobj:out{roottest})
print(testobj:out{roottest})
