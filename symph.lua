package.path = "./?.lua;./?/init.lua;" .. package.path
local sb = require('sbhelper')

storyboard = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/2613444 ryu5150 - Symphonic Touhou IX/ryu5150 - Symphonic Touhou IX (reisen91937).osb")
sb.file:setProjectFolder("/home/quake/.local/share/osu-wine/osu!/Songs/2613444 ryu5150 - Symphonic Touhou IX/")

storyboard:newObject("bg.jpg", "Background", "Center", 320, 240):add(
	{'fade', 0, { -500, -500 }, 0,0 }
)

local function Flash(time,dur,strength,peak)
	local T = sb.time:convert(time)
	return function (out)
		out{'fade',1,{T,T+dur*peak},0,strength}
		out{'fade',1,{T+dur*peak,T+dur},strength,0}
	end
end

local rl1 = {190,57822}

storyboard:newObject("sb/190bpm.png", "Foreground", "BottomCentre", 320, 463):add(
	{'fade', 0, { "0:57:822", "1:01:453" }, 0,0.8 },
	{'scale',0, { "0:57:822", "0:57:822" }, 0.37,0.37 },
	{'fade', 0, { "5:33:663", "5:35:663" }, 0.8,0 }
)

storyboard:newObject("sb/l_t_s.png", "Foreground", "Centre", 320, 286):add(
	{'move', 1, { {rl1,2}, {rl1,2.5} }, {270, 286}, {303,286}},
	{'move', 0, { {rl1,2.5}, {rl1,3} }, {303, 286}, {309,286}},
	{'move', 1, { {rl1,3}, {rl1,16+4} }, {309, 286}, {320,286}},
	{'fade', 1, { {rl1,2}, {rl1,3} }, 0   ,0.8 },
	{'scale',0, { {rl1,2}, {rl1,2} }, 0.40,0.40 },
	{'fade', 0, { "5:33:663", "5:35:663" }, 0.8,0 }
)

storyboard:newObject("sb/tabula.png", "Foreground", "Centre", 320, 333):add(
	{'move', 1, { {rl1,2+8}, {rl1,3.5+8} }, {380, 333}, {337,333}},
	{'move', 0, { {rl1,3.5+8}, {rl1,5.5+8} }, {337, 333}, {328,333}},
	{'move', 1, { {rl1,5.5+8}, {rl1,16+8} }, {328, 333}, {320,333}},
	{'fade', 1, { {rl1,2+8}, {rl1,3+8} }, 0   ,0.8 },
	{'scale',0, { {rl1,2+8}, {rl1,2+8} }, 0.35,0.35 },
	{'fade', 0, { "5:33:663", "5:35:663" }, 0.8,0 }
)

storyboard:newObject("sb/dimdream.png", "Foreground", "Centre", 320, 375):add(
	{'move', 1, { {rl1,2+16}, {rl1,3.5+16} }, {270, 375}, {303,375}},
	{'move', 0, { {rl1,3.5+16}, {rl1,5.5+16} }, {303, 375}, {315,375}},
	{'move', 1, { {rl1,5.5+16}, {rl1,16+8} }, {315, 375}, {320,375}},
	{'fade', 1, { {rl1,2+16}, {rl1,3+16} }, 0   ,0.8 },
	{'scale',0, { {rl1,2+16}, {rl1,2+16} }, 0.29,0.29 },
	{'fade', 0, { "5:33:663", "5:35:663" }, 0.8,0 }
)

storyboard:newObject("sb/190bpm.png", "Foreground", "BottomCentre", 320, 463):add(
	{'fade', 1, { "0:57:822", "0:58:453" }, 0,0.8 },
	{'scale',0, { "0:57:822", "0:57:822" }, 0.37,0.37 },
	{'fade', 0, { "5:33:663", "5:35:663" }, 0.8,0 }
)

storyboard:newObject("sb/E2.jpg", "Background", "TopLeft", -107, 249):add(
	{'scale',0, { "0:57:722", "0:57:882"}, 0.667, 0.667},
	{'color',0, { "0:57:722", "0:57:882"}, {239,239,239}, {239,239,239}},
	{'fade', 1, { "0:57:822", "0:58:453" }, 0,1 },
	{'color', 1, { {rl1,32}, {rl1,32.5} }, {239,239,239},{251,251,251} },
	{'fade', 0, { "5:33:663", "5:35:663" }, 1,0 }
)

local s1_flashes = {}
for i=32,58 do
	table.insert(s1_flashes, Flash({rl1, i},280,0.17,0.25))
end

storyboard:newObject("sb/Flash.jpg", "Foreground", "TopLeft", -107, 249):add(
	Flash({rl1, 0},280, 0.25, 0.25),
	Flash({rl1, 1},350, 0.25, 0.25),

	Flash({rl1, 8},280, 0.25, 0.25),
	Flash({rl1, 9},350, 0.25, 0.25),


	Flash({rl1, 16},280, 0.25, 0.25),
	Flash({rl1, 17},280, 0.25, 0.25),
	
	--Flash({rl1, 18},190, 0.18, 0.125),
	Flash({rl1, 18.5},280, 0.13, 0.125),
	Flash({rl1, 19.5},350, 0.15, 0.25),
	--Flash({rl1, 20},280, 0.18, 0.125),
	--Flash({rl1, 22},190, 0.18, 0.125),
	--Flash({rl1, 23},190, 0.18, 0.125),
	Flash({rl1, 21.5},280, 0.13, 0.25),
	Flash({rl1, 22.5},350, 0.15, 0.25),

	Flash({rl1, 24},280, 0.25, 0.25),
	Flash({rl1, 25},280, 0.25, 0.25),

	Flash({rl1, 26},280, 0.25, 0.25),
	Flash({rl1, 27},280, 0.25, 0.25),
	Flash({rl1, 28},280, 0.25, 0.25),
	Flash({rl1, 29},280, 0.25, 0.25),
	Flash({rl1, 30},280, 0.25, 0.25),
	sb.unpack(s1_flashes)
)


storyboard:newObject("sb/E2.jpg", "Foreground", "TopLeft", -112, 244):add(
	{'scale',0, {{rl1,1},{rl1,1}}, 0.69, 0.69},
	{'protract', {'parameter', { {rl1, 1}, {rl1, 1} }, value='a'}},
	Flash({rl1, 1},350, 0.09, 0.25),
	Flash({rl1, 9},350, 0.09, 0.25),
	Flash({rl1, 17},350, 0.09, 0.25),
	Flash({rl1, 25},280, 0.09, 0.25),

	Flash({rl1, 26},280, 0.09, 0.25),
	Flash({rl1, 27},280, 0.09, 0.25),
	Flash({rl1, 28},280, 0.09, 0.25),
	Flash({rl1, 29},280, 0.11, 0.25),
	Flash({rl1, 30},350, 0.13, 0.25)
)

storyboard:writeToFile2()
