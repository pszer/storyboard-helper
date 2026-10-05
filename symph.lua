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

local function FlashFloor(time,dur,strength,peak, floor)
	local T = sb.time:convert(time)
	return function (out)
		out{'fade',1,{T,T+dur*peak},floor,floor+strength}
		out{'fade',1,{T+dur*peak,T+dur},floor+strength,floor}
	end
end

local function FlashScale(time,dur,strength,peak)
	local T = sb.time:convert(time)
	return function (out)
		out{'scalerel',1,{T,T+dur*peak},1,1+strength}
		out{'scalerel',1,{T+dur*peak,T+dur},1,1/(1+strength)}
	end
end

--
--
-- Songe 0
--
--

local rl0 = {90.0, 400}
local rl0_1 = {90.0, 16399}
local rl0_2 = {130.0, 27045}

local rl0_move_in = {
	{'move', 0, {{rl0,0}}, {-107,242}},
	--{'moverel','Out',{ {rl0,0}, {rl0,4*4} }, {0,0}, {0,-20}},
	{'moverel','Out',{ {rl0,0 }, {rl0, 4*3} }, {0,0}, {0,-35}},
	{'moverel','In',{ {rl0,4*3}, {rl0,8*3} }, {0,0}, {0,-50}},
	{'moverel','QuintOut',{ {rl0,8*3}, "0:57:222" }, {0,0}, {0,-150}},
	--{'moverel','linear',{ {rl0,4*4}, {rl0,8*4} }, {0,0}, {0,-12}},
	--{'moverel','SineOut',{ {rl0,4*4}, {rl0,8*4} }, {0,0}, {0,-25}},
}

storyboard:newObject("sb/Intro1_S.jpg", "Background", "TopLeft", -107, 242):add(
	{'fade', 'quartOut', {{rl0,0}, {rl0,2*3}}, 0,0.5},
	{'fade', 'cubicOut', {{rl0,2*3+1}, {rl0,4*3}}, 0.5,0.7},
	{'fade', 'cubicOut', {{rl0,4*3}, {rl0,4*3+2}}, 0.7,0.9},
	{'fade', 'cubicOut', {{rl0,4*3+2}, {rl0,6*3}}, 0.9,0.8},
	{'fade', 'out', {{rl0,7*3+1}, {rl0,8*3}}, 0.8,0.3},
	{'fade', 1, {{rl0,8*3+0.25}}, 0,0},
	sb.concadd(rl0_move_in)
)
storyboard:newObject("sb/Intro2.jpg", "Background", "TopLeft", -107, 242):add(
	{'fade', 'out', {{rl0,8*3-0.25}, {rl0,8*3+0.25}}, 0.0,1.0},
	{'fade', 'out', {{rl0_2,0*4-2.5}, {rl0_2,0*4+0.5}}, 1, 0.8},
	{'fade', 'out', {{rl0_2,0*4+0.5}}, 0},
	sb.concadd(rl0_move_in)
)
storyboard:newObject("bg.jpg", "Background", "TopLeft", -107, 242):add(
	{'scale',0, { {rl0_2,0} }, 0.495 },
	{'fade', 'out', {{rl0_2,0*4}, {rl0_2,0*4+0.5}}, 0.0,1.0},
	{'fade', 1, {"0:53:022", "0:57:222"}, 1,0},
	{'color', 'quintOut', {{rl0_2, 7*4}, {rl0_2, 7*4+2}}, {255,255,255}, {190,190,190}},
	{'color', 'quintIn', {{rl0_2, 7*4+2}, {rl0_2, 8*4}}, {190,190,190}, {255,255,255}},
	{'color', 'cubicOut', {{rl0_2, 12*4}, "0:54:428"}, {255,255,255}, {50,50,50}},
	sb.concadd(rl0_move_in)
)
storyboard:newObject("sb/Intro1_Flash.png", "Background", "TopLeft", -107, 242):add(
	--{'fade', 1, {{rl0,0}, {rl0,2*4}}, 0,0.4},
	--{'fade', 1, {"0:53:022", "0:57:222"}, 0,1},
	{'protract', {'parameter', {{rl0, 0}}, value='a'}},
	Flash({rl0,2*3+1}, 1200, 0.09, 0.4),
	{'fade', 'cubicOut', {{rl0,3*3}, {rl0,3*3+0.9}}, 0, 0.22},
	{'fade', 'quintOut', {{rl0,3*3+2}, {rl0,3*3+8}}, 0.22, 0},

	{'fade', 'cubicOut', {{rl0,6*3+1}, {rl0,7*3}}, 0, 0.32},
	{'fade', 'out', {{rl0,7*3}, {rl0,8*3}}, 0.32, 0.6},
	{'fade', 'out', {{rl0,8*3}, {rl0_1,1*3}}, 0.6, 0.3},
	FlashFloor({rl0_1,1*4-1}, 1200, 0.5, 0.15, 0.5),
	FlashFloor({rl0_1,1*4+2}, 800, 0.2, 0.15, 0.5),
	FlashFloor({rl0_1,2*4}, 900, 0.3, 0.2, 0.5),

	{'fade', 'in', {{rl0_2,0-3},{rl0_2,0}}, 0.5, 0},
	--Flash({rl0_2,0*4}, 1200, 0.2, 0.15),
	Flash({rl0_2,3*4}, 1200, 0.4, 0.1),
	Flash({rl0_2,7*4}, 1200, 0.3, 0.1),
	Flash({rl0_2,8*4}, 1600, 0.5, 0.1),
	Flash({rl0_2,9*4}, 900, 0.15, 0.4),
	Flash({rl0_2,9*4+2}, 900, 0.20, 0.25),

	sb.concadd(rl0_move_in)
)
storyboard:newObject("sb/bgFlash.png", "Background", "TopLeft", -107, 242):add(
	{'scale',0, { {rl0_2,0} }, 0.4956*2*2 },
	{'moverel',0, { {rl0_2,0} }, {0,0},{1,0} },
	{'protract', {'parameter', {{rl0_2, 0}}, value='a'}},
	Flash({rl0_2,0*4}, 1200, 0.7, 0.1),
	Flash({rl0_2,4*4+0.1}, 1200, 0.5, 0.4),
	Flash({rl0_2,8*4}, 1600, 0.7, 0.1),
	Flash({rl0_2,10*4}, 1600, 0.08, 0.1),
	{'fade', 'cubicOut', {{rl0_2, 12*4}, {rl0_2, 13*4}}, 0, 0.6},
	{'fade', 'in', {{rl0_2, 13*4}, {rl0_2, 13*4+1}}, 0.6, 1.0},
	{'fade', 'in', {{rl0_2, 13*4+1}, {rl0_2, 13*4+2}}, 1.0, 0.6},
	{'fade', 'cubicOut', {"0:52:428", "0:54:428"}, 0.6, 0.0},
	--Flash({rl0_2,12*4}, 4000, 0.4, 0.3),
	sb.concadd(rl0_move_in)
)

storyboard:newObject("sb/Black.jpg", "Foreground", "BottomLeft", -106.7, 480):add(
	Flash({rl0_2,0*4}, 800, 0.1, 0.25),
	Flash({rl0_2,4*4}, 600, 0.15, 0.3)
	--Flash({rl0_2,4*4+1}, 450, 0.1, 0.25),
	--Flash({rl0_2,4*4+2}, 450, 0.1, 0.25),
	--Flash({rl0_2,5*4}, 600, 0.15, 0.3),
	--Flash({rl0_2,6*4}, 600, 0.15, 0.3)
)

local rl0_text = {90.0, 400}

storyboard:newObject("sb/90bpm.png", "Foreground", "Centre", 318, 449):add(
	{'fade', 1, { {rl0_text,2}, {rl0_text,5} }, 0   ,1.0 },
	{'scale',0, { {rl0_text,2}, {rl0_text,5} }, 0.47,0.47 },
	{'fade', 'cubicOut', {"0:52:428", "0:54:428"}, 1.0, 0.0}
)

storyboard:newObject("sb/symphonic.png", "Foreground", "Centre", 242, 306):add(
	{'moverel', 1, { {rl0_text,3}, {rl0_text,3.5} }, {0, 0}, {33,0}},
	{'moverel', 0, { {rl0_text,3.5}, {rl0_text,4} }, {0, 0}, {17,0}},
	{'moverel', 1, { {rl0_text,4}, {rl0_text,25+4} }, {0, 0}, {24,0}},

	{'fade', 1, { {rl0_text,3}, {rl0_text,5} }, 0   ,1.0 },
	{'scale',0, { {rl0_text,3}, {rl0_text,5} }, 0.49,0.49 },
	{'fade', 0, { {rl0_text,8*3-1.4}, {rl0_text,8*3+0.5} }, 1.0,0 }
)

storyboard:newObject("sb/dream_scarlet.png", "Foreground", "Centre", 385, 354):add(
	{'moverel', 1, { {rl0_text,4+4}, {rl0_text,5.5+4} }, {0, 0}, {-33,0}},
	{'moverel', 0, { {rl0_text,5.5+4}, {rl0_text,7.2+4} }, {0, 0}, {-16,0}},
	{'moverel', 1, { {rl0_text,7.2+4}, {rl0_text,29+4} }, {0, 0}, {-28,0}},
	{'fade', 1, { {rl0_text,4+4}, {rl0_text,7+4} }, 0   ,1.0 },
	{'scale',0, { {rl0_text,4+4}, {rl0_text,4+4} }, 0.41,0.41 },
	{'fade', 0, { {rl0_text,8*3-2}, {rl0_text,8*3} }, 1.0,0 }
)

storyboard:newObject("sb/eosd0.png", "Foreground", "Centre", 253, 394):add(
	{'moverel', 1, { {rl0_text,1+15}, {rl0_text,2.5+15} }, {0, 0}, {35,0}},
	{'moverel', 0, { {rl0_text,2.5+15}, {rl0_text,4.2+15} }, {0, 0}, {7,0}},
	{'moverel', 1, { {rl0_text,4.2+15}, {rl0_text,23+7} }, {0, 0}, {16,0}},
	{'fade', 1, { {rl0_text,1+15}, {rl0_text,4+15} }, 0   ,1.0 },
	{'scale',0, { {rl0_text,1+15}, {rl0_text,1+15} }, 0.36,0.36 },
	{'fade', 0, { {rl0_text,8*3-2.0}, {rl0_text,8*3-0.2} }, 1.0,0 }
)



-----
---
---
---
---
---
---
---
---
---
---
---
---
local rl1 = {190,57822}
local rl2 = {190,281400}

local s1_bpm_flashes = {}

storyboard:newObject("sb/190bpm.png", "Foreground", "Centre", 320, 449):add(
	{'fade', 1, { {rl1,2+22}, {rl1,5+22} }, 0   ,0.8 },
	{'scale',0, { "0:59:822", "0:59:822" }, 0.33,0.33 },
	{'fade', 0, { "5:33:663", "5:35:663" }, 0.9,0 },

	--{'moverel', 'out', { {rl1,32}, {rl1,34} }, {0,0}, {0,-1} },
	{'fade', 'out', { {rl1,32}, {rl1,34} }, 0.8, 0.91 },

	sb.unpack(s1_bpm_flashes)
)

storyboard:newObject("sb/l_t_s.png", "Foreground", "Centre", 242, 296):add(
	{'moverel', 1, { {rl1,3}, {rl1,3.5} }, {0, 0}, {33,0}},
	{'moverel', 0, { {rl1,3.5}, {rl1,4} }, {0, 0}, {17,0}},
	{'moverel', 1, { {rl1,4}, {rl1,25+4} }, {0, 0}, {24,0}},
	{'fade', 1, { {rl1,3}, {rl1,5} }, 0   ,0.9 },
	{'scale',0, { {rl1,3}, {rl1,3} }, 0.48,0.48 },
	{'fade', 0, { {rl1,32-0.5}, {rl1,34-0.5} }, 0.9,0 }
)

storyboard:newObject("sb/tabula.png", "Foreground", "Centre", 385, 344):add(
	{'moverel', 1, { {rl1,2+8}, {rl1,3.5+8} }, {0, 0}, {-43,0}},
	{'moverel', 0, { {rl1,3.5+8}, {rl1,5.2+8} }, {0, 0}, {-9,0}},
	{'moverel', 1, { {rl1,5.2+8}, {rl1,26+8} }, {0, 0}, {-18,0}},
	{'fade', 1, { {rl1,2+8}, {rl1,5+8} }, 0   ,0.9 },
	{'scale',0, { {rl1,2+8}, {rl1,2+8} }, 0.46,0.46 },
	{'fade', 0, { {rl1,32.15-0.6}, {rl1,34.15-0.6} }, 0.9,0 }
)

storyboard:newObject("sb/dimdream.png", "Foreground", "Centre", 253, 386):add(
	{'moverel', 1, { {rl1,2+15}, {rl1,3.5+15} }, {0, 0}, {35,0}},
	{'moverel', 0, { {rl1,3.5+15}, {rl1,5.2+15} }, {0, 0}, {7,0}},
	{'moverel', 1, { {rl1,5.2+15}, {rl1,23+8} }, {0, 0}, {16,0}},
	{'fade', 1, { {rl1,2+15}, {rl1,5+15} }, 0   ,0.9 },
	{'scale',0, { {rl1,2+15}, {rl1,2+15} }, 0.28,0.28 },
	{'fade', 0, { {rl1,32.3-0.6}, {rl1,34.3-0.6} }, 0.9,0 }
)

storyboard:newObject("sb/ellen.png", "Foreground", "Centre", 395, 405):add(
	{'moverel', 1, { {rl1,2+22-0.5}, {rl1,3.5+22-0.5} }, {0, 0}, {-59,0}},
	{'moverel', 0, { {rl1,3.5+22-0.5}, {rl1,4.5+22-0.5} }, {0, 0}, {-07,0}},
	{'moverel', 1, { {rl1,4.5+22-0.5}, {rl1,34-0.5} }, {0, 0}, {-09,0}},
	{'fade', 1, { {rl1,2+22}, {rl1,5+22} }, 0   ,0.9 },
	{'scale',0, { {rl1,2+22}, {rl1,2+22} }, 0.25,0.25 },
	{'fade', 0, { {rl1,32.45-0.6}, {rl1,34.45-0.6} }, 0.9,0 }
)

local rl1_move_in = {
	{'move', 'linear', {{rl1,0}}, {-107,242}},
	{'moverel','Out',{ {rl1,0}, {rl1,16}}, {0,0}, {0,-50}},
	{'moverel','linear',{ {rl1,14}, {rl1,29}}, {0,0}, {0,-25}},
	{'moverel','linear',{ {rl1,29}, {rl1,31}}, {0,0}, {0,-5}},
}

storyboard:newObject("sb/Ellen.jpg", "Background", "TopLeft", -107, 242):add(
	{'scale',0, { "0:57:722", "0:57:882"}, 0.667, 0.667},
	{'color',0, { "0:57:722", "0:57:882"}, {225,225,225}, {225,225,225}},
	{'fade', 1, { "0:57:822", "0:59:053" }, 0,0.85 },
	{'fade', 0, { "0:59:053", "1:01:453" }, 0.85,1 },
	{'fade', 'quintIn', { {rl1,32-0.5}, {rl1,32+0.5} }, 1,0 },
	{'fade', 1,  { {rl1,22*4}, {rl1,22*4} }, 1,1 },
	{'fade', 1,  { {rl1,49*4}, {rl1,49*4} }, 0,0 },

	{'color',0, { {rl1,72*4}, {rl1,72*4} }, {180,180,180}, {180,180,180}},
	{'fade', 1,  { {rl1,72*4}, {rl1,72*4} }, 1,1 },
	{'fade', 1,  { {rl1,92*4}, {rl1,92*4} }, 0,0 },
	{'color',0, { {rl1,74*4-0.5}, {rl1,74*4} }, {180,180,180}, {225,225,225}},
	{'fade', 1,  { {rl1,146*4-0.5}, {rl1,146*4-0.5} }, 1,1 },
	{'fade', 1,  { {rl1,148*4}, {rl1,148*4} }, 0,0 },

	{'fade', 1,  { {rl1,166*4-1}, {rl1,166*4-1} }, 1,1 },
	{'fade', 1,  { {rl2,9*4}, {rl2,9*4} }, 0,0 },

	{'color','out', { "04:40:137", {rl2,2} }, {225,225,225}, {160,160,160}},
	{'color','in', { {rl2,3},{rl2,4}}, {160,160,160}, {235,235,235}},

	sb.concadd(rl1_move_in)
)

storyboard:newObject("sb/EllenI1.jpg", "Background", "TopLeft", -107, 162):add(
	{'scale',0, { {rl1,107*4-1}, {rl1,107*4-1} }, 0.667, 0.667},
	{'fade', 'out',  { {rl1,107*4-1}, {rl1,107*4-1} }, 1,1 },
	{'moverel', 'sineIn',  { {rl1,107*4-1}, {rl1,111*4} }, {0,0},{0,22} },
	{'moverel', 'linear',  { {rl1,110*4}, {rl1,113*4} }, {0,0},{0,12} },
	{'moverel', 'out',  { {rl1,111*4}, {rl1,115*4} }, {0,0},{0,-4} },
	{'moverel', 'linear',  { {rl1,115*4}, {rl1,120*4} }, {0,0},{0,-5} },
	{'moverel', 'in',  { {rl1,112*4}, {rl1,123*4} }, {0,0},{0,-25} },
	{'color'  , 'out', { {rl1,123*4}, {rl1,125*4}}, {255,255,255}, {180,180,180}},
	{'fade', 'out',  { {rl1,126*4}, {rl1,126*4} }, 0,0 },
	{'color'  , 'linear', { {rl1,150*4-0.5}, {rl1,150*4-0.5}}, {255,255,255}, {255,255,255}},
	{'fade', 'linear',  { {rl1,150*4-0.5}, {rl1,150*4-0.5} }, 1,1 },
	{'fade', 'out',  { {rl1,166*4-1.0}, {rl1,166*4} }, 1,0 }
)

storyboard:newObject("sb/EllenI2.jpg", "Background", "TopLeft", -107, 162):add(
	{'scale',0, { {rl1,126*4-0.5}, {rl1,126*4-0.5} }, 0.667, 0.667},
	{'fade', 'in',  { {rl1,126*4-0.5}, {rl1,126*4} }, 0,1 },
	--{'moverel', 'sineIn',  { {rl1,107*4-1}, {rl1,111*4} }, {0,0},{0,22} },
	--{'moverel', 'linear',  { {rl1,110*4}, {rl1,113*4} }, {0,0},{0,12} },
	--{'moverel', 'out',  { {rl1,111*4}, {rl1,115*4} }, {0,0},{0,-4} },
	--{'moverel', 'linear',  { {rl1,115*4}, {rl1,120*4} }, {0,0},{0,-5} },
	--{'moverel', 'in',  { {rl1,112*4}, {rl1,123*4} }, {0,0},{0,-28} },
	--{'color'  , 'out', { {rl1,123*4}, {rl1,125*4}}, {255,255,255}, {180,180,180}},
	{'fade', 'out',  { {rl1,146*4-0.5}, {rl1,146*4+0.5} }, 1,0 },
	{'fade', 'out',  { {rl1,148*4-0.5}, {rl1,148*4} }, 0,1 },
	{'color'  , 'linear', { {rl1,148*4-0.5}, {rl1,148*4-0.5}}, {230,230,230}, {230,230,230}},
	{'fade', 'quintin',  { {rl1,150*4-0.5}, {rl1,150*4} }, 1,0 }
)

storyboard:newObject("sb/EllenK.jpg", "Background", "TopLeft", -106.7, 122):add(
	{'scale',0 , { {rl1,8*4-0.5}, {rl1,8*4-0.5} }, 0.6675, 0.6675},
	{'color',0 , { {rl1,8*4-0.5}, {rl1,8*4-0.5} }, {220,220,220},{220,220,220}},
	{'fade', 1,  { {rl1,8*4-0.5}, {rl1,8*4+0.5} }, 0,1 },
	{'color', 1,  { {rl1,16*4-0.5}, {rl1,16*4} }, {220,220,220},{255,255,255} },
	{'fade', 1,  { {rl1,23*4-0.5}, {rl1,23*4} }, 1,0 },
	{'fade', 1,  { {rl1,49*4-0.5}, {rl1,49*4} }, 0,1 },
	{'fade', 'out',  { {rl1,73*4-1}, {rl1,73*4} }, 1,0 },
	{'color', 1,  { {rl1,65*4-0.5}, {rl1,65*4} }, {255,255,255},{220,220,220} },
	Flash({rl1, 39*4},1400, 0.8, 0.1),
	Flash({rl1, 47*4},1400, 0.8, 0.1),
	{'fade', 'in',  { {rl1,74*4-3}, {rl1,74*4} }, 0,0.8 },
	{'fade', 'out',  { {rl1,74*4}, {rl1,76*4} }, 0.8,0 },
	Flash({rl1, 81*4},1400, 0.8, 0.1),
	--
	{'color', 1,  { {rl1,91*4-0.5}, {rl1,91*4-0.5} }, {225,225,225},{255,255,255} },
	{'fade', 1,  { {rl1,91*4-0.5}, {rl1,91*4} }, 0,1 },
	{'fade', 'quintIn',  { {rl1,107*4-1}, {rl1,107*4} }, 1,0 },
	{'fade', 'out',  { {rl2,33*4-0.5}, {rl2,33*4-0.5} }, 1,1 },
	{'fade', 'out',  { {rl2,42*4-2}, {rl2,43*4} }, 1,0 },
	sb.concadd(rl1_move_in)
)

storyboard:newObject("sb/EllenK2.jpg", "Background", "TopLeft", -106.7, 162):add(
	{'scale',0 , { {rl2,9*4-0.5}, {rl2,9*4-0.5} }, 0.6675, 0.6675},
	{'fade', 1,  { {rl2,9*4-0.5}, {rl2,9*4} }, 0,1 },
	{'fade', 'out',  { {rl2,33*4-0.5}, {rl2,33*4} }, 1,0 },

	Flash({rl1, 175*4},2400, 0.8, 0.1),
	Flash({rl2, 5*4},1600, 0.6, 0.1)
)

local count = 1
local flashes_s1 = {}
for i = 33, 16*4-2,1 do
	local str = 0.05
	if i==12*4 or i==14*4 then str=0.10 end
	flashes_s1[count] = Flash({rl1,i}, 280, str, 0.15)
	count=count+1
end

for i = 65*4+1, 72*4-2,1 do
	local str = 0.07
	if i==69*4 or i==71*4 then str=0.13 end
	flashes_s1[count] = Flash({rl1,i}, 280, str, 0.15)
	count=count+1
end

storyboard:newObject("sb/EllenFlash.png", "Foreground", "TopLeft", -107, 242):add(
	{'protract', {'parameter', { {rl1, 0}, {rl1, 0} }, value='a'}},
	Flash({rl1, 0},280, 0.5, 0.25),
	Flash({rl1, 1},800, 0.65, 0.1),
	Flash({rl1, 8},280, 0.2, 0.25),
	Flash({rl1, 9},800, 0.25, 0.1),
	Flash({rl1, 16},280, 0.2, 0.25),
	Flash({rl1, 17},800, 0.25, 0.1),

	Flash({rl1, 24},280, 0.2, 0.25),
	Flash({rl1, 25},280, 0.09, 0.1),

	Flash({rl1, 26},280, 0.10, 0.25),
	Flash({rl1, 27},280, 0.11, 0.25),
	Flash({rl1, 28},280, 0.12, 0.25),
	Flash({rl1, 29},280, 0.13, 0.25),
	Flash({rl1, 30},350, 0.14, 0.25),

	Flash({rl1, 16*4},350, 0.17, 0.25),
	Flash({rl1, 17*4},350, 0.10, 0.25),
	Flash({rl1, 18*4},350, 0.10, 0.25),
	Flash({rl1, 20*4},350, 0.17, 0.25),
	Flash({rl1, 21*4},350, 0.10, 0.25),
	Flash({rl1, 22*4},350, 0.10, 0.25),
	Flash({rl1, 23*4},1400, 0.25, 0.1),
	Flash({rl1, 27*4},1400, 0.25, 0.1),
	Flash({rl1, 31*4},1400, 0.15, 0.1),
	Flash({rl1, 35*4},1400, 0.15, 0.1),
	Flash({rl1, 39*4},800, 0.18, 0.1),
	Flash({rl1, 43*4},800, 0.18, 0.1),
	Flash({rl1, 47*4},800, 0.15, 0.1),
	Flash({rl1, 49*4},800, 0.25, 0.1),
	Flash({rl1, 53*4},800, 0.18, 0.1),
	Flash({rl1, 57*4},800, 0.18, 0.1),
	Flash({rl1, 61*4},800, 0.18, 0.1),
	Flash({rl1, 63*4},800, 0.18, 0.1),
	Flash({rl1, 65*4},280, 0.18, 0.25),
	Flash({rl1, 73*4},600, 0.11, 0.25),
	Flash({rl1, 74*4},280, 0.15, 0.25),
	Flash({rl1, 81*4},800, 0.15, 0.1),
	Flash({rl1, 85*4},800, 0.15, 0.1),
	Flash({rl1, 89*4},800, 0.15, 0.1),


	Flash({rl1, 91*4},800, 0.25, 0.1),
	Flash({rl1, 95*4},800, 0.18, 0.1),
	Flash({rl1, 99*4},800, 0.18, 0.1),
	Flash({rl1, 103*4},800, 0.18, 0.1),
	Flash({rl1, 105*4},800, 0.18, 0.1),
	Flash({rl1, 107*4},280, 0.18, 0.25),

	Flash({rl1, 123*4},280, 0.18, 0.25),
	
	Flash({rl1, 125*4},280, 0.10, 0.25),
	Flash({rl1, 125*4+1},280, 0.10, 0.25),
	Flash({rl1, 125*4+2},280, 0.10, 0.25),
	Flash({rl1, 125*4+3},280, 0.15, 0.25),

	Flash({rl1, 126*4},280, 0.25, 0.25),

	Flash({rl1, 127*4},600, 0.07, 0.25),
	Flash({rl1, 128*4},600, 0.07, 0.25),
	Flash({rl1, 129*4},600, 0.07, 0.25),
	Flash({rl1, 132*4},600, 0.15, 0.25),
	Flash({rl1, 134*4},600, 0.15, 0.25),
	Flash({rl1, 135*4},600, 0.07, 0.25),
	Flash({rl1, 136*4},600, 0.07, 0.25),
	Flash({rl1, 137*4},600, 0.07, 0.25),

	Flash({rl1, 142*4},280, 0.13, 0.1),
	Flash({rl1, 142*4+1},280, 0.06, 0.1),
	Flash({rl1, 142*4+2},280, 0.06, 0.1),
	Flash({rl1, 142*4+3},280, 0.06, 0.1),
	Flash({rl1, 142*4+4},280, 0.06, 0.1),
	Flash({rl1, 142*4+5},280, 0.06, 0.1),
	Flash({rl1, 142*4+6},280, 0.06, 0.1),
	Flash({rl1, 142*4+7},280, 0.06, 0.1),
	Flash({rl1, 142*4+8},280, 0.06, 0.1),
	Flash({rl1, 142*4+9},280, 0.06, 0.1),
	Flash({rl1, 142*4+10},280, 0.06, 0.1),
	Flash({rl1, 142*4+11},280, 0.06, 0.1),
	Flash({rl1, 142*4+12},280, 0.06, 0.1),
	Flash({rl1, 142*4+13},280, 0.06, 0.1),
	Flash({rl1, 142*4+14},280, 0.06, 0.1),
	Flash({rl1, 146*4},280, 0.10, 0.1),

	Flash({rl1, 148*4},280, 0.13, 0.1),
	Flash({rl1, 148*4+1},280, 0.06, 0.1),
	Flash({rl1, 148*4+2},280, 0.06, 0.1),
	Flash({rl1, 148*4+3},280, 0.06, 0.1),
	Flash({rl1, 148*4+4},280, 0.06, 0.1),
	Flash({rl1, 148*4+5},280, 0.06, 0.1),
	Flash({rl1, 148*4+6},280, 0.06, 0.1),
	Flash({rl1, 148*4+7},280, 0.06, 0.1),

	Flash({rl1, 150*4},800, 0.18, 0.1),
	Flash({rl1, 151*4},800, 0.07, 0.1),
	Flash({rl1, 152*4},800, 0.07, 0.1),
	Flash({rl1, 153*4},800, 0.07, 0.1),
	--Flash({rl1, 154*4},800, 0.09, 0.1),
	Flash({rl1, 158*4},800, 0.18, 0.1),
	Flash({rl1, 159*4},800, 0.07, 0.1),
	Flash({rl1, 160*4},800, 0.07, 0.1),
	Flash({rl1, 161*4},800, 0.07, 0.1),

	Flash({rl1, 166*4},800, 0.25, 0.1),


	Flash({rl1, 168*4},800, 0.15, 0.1),
	Flash({rl1, 170*4},800, 0.15, 0.1),
	Flash({rl1, 174*4},800, 0.12, 0.1),

	Flash({rl2, 1*4},800, 0.16, 0.1),
	Flash({rl2, 2*4},800, 0.10, 0.1),
	Flash({rl2, 3*4},800, 0.10, 0.1),
	Flash({rl2, 4*4},800, 0.10, 0.1),

	Flash({rl2, 9*4},800, 0.16, 0.1),
	Flash({rl2, 13*4},800, 0.12, 0.1),
	Flash({rl2, 15*4},800, 0.12, 0.1),
	Flash({rl2, 16*4},800, 0.20, 0.1),

	Flash({rl2, 25*4},800, 0.25, 0.1),
	Flash({rl2, 29*4},800, 0.18, 0.1),
	Flash({rl2, 31*4},800, 0.18, 0.1),
	sb.concadd(rl1_move_in, flashes_s1)
)
storyboard:newObject("sb/EllenFlash2.png", "Foreground", "TopLeft", -107, 162):add(
	{'protract', {'parameter', { {rl1, 0}, {rl1, 0} }, value='a'}},
	Flash({rl1, 41*4},800, 0.2, 0.1),
	Flash({rl1, 83*4},800, 0.2, 0.1),
	Flash({rl2, 5*4},800, 0.22, 0.1),
	Flash({rl2, 39*4},800, 0.12, 0.1),
	Flash({rl2, 40*4},280, 0.18, 0.25),
	Flash({rl2, 40*4+1.5},280, 0.18, 0.25),
	Flash({rl2, 40*4+3},500, 0.18, 0.10),
	Flash({rl2, 41*4+1.5},1200, 0.25, 0.06)
)

-- black flashes
storyboard:newObject("sb/Black.jpg", "Foreground", "BottomLeft", -106.7, 480):add(
	Flash({rl1, 45*4 + 0 },280, 0.1, 0.25),
	Flash({rl1, 45*4 + 1 },280, 0.1, 0.25),
	Flash({rl1, 45*4 + 2 },280, 0.1, 0.25),
	Flash({rl1, 45*4 + 3 },280, 0.1, 0.25),
	Flash({rl1, 45*4 + 4 },280, 0.1, 0.25),
	Flash({rl1, 45*4 + 5 },280, 0.1, 0.25),
	Flash({rl1, 45*4 + 6 },280, 0.1, 0.25),
	Flash({rl1, 45*4 + 7 },280, 0.1, 0.25),

	Flash({rl1, 77*4 + 0 },280, 0.06, 0.25),
	Flash({rl1, 77*4 + 1 },280, 0.06, 0.25),
	Flash({rl1, 77*4 + 2 },280, 0.06, 0.25),
	Flash({rl1, 77*4 + 3 },280, 0.06, 0.25),
	Flash({rl1, 77*4 + 4 },280, 0.06, 0.25),
	Flash({rl1, 77*4 + 5 },280, 0.06, 0.25),
	Flash({rl1, 77*4 + 6 },280, 0.06, 0.25),
	Flash({rl1, 77*4 + 7 },280, 0.06, 0.25),
	Flash({rl1, 77*4 + 8 },280, 0.06, 0.25),
	Flash({rl1, 77*4 + 9 },280, 0.06, 0.25),
	Flash({rl1, 77*4 + 10 },280, 0.06, 0.25),
	Flash({rl1, 77*4 + 11 },280, 0.06, 0.25),
	Flash({rl1, 77*4 + 12 },280, 0.06, 0.25),
	Flash({rl1, 77*4 + 13 },280, 0.06, 0.25),
	Flash({rl1, 77*4 + 14 },280, 0.06, 0.25),
	Flash({rl1, 77*4 + 15 },280, 0.06, 0.25),

	Flash({rl1, 87*4 + 0 },280, 0.1, 0.25),
	Flash({rl1, 87*4 + 1 },280, 0.1, 0.25),
	Flash({rl1, 87*4 + 2 },280, 0.1, 0.25),
	Flash({rl1, 87*4 + 3 },280, 0.1, 0.25),
	Flash({rl1, 87*4 + 4 },280, 0.1, 0.25),
	Flash({rl1, 87*4 + 5 },280, 0.1, 0.25),
	Flash({rl1, 87*4 + 6 },280, 0.1, 0.25),
	Flash({rl1, 87*4 + 7 },280, 0.1, 0.25),

	Flash({rl1, 73*4+3},600, 0.2, 0.25),

	Flash({rl1, 115*4},800, 0.1, 0.1),
	Flash({rl1, 116*4},800, 0.1, 0.1),
	Flash({rl1, 117*4},800, 0.1, 0.1),
	Flash({rl1, 118*4},800, 0.1, 0.1),
	Flash({rl1, 119*4},800, 0.1, 0.1),

	Flash({rl1, 130*4 + 0 },280, 0.09, 0.25),
	Flash({rl1, 130*4 + 1 },280, 0.09, 0.25),
	Flash({rl1, 130*4 + 2 },280, 0.09, 0.25),
	Flash({rl1, 130*4 + 3 },280, 0.09, 0.25),
	Flash({rl1, 130*4 + 4 },280, 0.09, 0.25),
	Flash({rl1, 130*4 + 5 },280, 0.09, 0.25),
	Flash({rl1, 130*4 + 6 },280, 0.09, 0.25),
	Flash({rl1, 130*4 + 7 },280, 0.09, 0.25),
	Flash({rl1, 130*4 + 8 },280, 0.09, 0.25),
	Flash({rl1, 130*4 + 9 },280, 0.09, 0.25),
	Flash({rl1, 130*4 + 10 },280, 0.09, 0.25),
	Flash({rl1, 130*4 + 11 },280, 0.09, 0.25),
	Flash({rl1, 130*4 + 12 },280, 0.09, 0.25),
	Flash({rl1, 130*4 + 13 },280, 0.09, 0.25),
	Flash({rl1, 130*4 + 14 },280, 0.09, 0.25),
	Flash({rl1, 130*4 + 15 },280, 0.09, 0.25),

	Flash({rl1, 138*4 + 0 },280, 0.09, 0.25),
	Flash({rl1, 138*4 + 1 },280, 0.09, 0.25),
	Flash({rl1, 138*4 + 2 },280, 0.09, 0.25),
	Flash({rl1, 138*4 + 3 },280, 0.09, 0.25),
	Flash({rl1, 138*4 + 4 },280, 0.09, 0.25),
	Flash({rl1, 138*4 + 5 },280, 0.09, 0.25),
	Flash({rl1, 138*4 + 6 },280, 0.09, 0.25),
	Flash({rl1, 138*4 + 7 },280, 0.09, 0.25),
	Flash({rl1, 138*4 + 8 },280, 0.09, 0.25),
	Flash({rl1, 138*4 + 9 },280, 0.09, 0.25),
	Flash({rl1, 138*4 + 10 },280, 0.09, 0.25),
	Flash({rl1, 138*4 + 11 },280, 0.09, 0.25),
	Flash({rl1, 138*4 + 12 },280, 0.09, 0.25),
	Flash({rl1, 138*4 + 13 },280, 0.09, 0.25),
	Flash({rl1, 138*4 + 14 },280, 0.09, 0.25),
	Flash({rl1, 138*4 + 15 },280, 0.09, 0.25),

	Flash({rl1, 154*4 + 0 },280, 0.09, 0.25),
	Flash({rl1, 154*4 + 1 },280, 0.09, 0.25),
	Flash({rl1, 154*4 + 2 },280, 0.09, 0.25),
	Flash({rl1, 154*4 + 3 },280, 0.09, 0.25),
	Flash({rl1, 154*4 + 4 },280, 0.09, 0.25),
	Flash({rl1, 154*4 + 5 },280, 0.09, 0.25),
	Flash({rl1, 154*4 + 6 },280, 0.09, 0.25),
	Flash({rl1, 154*4 + 7 },280, 0.09, 0.25),
	Flash({rl1, 154*4 + 8 },280, 0.09, 0.25),
	Flash({rl1, 154*4 + 9 },280, 0.09, 0.25),
	Flash({rl1, 154*4 + 10 },280, 0.09, 0.25),
	Flash({rl1, 154*4 + 11 },280, 0.09, 0.25),
	Flash({rl1, 154*4 + 12 },280, 0.09, 0.25),
	Flash({rl1, 154*4 + 13 },280, 0.09, 0.25),
	Flash({rl1, 154*4 + 14 },280, 0.09, 0.25),
	Flash({rl1, 154*4 + 15 },280, 0.09, 0.25),

	Flash({rl1, 162*4 + 0 },280, 0.09, 0.25),
	Flash({rl1, 162*4 + 1 },280, 0.09, 0.25),
	Flash({rl1, 162*4 + 2 },280, 0.09, 0.25),
	Flash({rl1, 162*4 + 3 },280, 0.09, 0.25),
	Flash({rl1, 162*4 + 4 },280, 0.09, 0.25),
	Flash({rl1, 162*4 + 5 },280, 0.09, 0.25),
	Flash({rl1, 162*4 + 6 },280, 0.09, 0.25),
	Flash({rl1, 162*4 + 7 },280, 0.09, 0.25),
	Flash({rl1, 162*4 + 8 },280, 0.09, 0.25),
	Flash({rl1, 162*4 + 9 },280, 0.09, 0.25),
	Flash({rl1, 162*4 + 10 },280, 0.09, 0.25),
	Flash({rl1, 162*4 + 11 },280, 0.09, 0.25),
	Flash({rl1, 162*4 + 12 },280, 0.09, 0.25),
	Flash({rl1, 162*4 + 13 },280, 0.09, 0.25),
	Flash({rl1, 162*4 + 14 },280, 0.09, 0.25),
	Flash({rl1, 162*4 + 15 },280, 0.09, 0.25),

	Flash({rl1, 172*4 + 0 },280, 0.1, 0.25),
	Flash({rl1, 172*4 + 1 },280, 0.1, 0.25),
	Flash({rl1, 172*4 + 2 },280, 0.1, 0.25),
	Flash({rl1, 172*4 + 3 },280, 0.1, 0.25),
	Flash({rl1, 172*4 + 4 },280, 0.1, 0.25),
	Flash({rl1, 172*4 + 5 },280, 0.1, 0.25),
	Flash({rl1, 172*4 + 6 },280, 0.1, 0.25),
	Flash({rl1, 172*4 + 7 },280, 0.1, 0.25),

	Flash({rl2, 17*4 + 0 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 1 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 2 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 3 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 4 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 5 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 6 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 7 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 8 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 9 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 10 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 11 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 12 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 13 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 14 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 15 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 16 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 17 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 18 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 19 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 20 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 21 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 22 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 23 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 24 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 25 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 26 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 27 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 28 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 29 },280, 0.06, 0.25),
	Flash({rl2, 17*4 + 30 },280, 0.06, 0.25),

	Flash({rl2, 33*4},800, 0.12, 0.1),
	Flash({rl2, 37*4},800, 0.12, 0.1)
)

local rl3 = {180.0,338600}

--- Songe 2
---
---
---
storyboard:newObject("sb/laplace.jpg", "Background", "TopLeft", -107, 210):add(
	{'scale', 0, { {rl3,0*4-1}, {rl3,0*4-1} }, 0.6675, 0.6675},
	{'moverel', 1, { {rl3,0*4-1.25}, {rl3,0*4} }, {0,0}, {0,10}},
	{'moverel', 1, { {rl3,0*4}, {rl3,2*4} }, {0,0}, {0,9}},
	{'fade', 1, { {rl3,0*4-1.25}, {rl3,0*4-0} }, 0.0, 0.5},
	{'fade', 1, { {rl3,2*4}, {rl3,2*4} }, 0, 0},
	Flash({rl3,225*4}, 600, 0.9, 0.1)
)

storyboard:newObject("sb/rem1.jpg", "Background", "TopLeft", -107, 229):add(
	{'scale', 0, { {rl3,8*4}, {rl3,8*4} }, 0.6675, 0.6675},
	{'fade', 1, { {rl3,7*4}, {rl3,7*4} }, 1, 1},
	{'fade', 1, { {rl3,17*4}, {rl3,17*4} }, 0, 0},
	{'fade', 1, { {rl3,47*4}, {rl3,47*4} }, 1, 1},
	{'fade', 1, { {rl3,75*4}, {rl3,75*4} }, 0, 0},
	{'fade', 1, { {rl3,105*4}, {rl3,105*4} }, 1, 1},
	{'fade', 1, { {rl3,126*4}, {rl3,126*4} }, 0, 0},
	{'fade', 1, { {rl3,131*4}, {rl3,131*4} }, 1, 1},
	{'fade', 1, { {rl3,142*4}, {rl3,142*4} }, 0,0},
	{'fade', 1, { {rl3,194*4-0.5}, {rl3,194*4} }, 0, 1},
	{'fade', 'quartIn', { {rl3,224*4}, {rl3,225*4+0.25} }, 1,0 }
)

storyboard:newObject("sb/rem2.jpg", "Background", "TopLeft", -107, 210):add(
	{'scale', 0, { {rl3,0*4-1}, {rl3,0*4-1} }, 0.6675, 0.6675},
	{'moverel', 1, { {rl3,0*4-1.25}, {rl3,0*4} }, {0,0}, {0,10}},
	{'moverel', 1, { {rl3,0*4}, {rl3,2*4} }, {0,0}, {0,9}},
	{'fade', 'quartIn', { {rl3,0*4-0.75}, {rl3,0.5} }, 0, 0.9},
	{'color', 'linear', { {rl3,0*4-0.75}, {rl3,4*2} }, {140,140,140}, {170,170,170}},
	{'color', 'linear', { {rl3,8}, {rl3,9} }, {170,170,170}, {215,215,215}},
	{'color', 'linear', { {rl3,16}, {rl3,17} }, {215,215,215}, {230,230,230}},
	{'fade', 'quartIn', { {rl3,8*4-0.6}, {rl3,8*4+0.1} }, 1, 0},
	{'fade', 1, { {rl3,16*4}, {rl3,16*4+4} }, 0, 1},
	{'fade', 'quartIn', { {rl3,48*4-0.5}, {rl3,48*4} }, 1, 0},
	{'fade', 1, { {rl3,74*4}, {rl3,74*4+2} }, 0, 1},
	{'fade', 'quartIn', { {rl3,106*4-0.5}, {rl3,106*4} }, 1, 0},


	{'fade',  1, { {rl3,124*4}, {rl3,124*4+2} }, 0, 1},
	{'color', 1, { {rl3,124*4}, {rl3,124*4+2} }, {180,180,180},{180,180,180}},
	{'color', 1, { {rl3,127*4+0.5}, {rl3,127*4+0.5} }, {130,130,130},{130,130,130}},
	{'color', 1, { {rl3,128*4}, {rl3,128*4+0.5} }, {130,130,130},{150,150,150}},
	{'color', 1, { {rl3,130*4}, {rl3,130*4+0.5} }, {150,150,150},{200,200,200}},
	{'color', 2, { {rl3,131*4+2}, {rl3,132*4} }, {200,200,200},{235,235,235}},
	{'fade', 'quartIn', { {rl3,132*4-0.5}, {rl3,132*4} }, 1, 0},

	{'fade',  1, { {rl3,174*4-0.25}, {rl3,174*4} }, 0, 1},
	{'fade',  'quartIn', { {rl3,190*4}, {rl3,191*4} }, 1,0.8},
	{'fade',  'In', { {rl3,194*4-0.5}, {rl3,194*4} }, 0.8,1}
)

storyboard:newObject("sb/rem2high.png", "Background", "TopLeft", -107, 210):add(
	{'scale', 0, { {rl3,0*4-1}, {rl3,0*4-1} }, 0.6675, 0.6675},
	{'moverel', 1, { {rl3,0*4-1.25}, {rl3,0*4} }, {0,0}, {0,10}},
	{'moverel', 1, { {rl3,0*4}, {rl3,2*4} }, {0,0}, {0,9}},
	{'fade', 'quartIn', { {rl3,0*4-0.75}, {rl3,0.5} }, 0, 0.7},
	{'fade', 'quartIn', { {rl3,8*4-0.6}, {rl3,8*4+0.1} }, 0.7, 0}
)

storyboard:newObject("sb/rem3.jpg", "Background", "TopLeft", -107, 229):add(
	{'scale', 0, { {rl3,140*4}, {rl3,140*4} }, 0.6675, 0.6675},
	{'fade', 2, { {rl3,140*4-0.5}, {rl3,140*4} }, 0, 1},
	{'fade', 2, { {rl3,149*4}, {rl3,149*4} }, 0, 0},


	{'fade', 2, { {rl3,156*4-0.5}, {rl3,156*4} }, 1, 1},
	{'fade', 2, { {rl3,165*4}, {rl3,165*4} }, 0, 0}
)

storyboard:newObject("sb/rem3.jpg", "Foreground", "TopLeft", -107, 229):add(
	{'scale', 0, { {rl3,156*4}, {rl3,156*4} }, 0.6675, 0.6675},
	{'protract', {'parameter', { {rl3, 156*4}, {rl3, 156*4} }, value='a'}},
	Flash({rl3,156*4}, 1600, 0.3, 0.08),
	Flash({rl3,160*4}, 1600, 0.2, 0.08)
)
storyboard:newObject("sb/rem4.jpg", "Background", "TopLeft", -107, 229):add(
	{'scale', 0, { {rl3,148*4}, {rl3,148*4} }, 0.6675, 0.6675},
	{'fade', 2, { {rl3,148*4-0.5}, {rl3,148*4} }, 0, 1},
	{'fade', 2, { {rl3,156*4-0.5}, {rl3,156*4} }, 1, 0},
	{'fade', 2, { {rl3,164*4-0.5}, {rl3,164*4} }, 0, 1},

	{'fade', 0, { {rl3,173*4}, {rl3,174*4-0.25} }, 1, 0.9},
	{'fade', 2, { {rl3,174*4-0.25}, {rl3,174*4+0.25} }, 0.9, 0}
)

storyboard:newObject("sb/rem4.jpg", "Foreground", "TopLeft", -107, 229):add(
	{'scale', 0, { {rl3,164*4}, {rl3,164*4} }, 0.6675, 0.6675},
	{'protract', {'parameter', { {rl3, 164*4}, {rl3, 164*4} }, value='a'}},
	Flash({rl3,164*4}, 1600, 0.3, 0.08),
	Flash({rl3,168*4}, 1600, 0.2, 0.08),
	Flash({rl3,172*4}, 1600, 0.2, 0.08)
)

storyboard:newObject("sb/remFlash.jpg", "Foreground", "TopLeft", -107, 210):add(
	{'scale', 0, { {rl3, 8}, {rl3, 8} }, 0.6675, 0.6675},
	{'moverel', 1, { {rl3,0*4-1.25}, {rl3,0*4} }, {0,0}, {0,10}},
	{'moverel', 1, { {rl3,0*4}, {rl3,2*4} }, {0,0}, {0,9}},
	{'protract', {'parameter', { {rl3, 8}, {rl3, 8} }, value='a'}},
	Flash({rl3,8}, 1200, 0.25, 0.08),
	Flash({rl3,16}, 1200, 0.25, 0.08),
	Flash({rl3,24}, 1200, 0.12, 0.08),
	Flash({rl3,7*4}, 800, 0.09, 0.12),
	Flash({rl3,8*4}, 800, 0.15, 0.12),
	Flash({rl3,16*4}, 800, 0.15, 0.12),
	Flash({rl3,24*4}, 800, 0.15, 0.12),
	Flash({rl3,32*4}, 800, 0.13, 0.12),
	Flash({rl3,40*4}, 800, 0.13, 0.12),
	Flash({rl3,48*4}, 1200, 0.18, 0.08),
	Flash({rl3,56*4}, 1200, 0.18, 0.08),
	Flash({rl3,60*4}, 1200, 0.18, 0.08),
	Flash({rl3,64*4}, 1200, 0.18, 0.08),
	Flash({rl3,66*4}, 1200, 0.18, 0.08),
	Flash({rl3,74*4}, 800, 0.15, 0.05),
	Flash({rl3,82*4}, 1200, 0.12, 0.08),
	Flash({rl3,90*4}, 1200, 0.15, 0.08),
	Flash({rl3,94*4}, 1200, 0.12, 0.08),
	Flash({rl3,98*4}, 1200, 0.15, 0.08),

	Flash({rl3,106*4}, 1200, 0.18, 0.08),
	Flash({rl3,114*4}, 1200, 0.18, 0.08),
	Flash({rl3,118*4}, 1200, 0.18, 0.08),
	Flash({rl3,122*4}, 1200, 0.18, 0.08),
	Flash({rl3,124*4}, 2400, 0.24, 0.08),
	Flash({rl3,126*4}, 2400, 0.24, 0.08),
	Flash({rl3,128*4}, 2400, 0.24, 0.08),
	Flash({rl3,130*4}, 1200, 0.18, 0.08),
	Flash({rl3,131*4}, 800, 0.15, 0.1),
	Flash({rl3,132*4}, 1200, 0.18, 0.08),
	Flash({rl3,140*4}, 1200, 0.15, 0.08),
	Flash({rl3,174*4}, 1200, 0.25, 0.08),
	Flash({rl3,182*4}, 1200, 0.15, 0.08),
	Flash({rl3,190*4}, 1200, 0.25, 0.08),
	Flash({rl3,191*4}, 1200, 0.18, 0.08),
	Flash({rl3,192*4}, 1200, 0.18, 0.08),
	Flash({rl3,193*4}, 1200, 0.18, 0.08),
	Flash({rl3,194*4}, 1200, 0.18, 0.08),
	Flash({rl3,198*4}, 1200, 0.18, 0.08),
	Flash({rl3,199*4}, 1200, 0.05, 0.15),
	Flash({rl3,200*4}, 1200, 0.05, 0.15),
	Flash({rl3,201*4}, 1200, 0.05, 0.15),
	Flash({rl3,202*4}, 1200, 0.15, 0.08),
	Flash({rl3,203*4}, 1200, 0.05, 0.15),
	Flash({rl3,204*4}, 1200, 0.05, 0.15),
	Flash({rl3,205*4}, 1200, 0.05, 0.15),
	Flash({rl3,206*4}, 1200, 0.15, 0.08),
	Flash({rl3,207*4}, 800, 0.07, 0.1),
	Flash({rl3,208*4}, 800, 0.07, 0.1),
	Flash({rl3,209*4}, 800, 0.07, 0.1),
	Flash({rl3,210*4}, 1200, 0.15, 0.08),
	Flash({rl3,214*4}, 1200, 0.15, 0.08),
	Flash({rl3,216*4}, 1200, 0.15, 0.08),
	Flash({rl3,224*4}, 1200, 0.34, 0.08),
	Flash({rl3,225*4+0.5}, 1800, 1.0, 0.1)
)

storyboard:newObject("sb/rem2.jpg", "Foreground", "TopLeft", -107, 229):add(
	{'scale', 0, { {rl3, 12}, {rl3, 12} }, 0.6675, 0.6675},
	{'color', 0, { {rl3, 12}, {rl3, 12} }, {125,125,125},{125,125,125}},
	Flash({rl3,12}, 1800, 0.25, 0.2),
	Flash({rl3,46*4}, 300, 0.20, 0.15),
	Flash({rl3,46*4+1}, 300, 0.20, 0.15),
	Flash({rl3,46*4+2}, 300, 0.20, 0.15),
	Flash({rl3,46*4+3}, 300, 0.20, 0.15),
	Flash({rl3,46*4+4}, 300, 0.20, 0.15),
	Flash({rl3,46*4+5}, 300, 0.20, 0.15),
	Flash({rl3,46*4+6}, 300, 0.20, 0.15),
	Flash({rl3,46*4+7}, 300, 0.20, 0.15),

	Flash({rl3,104*4}, 300, 0.20, 0.15),
	Flash({rl3,104*4+1}, 300, 0.20, 0.15),
	Flash({rl3,104*4+2}, 300, 0.20, 0.15),
	Flash({rl3,104*4+3}, 300, 0.20, 0.15),
	Flash({rl3,104*4+4}, 300, 0.20, 0.15),
	Flash({rl3,104*4+5}, 300, 0.20, 0.15),
	Flash({rl3,104*4+6}, 300, 0.20, 0.15),
	Flash({rl3,104*4+7}, 300, 0.20, 0.15),
	Flash({rl3,173*4}, 600, 0.18, 0.16),

	Flash({rl3,188*4}, 300, 0.20, 0.15),
	Flash({rl3,188*4+1}, 300, 0.20, 0.15),
	Flash({rl3,188*4+2}, 300, 0.20, 0.15),
	Flash({rl3,188*4+3}, 300, 0.20, 0.15),
	Flash({rl3,188*4+4}, 300, 0.20, 0.15),
	Flash({rl3,188*4+5}, 300, 0.20, 0.15),
	Flash({rl3,188*4+6}, 300, 0.20, 0.15),
	Flash({rl3,188*4+7}, 300, 0.20, 0.15)
)

storyboard:newObject("sb/laplace.jpg", "Foreground", "TopLeft", -107, 229):add(
	{'scale', 0, { {rl3, 127*4}, {rl3, 127*4} }, 0.6675, 0.6675},
	Flash({rl3,127*4}, 2800, 1.0, 0.05))

storyboard:newObject("sb/180bpm.png", "Foreground", "Centre", 318, 446):add(
	{'fade', 1, { {rl3,2+22}, {rl3,5+22} }, 0   ,1.0 },
	{'scale',0, { {rl3,2+22}, {rl3,5+22} }, 0.34,0.34 },
	{'fade', 0, { {rl3,223*4}, {rl3,227*4} }, 1,0 }
)

storyboard:newObject("sb/m_r.png", "Foreground", "Centre", 242, 290):add(
	{'moverel', 1, { {rl3,4}, {rl3,4.5} }, {0, 0}, {33,0}},
	{'moverel', 0, { {rl3,4.5}, {rl3,5} }, {0, 0}, {17,0}},
	{'moverel', 1, { {rl3,5}, {rl3,25+5} }, {0, 0}, {24,0}},
	{'fade', 1, { {rl3,4}, {rl3,6} }, 0   ,1.0 },
	{'scale',0, { {rl3,4}, {rl3,6} }, 0.49,0.49 },
	{'fade', 0, { {rl3,33-1.4}, {rl3,35-1.4} }, 1.0,0 }
)

storyboard:newObject("sb/eastern_dream.png", "Foreground", "Centre", 385, 347):add(
	{'moverel', 1, { {rl3,4+8}, {rl3,5.5+8} }, {0, 0}, {-43,0}},
	{'moverel', 0, { {rl3,5.5+8}, {rl3,7.2+8} }, {0, 0}, {-9,0}},
	{'moverel', 1, { {rl3,7.2+8}, {rl3,29+8} }, {0, 0}, {-18,0}},
	{'fade', 1, { {rl3,4+8}, {rl3,7+8} }, 0   ,1.0 },
	{'scale',0, { {rl3,4+8}, {rl3,4+8} }, 0.41,0.41 },
	{'fade', 0, { {rl3,34.15-2.0}, {rl3,36.15-2.0} }, 1.0,0 }
)

storyboard:newObject("sb/r0203.png", "Foreground", "Centre", 320, 347):add(
	{'fade', 1, { {rl3,4*8+0.5}, {rl3,5*8} }, 0   ,1.0 },
	{'scale',0, { {rl3,4*8}, {rl3,4*8} }, 0.41,0.41 },
	{'fade',0, { {rl3,11*4+0.5}, {rl3,12*4} }, 1.0, 0 }
)

storyboard:newObject("sb/eosd_.png", "Foreground", "Centre", 253, 402):add(
	{'moverel', 1, { {rl3,2+15}, {rl3,3.5+15} }, {0, 0}, {35,0}},
	{'moverel', 0, { {rl3,3.5+15}, {rl3,5.2+15} }, {0, 0}, {7,0}},
	{'moverel', 1, { {rl3,5.2+15}, {rl3,23+8} }, {0, 0}, {16,0}},
	{'fade', 1, { {rl3,2+15}, {rl3,5+15} }, 0   ,1.0 },
	{'scale',0, { {rl3,2+15}, {rl3,2+15} }, 0.27,0.27 },
	{'fade', 0, { {rl3,32.3-0.6}, {rl3,34.3-0.6} }, 1.0,0 }
)

---
--- Songe 3
---
---
---

local rl4={190.0, 643537}

local rl4_moveIn = {
	{'move', 'linear', { {rl4,0}, {rl4,0} }, {-107,242}, {-107,242}},
	{'moverel', 'quartOut', { {rl4,0}, {rl4,1.5} }, {0,0}, {0,-30}},
	{'moverel', 'linear', {{rl4,0.75}, {rl4,8}}, {0,0}, {0,-18}},
	{'moverel', 'out', {{rl4,8}, {rl4,6*4}}, {0,0}, {0,-12}}
}

local LLLL = 34
local rl4_int_move = {
	{'move', 'linear', { {rl4,LLLL*4}, {rl4,LLLL*4} }, {-107,242}, {-107,183}},
	{'moverel', 'sineIn',  { {rl4,LLLL*4-1}, {rl4,(LLLL+4)*4} }, {0,0},{0,22} },
	{'moverel', 'linear',  { {rl4,(LLLL+3)*4}, {rl4,(LLLL+5)*4} }, {0,0},{0,12} },
	{'moverel', 'out',  { {rl4,(LLLL+4)*4}, {rl4,(LLLL+8)*4} }, {0,0},{0,-4} },
	{'moverel', 'linear',  { {rl4,(LLLL+8)*4}, {rl4,(LLLL+13)*4} }, {0,0},{0,-16} },
	{'moverel', 'in',  { {rl4,(LLLL+5)*4}, {rl4,(LLLL+16)*4} }, {0,0},{0,-24} },
	{'moverel', 'linear',  { {rl4,(LLLL+12)*4}, {rl4,(LLLL+16)*4} }, {0,0},{0,-16} },
}

local LLLL2 = 90
local rl4_int_move2 = {
	{'move', 'linear', { {rl4,LLLL2*4}, {rl4,LLLL2*4} }, {-107,242}, {-107,183}},
	{'moverel', 'sineIn',  { {rl4,LLLL2*4-1}, {rl4,(LLLL2+4)*4} }, {0,0},{0,22} },
	{'moverel', 'linear',  { {rl4,(LLLL2+3)*4}, {rl4,(LLLL2+5)*4} }, {0,0},{0,12} },
	{'moverel', 'out',  { {rl4,(LLLL2+4)*4}, {rl4,(LLLL2+8)*4} }, {0,0},{0,-4} },
	{'moverel', 'linear',  { {rl4,(LLLL2+8)*4}, {rl4,(LLLL2+13)*4} }, {0,0},{0,-16} },
	{'moverel', 'in',  { {rl4,(LLLL2+5)*4}, {rl4,(LLLL2+16)*4} }, {0,0},{0,-24} },
	{'moverel', 'linear',  { {rl4,(LLLL2+12)*4}, {rl4,(LLLL2+16)*4} }, {0,0},{0,-16} },
}

local rl4_flashes = {

}
for i=10*4+1,16*4-1, 1 do
	table.insert(rl4_flashes, Flash({rl4, i}, 280, 0.11, 0.1))
end

for i=150*4+1,156*4-1, 1 do
	if i~=150*4 or i~=154*4 or i~=158*4 then
		table.insert(rl4_flashes, Flash({rl4, i}, 280, 0.11, 0.1))
	end
end

for i=75*4+1,83*4-1, 1 do
	table.insert(rl4_flashes, Flash({rl4, i}, 280, 0.11, 0.1))
end


local rl4_chain_flashes = {}
	table.insert(rl4_chain_flashes, Flash({rl4, 18*4+1}, 300, 0.14, 0.25))
for i=18*4+2,26*4-1, 1 do
	table.insert(rl4_chain_flashes, Flash({rl4, i}, 300, 0.22, 0.25))
end

for i=158*4+2,166*4-1, 1 do
	table.insert(rl4_chain_flashes, Flash({rl4, i}, 300, 0.22, 0.25))
end

for i=51*4+1,67*4-1, 1 do
	table.insert(rl4_chain_flashes, Flash({rl4, i}, 300, 0.22, 0.25))
end

for i=108*4+1,124*4-1, 1 do
	table.insert(rl4_chain_flashes, Flash({rl4, i}, 300, 0.22, 0.25))
end

for i=174*4+1,182*4-1, 1 do
	table.insert(rl4_chain_flashes, Flash({rl4, i}, 300, 0.22, 0.25))
end

local rl4_black_flashes = {}
for i=26*4+1,32*4-1, 1 do
	table.insert(rl4_black_flashes, Flash({rl4, i}, 300, 0.15, 0.25))
end

for i=166*4+1,172*4-1, 1 do
	table.insert(rl4_black_flashes, Flash({rl4, i}, 300, 0.15, 0.25))
end

for i=182*4+1,190*4-1, 1 do
	table.insert(rl4_black_flashes, Flash({rl4, i}, 300, 0.15, 0.25))
end

for i=46*4+0.5,50*4-0.5, 0.5 do
	table.insert(rl4_black_flashes, Flash({rl4, i}, 140, 0.13, 0.33))
end

for i=83*4+1,91*4-1, 1 do
	table.insert(rl4_black_flashes, Flash({rl4, i}, 140, 0.15, 0.25))
end

for i=103*4+0.5,107*4-0.5, 0.5 do
	table.insert(rl4_black_flashes, Flash({rl4, i}, 140, 0.13, 0.33))
end

local rl4_inst_f = {}
for i=132*4+2,132*4-0.5+4, 0.5 do
	table.insert(rl4_inst_f, FlashFloor({rl4,i},79*2-1, 0.45, 0.5, 0.1))
end
for i=134*4+2,134*4-0.5+4, 0.5 do
	table.insert(rl4_inst_f, FlashFloor({rl4,i},79*2-1, 0.45, 0.5, 0.1))
end
for i=136*4+2,136*4-0.5+4, 0.5 do
	table.insert(rl4_inst_f, FlashFloor({rl4,i},79*2-1, 0.45, 0.5, 0.1))
end
for i=138*4+2,138*4-0.5+4, 0.5 do
	table.insert(rl4_inst_f, FlashFloor({rl4,i},79*2-1, 0.45, 0.5, 0.1))
end

storyboard:newObject("sb/HecatiaS.jpg", "Background", "TopLeft", -107, 242):add(
	{'scale',0, { {rl4,0},{rl4,0}}, 0.667, 0.667},
	{'fade',0,  {  {rl4,0},{rl4,0.5}}, 0, 1},
	{'fade',0,  {  {rl4,9},{rl4,9}}, 0, 0},

	sb.concadd(rl4_moveIn)
)

storyboard:newObject("sb/Hecatia.jpg", "Background", "TopLeft", -107, 242):add(
	{'scale',0, { {rl4,0},{rl4,0}}, 0.667, 0.667},
	{'fade','linear',  {  {rl4,0},{rl4,0}}, 0.3, 0.3},
	{'fade','out',  {  {rl4,1.5},{rl4,1.5+0.5}}, 0.3, 0.9},
	{'fade','out',  {  {rl4,2},{rl4,3}}, 0.9, 0.4},
	{'fade','out',  {  {rl4,3},{rl4,3.5}}, 0.4, 0.8},
	{'fade','circIn',  {  {rl4,3.5},{rl4,8}}, 0.8, 1},
	{'color','quartOut',  {  {rl4,8},{rl4,9}}, {255,255,255},{230,230,230}},
	{'fade',0,  {  {rl4,11*4},{rl4,11*4}}, 0, 0},


	{'fade',0,  {  {rl4,140*4-0.5},{rl4,140*4-0.5}}, 1, 1},
	{'color',0,  {  {rl4,140*4-0.5},{rl4,140*4-0.5}}, {220,220,230},{220,220,220}},
	{'color',0,  {  {rl4,142*4-0.5},{rl4,142*4}}, {220,220,220},{255,255,255}},
	{'fade',0,  {  {rl4,150*4},{rl4,150*4}}, 0, 0},

	--{'fade' ,'linear', { {rl4,34*4-0.5},{rl4,34*4}}, 1, 1},
	sb.concadd(rl4_moveIn)
)

storyboard:newObject("sb/HecatiaInst1.jpg", "Background", "TopLeft", -107, 242):add(
	{'scale',0, { {rl4,34*4-0.5},{rl4,34*4-0.5}}, 0.667, 0.667},
	{'fade' ,'linear', { {rl4,34*4-0.5},{rl4,34*4-0.5}}, 1, 1},
	{'fade' ,'quintOut', { {rl4,50*4-0.5},{rl4,50*4+0.5}}, 1, 0},

	{'fade' ,'linear', { {rl4,91*4-0.5},{rl4,91*4-0.5}}, 1, 1},
	{'fade' ,'quintOut', { {rl4,107*4-0.5},{rl4,107*4+0.5}}, 1, 0},
	sb.concadd(rl4_int_move, rl4_int_move2)
)

storyboard:newObject("sb/HecatiaK.jpg", "Background", "TopLeft", -107, 182):add(
	{'scale',0, { {rl4,10*4-0.5},{rl4,10*4}}, 0.667, 0.667},
	{'fade' ,2, { {rl4,10*4-0.5},{rl4,10*4}}, 0, 1},
	{'fade' ,'quintIn', { {rl4,34*4-0.5},{rl4,34*4}}, 1, 0},
	{'fade' ,2, { {rl4,51*4-0.5},{rl4,51*4}}, 0, 1},
	{'fade' ,'quintIn', { {rl4,67*4-0.5},{rl4,67*4}}, 1, 0},

	{'fade' ,2, { {rl4,75*4-0.5},{rl4,75*4}}, 0, 1},
	{'fade' ,'quintOut', { {rl4,91*4-0.5},{rl4,91*4}}, 1, 0},

	{'fade' ,2, { {rl4,108*4-0.5},{rl4,108*4}}, 0, 1},
	{'fade' ,'quintIn', { {rl4,124*4-0.5},{rl4,124*4}}, 1, 0},

	{'fade' ,2, { {rl4,150*4-0.5},{rl4,150*4}}, 0, 1},
	{'fade' ,'cubicOut', { {rl4,192*4},{rl4,196*4}}, 1, 0}
)

storyboard:newObject("sb/Stars1.jpg", "Background", "Centre", 320, 353):add(
	{'scale', 'in', {{rl4,71*4}, {rl4,75*4}}, 1, 1.2},
	{'fade', 'cubicOut', {{rl4,71*4}, {rl4,71*4}}, 1, 1},
	{'fade', 'cubicOut', {{rl4,75*4-1}, {rl4,75*4}}, 1, 0}
)
storyboard:newObject("sb/Stars3.jpg", "Background", "Centre", 320, 353):add(
	{'scale', 'linear', {{rl4,124*4}, {rl4,124*4}}, 0.667, 0.667},
	{'fade', 'cubicOut', {{rl4,124*4}, {rl4,125*4}}, 0, 1},
	{'fade', 'cubicOut', {{rl4,133*4}, {rl4,133*4}}, 0}
)

storyboard:newObject("sb/Stars2.jpg", "Background", "Centre", 320, 353):add(
	{'fade', 'cubicOut', {{rl4,68*4}, {rl4,71*4-0.5}}, 0, 1},
	{'scale', 'SineOut', {{rl4,68*4}, {rl4,71*4}}, 1.2, 1},
	{'fade', 'cubicOut', {{rl4,71*4-0.5}, {rl4,71*4+0.5}}, 1, 0}
)

storyboard:newObject("sb/Moon.png", "Foreground", "Centre", 320, 353):add(
	{'protract', {'parameter', { {rl4, 71*4}, {rl4, 71*4} }, value='a'}},
	{'move', 'in', {{rl4,71*4}, {rl4,71*4}}, {320,353}},
	{'fade', 0, {{rl4,71*4}, {rl4,71*4}}, 0,0},
	{'scale', 'in', {{rl4,71*4}, {rl4,75*4}}, 0.528, 0.9},
	--Flash({rl4,71*4      }, 600, 1.5, 0.1),
	--Flash({rl4,71*4 + 2*1}, 600, 0.5, 0.1),
	Flash({rl4,71*4 + 2*2}, 600, 0.5, 0.1),
	--Flash({rl4,71*4 + 2*3}, 600, 0.5, 0.1),
	Flash({rl4,71*4 + 2*4}, 600, 0.5, 0.1),
	--Flash({rl4,71*4 + 2*5}, 600, 0.5, 0.1),
	Flash({rl4,71*4 + 2*6}, 600, 0.5, 0.1),
	{'scale', 'in', {{rl4,126*4}, {rl4,126*4}}, 0.57},
	{'move', 'in', {{rl4,126*4}, {rl4,126*4}}, {320,339}},
	Flash({rl4, 126*4}, 1200, 0.9, 0.1)
	--Flash({rl4,71*4 + 2*7}, 600, 0.5, 0.1)
	--{'fade', 'cubicOut', {{rl4,71*4-0.5}, {rl4,71*4+0.5}}, 0, 1},
	--{'fade', 'cubicOut', {{rl4,75*4}, {rl4,75*4}}, 0, 0}
)

storyboard:newObject("sb/Moon.png", "Background", "Centre", 320, 353):add(
	{'color', 'linear', {{rl4,71*4-0.5}, {rl4,71*4-0.5}}, {255,0,0},{255,0,0}},
	{'scale', 'in', {{rl4,71*4-0.5}, {rl4,75*4}}, 0.528, 0.9},
	{'fade', 'cubicOut', {{rl4,71*4-0.5}, {rl4,71*4+0.5}}, 0, 1},
	{'fade', 'cubicOut', {{rl4,75*4-1}, {rl4,75*4}}, 1, 0}
)

storyboard:newObject("sb/Globe1.png", "Background", "Centre", 320, 353):add(
	{'fade', 'cubicout', {{rl4,68*4}, {rl4,68*4}}, 1, 1},
	{'scale', 'sineout', {{rl4,68*4}, {rl4,71*4}}, 0.8, 0.66},
	{'color', 'cubicIn', {{rl4,68*4}, {rl4,71*4-0.5}}, {0,0,0}, {244,244,244}},
	{'color', 'linear', {{rl4,71*4-0.5}, {rl4,71*4+0.5}}, {255,255,255}, {255,0,0}},
	{'fade', 'cubicOut', {{rl4,71*4-0.5}, {rl4,71*4+0.5}}, 1, 0}
)

storyboard:newObject("sb/HecatiaInst2.jpg", "Background", "TopLeft", -107, 182):add(
	{'scale',0, { {rl4,132*4-0.5},{rl4,132*4-0.5}}, 0.667, 0.667},
	{'fade' ,'cubicOut', { {rl4,132*4-0.5},{rl4,132*4+2.5}}, 0, 1},
	{'fade' ,'cubicOut', { {rl4,140*4-0.5},{rl4,140*4}}, 1, 0}
)

-- kiai inst1
storyboard:newObject("sb/HecatiaInst1.jpg", "Background", "TopLeft", -107, 182):add(
	{'scale',0, { {rl4,57*4-0.5},{rl4,57*4-0.5}}, 0.667, 0.667},

	{'fade' ,'cubicIn', { {rl4,57*4-0.5},{rl4,57*4+0.5}}, 0, 1},
	{'fade' ,'quintOut', { {rl4,59*4-0.5},{rl4,59*4+0.5}}, 1, 0},

	{'fade' ,'cubicIn', { {rl4,65*4-0.5},{rl4,65*4+0.5}}, 0, 1},
	{'fade' ,'quintOut', { {rl4,67*4},{rl4,67*4}}, 1, 0},


	{'fade' ,'cubicIn', { {rl4,114*4-0.5},{rl4,114*4+0.5}}, 0, 1},
	{'fade' ,'quintOut', { {rl4,116*4-0.5},{rl4,116*4+0.5}}, 1, 0},

	{'fade' ,'cubicIn', { {rl4,122*4-0.5},{rl4,122*4+0.5}}, 0, 1},
	{'fade' ,'quintOut', { {rl4,124*4},{rl4,124*4}}, 1, 0},

	{'fade' ,'cubicIn', { {rl4,180*4-0.5},{rl4,180*4+0.5}}, 0, 1},
	{'fade' ,'quintOut', { {rl4,182*4-0.5},{rl4,182*4+0.5}}, 1, 0},
	
	{'fade' ,'cubicIn', { {rl4,188*4-0.5},{rl4,188*4+0.5}}, 0, 1},
	{'fade' ,'quintOut', { {rl4,190*4-0.5},{rl4,190*4+0.5}}, 1, 0},

	sb.concadd(rl4_inst_f)
)

storyboard:newObject("sb/Chains2.png", "Background", "TopLeft", -107, 182):add(
	{'fade' ,2, { {rl4,10*4-1},{rl4,10*4}}, 0, 1},
	{'fade' ,'quintIn', { {rl4,34*4-0.5},{rl4,34*4}}, 1, 0},

	{'fade' ,2, { {rl4,51*4-0.5},{rl4,51*4}}, 0, 1},
	{'fade' ,'out', { {rl4,67*4-0.5},{rl4,67*4+1}}, 1, 0},

	{'fade' ,2, { {rl4,108*4-0.5},{rl4,108*4}}, 0, 1},
	{'fade' ,'out', { {rl4,124*4-0.5},{rl4,124*4+1}}, 1, 0},

	{'fade' ,2, { {rl4,150*4-1},{rl4,150*4}}, 0, 1},
	{'fade' ,'cubicOut', { {rl4,192*4},{rl4,196*4}}, 1, 0}
)

storyboard:newObject("sb/HecatiaFlash.png", "Background", "TopLeft", -107, 242):add(
	{'protract', {'parameter', { {rl1, 0}, {rl1, 0} }, value='a'}},

	Flash({rl4,0}, 500, 0.4, 0.15),
	Flash({rl4,3}, 350, 0.4, 0.15),
	Flash({rl4,4.5}, 450, 0.4, 0.15),
	Flash({rl4,6}, 300, 0.3, 0.1),
	Flash({rl4,7}, 300, 0.3, 0.1),
	Flash({rl4,2*4}, 1200, 0.4, 0.1),
	Flash({rl4,4*4}, 1200, 0.4, 0.1),
	Flash({rl4,7*4}, 800, 0.1, 0.15),
	Flash({rl4,8*4}, 800, 0.25, 0.1),
	Flash({rl4,8*4+3}, 400, 0.25, 0.1),
	Flash({rl4,9*4+0.5}, 280, 0.18, 0.1),
	Flash({rl4,9*4+1.5}, 280, 0.18, 0.1),
	Flash({rl4,10*4}, 300, 0.25, 0.1),
	Flash({rl4,16*4}, 800, 0.25, 0.1),
	Flash({rl4,18*4}, 1200, 0.25, 0.1),
	Flash({rl4,26*4}, 1200, 0.3, 0.1),
	Flash({rl4,30*4}, 1200, 0.3, 0.1),
	Flash({rl4,34*4}, 1200, 0.4, 0.1),
	Flash({rl4,42*4}, 1200, 0.4, 0.1),
	Flash({rl4,46*4}, 800, 0.25, 0.1),

	{'move', 0, {{rl4,51*4}, {rl4,51*4}}, {-107,182}},
	{'move', 0, {{rl4,108*4}, {rl4,108*4}}, {-107,182}},

	Flash({rl4,51*4 + 4*2*0}, 1200, 0.35, 0.1),
	Flash({rl4,51*4 + 4*2*1}, 1200, 0.2, 0.1),
	Flash({rl4,51*4 + 4*2*2}, 1200, 0.35, 0.1),
	Flash({rl4,51*4 + 4*2*3}, 1200, 0.35, 0.1),
	Flash({rl4,51*4 + 4*2*4}, 1200, 0.35, 0.1),
	Flash({rl4,51*4 + 4*2*5}, 1200, 0.2, 0.1),
	Flash({rl4,51*4 + 4*2*6}, 1200, 0.2, 0.1),
	Flash({rl4,51*4 + 4*2*7}, 1200, 0.35, 0.1),
	Flash({rl4,51*4 + 4*2*8}, 1200, 0.35, 0.1),

	Flash({rl4,75*4}, 300, 0.35, 0.25),
	Flash({rl4,83*4}, 300, 0.35, 0.25),

	Flash({rl4,91*4}, 1200, 0.4, 0.1),
	Flash({rl4,95*4}, 1200, 0.4, 0.1),
	Flash({rl4,99*4}, 1200, 0.4, 0.1),
	Flash({rl4,103*4}, 1200, 0.4, 0.1),


	Flash({rl4,108*4 + 4*2*0}, 1200, 0.35, 0.1),
	Flash({rl4,108*4 + 4*2*1}, 1200, 0.2, 0.1),
	Flash({rl4,108*4 + 4*2*2}, 1200, 0.35, 0.1),
	Flash({rl4,108*4 + 4*2*3}, 1200, 0.35, 0.1),
	Flash({rl4,108*4 + 4*2*4}, 1200, 0.35, 0.1),
	Flash({rl4,108*4 + 4*2*5}, 1200, 0.2, 0.1),
	Flash({rl4,108*4 + 4*2*6}, 1200, 0.2, 0.1),
	Flash({rl4,108*4 + 4*2*7}, 1200, 0.35, 0.1),
	Flash({rl4,108*4 + 4*2*8}, 1200, 0.35, 0.1),


	Flash({rl4,132*4 }, 1200, 0.20, 0.1),
	Flash({rl4,136*4 }, 1200, 0.35, 0.1),
	Flash({rl4,139*4 }, 800, 0.25, 0.1),
	Flash({rl4,140*4 }, 1200, 0.35, 0.1),

	Flash({rl4,142*4 }, 1200, 0.35, 0.1),
	Flash({rl4,144*4 }, 1200, 0.35, 0.1),
	Flash({rl4,146*4 }, 1200, 0.35, 0.1),
	Flash({rl4,148*4 }, 1200, 0.35, 0.1),
	Flash({rl4,150*4 }, 300, 0.4, 0.25),
	Flash({rl4,158*4 }, 300, 0.35, 0.25),
	Flash({rl4,164*4 }, 1200, 0.35, 0.1),
	Flash({rl4,166*4 }, 1200, 0.35, 0.1),
	Flash({rl4,172*4 }, 1200, 0.35, 0.1),
	Flash({rl4,174*4 }, 1200, 0.35, 0.1),
	Flash({rl4,178*4 }, 1200, 0.35, 0.1),
	Flash({rl4,180*4 }, 1200, 0.35, 0.1),
	Flash({rl4,182*4 }, 1200, 0.35, 0.1),
	Flash({rl4,186*4 }, 1200, 0.35, 0.1),
	Flash({rl4,188*4 }, 1200, 0.35, 0.1),
	Flash({rl4,192*4 }, 2400, 0.45, 0.067),

	sb.concadd(rl4_moveIn, rl4_flashes, rl4_int_move, rl4_int_move2)
)
storyboard:newObject("sb/ChainsFlash.png", "Background", "TopLeft", -107, 182):add(
	sb.concadd(rl4_chain_flashes)
)

storyboard:newObject("sb/Black.jpg", "Foreground", "BottomLeft", -106.7, 480):add(
	Flash({rl4, 6*4 },2500, 0.42, 0.1),
	Flash({rl4, 8*4+1.5 },600, 0.19, 0.1),
	Flash({rl4, 147*4 },2500, 0.42, 0.1),
	sb.concadd(rl4_black_flashes)
)

storyboard:newObject("sb/Ch1.png", "Background", "TopLeft", -107+37, 182):add(
	{'fade' ,'in', { {rl4,50*4-0.5},{rl4,50*4}}, 0, 1},
	{'fade' ,'linear', { {rl4,51*4},{rl4,51*4}}, 0, 0},

	{'fade' ,'in', { {rl4,107*4-0.5},{rl4,107*4}}, 0, 1},
	{'fade' ,'linear', { {rl4,108*4},{rl4,108*4}}, 0, 0},

	{'parameter', {{rl4, 128*4}, {rl4, 132*4}}, value='a'},
	Flash({rl4, 128*4}, 1200, 0.9, 0.1)
)
storyboard:newObject("sb/Ch2.png", "Background", "TopLeft", -107+571, 182):add(
	{'fade' ,'in', { {rl4,50*4-0.5+2},{rl4,50*4+2}}, 0, 1},
	{'fade' ,'linear', { {rl4,51*4},{rl4,51*4}}, 0, 0},

	{'fade' ,'in', { {rl4,107*4-0.5+2},{rl4,107*4+2}}, 0, 1},
	{'fade' ,'linear', { {rl4,108*4},{rl4,108*4}}, 0, 0},

	{'parameter', {{rl4, 126*4}, {rl4, 132*4}}, value='a'},
	Flash({rl4, 130*4}, 1200, 0.9, 0.1)
)

local rl4_text={190.0, 646063}

storyboard:newObject("sb/n_w_o.png", "Foreground", "Centre", 242, 296):add(
	{'moverel', 1, { {rl4_text,3}, {rl4_text,3.5} }, {0, 0}, {33,0}},
	{'moverel', 0, { {rl4_text,3.5}, {rl4_text,4} }, {0, 0}, {17,0}},
	{'moverel', 1, { {rl4_text,4}, {rl4_text,25+4} }, {0, 0}, {24,0}},
	{'fade', 1, { {rl4_text,3}, {rl4_text,5} }, 0   ,0.9 },
	{'scale',0, { {rl4_text,3}, {rl4_text,3} }, 0.51,0.51 },
	{'fade', 0, { {rl4_text,32-0.5}, {rl4_text,34-0.5} }, 0.9,0 }
)

storyboard:newObject("sb/pandemonic_planet.png", "Foreground", "Centre", 385, 344):add(
	{'moverel', 1, { {rl4_text,2+8}, {rl4_text,3.5+8} }, {0, 0}, {-43,0}},
	{'moverel', 0, { {rl4_text,3.5+8}, {rl4_text,5.2+8} }, {0, 0}, {-9,0}},
	{'moverel', 1, { {rl4_text,5.2+8}, {rl4_text,26+8} }, {0, 0}, {-18,0}},
	{'fade', 1, { {rl4_text,2+8}, {rl4_text,5+8} }, 0   ,0.9 },
	{'scale',0, { {rl4_text,2+8}, {rl4_text,2+8} }, 0.49,0.49 },
	{'fade', 0, { {rl4_text,32.15-0.6}, {rl4_text,34.15-0.6} }, 0.9,0 }
)

storyboard:newObject("sb/lunatic.png", "Foreground", "Centre", 253, 386):add(
	{'moverel', 1, { {rl4_text,2+15}, {rl4_text,3.5+15} }, {0, 0}, {35,0}},
	{'moverel', 0, { {rl4_text,3.5+15}, {rl4_text,5.2+15} }, {0, 0}, {7,0}},
	{'moverel', 1, { {rl4_text,5.2+15}, {rl4_text,23+8} }, {0, 0}, {16,0}},
	{'fade', 1, { {rl4_text,2+15}, {rl4_text,5+15} }, 0   ,0.8 },
	{'scale',0, { {rl4_text,2+15}, {rl4_text,2+15} }, 0.32,0.32 },
	{'fade', 0, { {rl4_text,32.3-0.6}, {rl4_text,34.3-0.6} }, 0.8,0 }
)

storyboard:newObject("sb/hecatia.png", "Foreground", "Centre", 395, 405):add(
	{'moverel', 1, { {rl4_text,2+22-0.5}, {rl4_text,3.5+22-0.5} }, {0, 0}, {-59,0}},
	{'moverel', 0, { {rl4_text,3.5+22-0.5}, {rl4_text,4.5+22-0.5} }, {0, 0}, {-07,0}},
	{'moverel', 1, { {rl4_text,4.5+22-0.5}, {rl4_text,34-0.5} }, {0, 0}, {-09,0}},
	{'fade', 1, { {rl4_text,2+22}, {rl4_text,5+22} }, 0   ,0.9 },
	{'scale',0, { {rl4_text,2+22}, {rl4_text,2+22} }, 0.28,0.28 },
	{'fade', 0, { {rl4_text,32.45-0.6}, {rl4_text,34.45-0.6} }, 0.9,0 }
)

storyboard:newObject("sb/190bpm_h.png", "Foreground", "Centre", 320, 446):add(
	{'fade', 1, { {rl4_text,2+22}, {rl4_text,5+22} }, 0   ,0.9 },
	{'scale',0, { {rl4_text,0}, {rl4_text,0} }, 0.47,0.47 },
	{'fade' ,'cubicOut', { {rl4,192*4},{rl4,196*4}}, 0.9, 0}
)

---
---
---
---
---
--- Songe 4

local rl5 = {180.0, 891154}

local rl5_flashes = {}
for i=16*4+1, 20*4-1 do
	table.insert(rl5_flashes, Flash({rl5,i}, 320, 0.11, 0.25)) end

for i=122*4+2, 129*4-2, 2 do
	table.insert(rl5_flashes, Flash({rl5,i}, 320, 0.11, 0.25)) end

for i=130*4+1, 146*4-1, 1 do
	table.insert(rl5_flashes, Flash({rl5,i}, 320, 0.15, 0.25)) end
for i=183*4+1, 187*4-1, 1 do
	table.insert(rl5_flashes, Flash({rl5,i}, 320, 0.15, 0.25)) end

local function kiai_flashes_rl5_func(X)
	local X=X*4
	return {
		Flash({rl5,X}, 1200, 0.4, 0.1),--49
		Flash({rl5,4*4+X}, 1200, 0.25, 0.1),
		Flash({rl5,8*4+X}, 1200, 0.25, 0.1),
		Flash({rl5,12*4+X}, 1200, 0.25, 0.1),
		Flash({rl5,14*4+X}, 1200, 0.4, 0.1),
		Flash({rl5,16*4+X}, 1200, 0.4, 0.1)
	}
end
local function kiai_black_flashes_rl5_func(X)
	local X=X*4
	return {
		Flash({rl5,  X+8*4+1 }, 280, 0.10, 0.105), --57+0.105
		Flash({rl5,  X+8*4+2 }, 280, 0.10, 0.105),
		Flash({rl5,  X+8*4+3 }, 280, 0.10, 0.105),
		Flash({rl5,  X+8*4+4 }, 280, 0.10, 0.105),
		Flash({rl5,  X+8*4+5 }, 280, 0.10, 0.105),
		Flash({rl5,  X+8*4+6 }, 280, 0.10, 0.105),
		Flash({rl5,  X+8*4+7 }, 280, 0.10, 0.105),
		Flash({rl5,  X+8*4+8 }, 280, 0.10, 0.105),
		Flash({rl5,  X+8*4+9 }, 280, 0.10, 0.105),
		Flash({rl5,  X+8*4+10}, 280, 0.10, 0.105),
		Flash({rl5,  X+8*4+11}, 280, 0.10, 0.105),
		Flash({rl5,  X+8*4+12}, 280, 0.10, 0.105),
		Flash({rl5,  X+8*4+13}, 280, 0.10, 0.105),
		Flash({rl5,  X+8*4+14}, 280, 0.10, 0.105),
		Flash({rl5,  X+8*4+15}, 280, 0.10, 0.105)--]]
	}
end

local rl5_inst_move = function(X)
	local X=X*4
	return {
		{'moverel', 'sineIn', {{rl5,X}, {rl5,X+3*4}}, {0,0}, {0,-31}},
		{'moverel', 'sineOut', {{rl5,X+3*4}, {rl5,X+8*4}}, {0,0}, {0,-31}},
		{'moverel', 'sineIn', {{rl5,X+8*4}, {rl5,X+11*4}}, {0,0}, {0,31}},
		{'moverel', 'sineOut', {{rl5,X+11*4}, {rl5,X+16*4}}, {0,0}, {0,31}}
	}
end

local rl5_black_flashes = {}
for i=22*4, 24*4-1 do
	table.insert(rl5_black_flashes, Flash({rl5,i}, 320, 0.21, 0.25)) end

local rl5_move_in = function(X) return {
	{'move', 0, {{rl5,X}, {rl5,X}}, {320, 90}},
	{'moverel', 'sineOut', {{rl5,X}, {rl5,X+6*4}}, {0,0}, {0,70}},
	{'moverel', 'sineOut', {{rl5,X+4*4}, {rl5,X+8*4-0.25}}, {0,0}, {0,63}},
	{'moverel', 'out', {{rl5,X+4.5*4}, {rl5,X+8*4-0.25}}, {0,0}, {0,28}},
	--{'moverel', 'sineOut', {{rl5,X+7*4}, {rl5,X+8*4-0.5}}, {0,0}, {0,16}}
} end

storyboard:newObject("sb/Mima.jpg", "Background", "TopCentre", 320, 160):add(
	{'scale',0, { {rl5,0},{rl5,0}}, 0.667, 0.667},
	{'fade',0,  {  {rl5,0},{rl5,0.5}}, 0, 0.6},
	{'fade',0,  {  {rl5,4*4-0.5},{rl5,4*4}}, 0.6, 0.85},
	{'fade',0,  {  {rl5,4*4},{rl5,8*4}}, 0.6, 1.0},
	{'fade',0,  {  {rl5,8*4},{rl5,8*4}}, 0, 0},

	{'fade', 'cubicOut',  {  {rl5,24*4-1},{rl5,24*4-0.5}}, 0, 1},
	{'fade',0,  {  {rl5,48*4},{rl5,49*4}}, 1, 0.5},

	{'fade', 'cubicOut',  {  {rl5,73*4-1},{rl5,73*4-0.5}}, 0, 1},
	{'fade',0,  {  {rl5,89*4},{rl5,90*4}}, 1, 0.5},

	{'fade', 'cubicOut',  {  {rl5,106*4-1},{rl5,107*4}}, 0, 0.8},
	{'fade',0,  {  {rl5,114*4-0.5},{rl5,114*4}}, 0.8, 0},

	{'fade', 'cubicOut',  {  {rl5,146*4-1},{rl5,146*4-0.5}}, 0, 1},
	{'fade', 'cubicOut',  {  {rl5,154*4},{rl5,155*4-0.25}}, 1, 0.5},
	{'fade', 'cubicOut',  {  {rl5,155*4-0.25},{rl5,155*4}}, 0.5, 0.8},
	{'fade', 'cubicOut',  {  {rl5,159*4-0.5},{rl5,159*4}}, 0.8, 1},
	{'fade',0,  {  {rl5,163*4},{rl5,163*4}}, 1, 0.5},

	sb.concadd(rl5_move_in(0))
)

storyboard:newObject("sb/MimaK4.jpg", "Background", "TopCentre", 320, 251):add(
	{'scale',0, { {rl5,16*4-0.5},{rl5,16*4-0.5}}, 0.667, 0.667},

	{'fade', 'in',  {  {rl5,49*4-0.5},{rl5,49*4}}, 0, 1},
	{'fade', 'cubicOut',  {  {rl5,65*4-0.5},{rl5,65*4}}, 1, 0},

	{'fade', 'in',  {  {rl5,90*4-0.5},{rl5,90*4}}, 0, 1},
	{'fade', 'cubicOut',  {  {rl5,106*4-0.5},{rl5,106*4}}, 1, 0},

	{'fade', 'in',  {  {rl5,163*4-0.5},{rl5,163*4}}, 0, 1},
	{'fade', 'cubicOut',  {  {rl5,187*4-0.5},{rl5,187*4}}, 1, 0}
)
storyboard:newObject("sb/MimaK.jpg", "Background", "TopCentre", 320, 252):add(
	{'scale',0, { {rl5,8*4-0.5},{rl5,8*4-0.5}}, 0.667, 0.667},
	{'fade', 'in',  {  {rl5,8*4-0.5},{rl5,8*4}}, 0, 1},
	{'fade', 'quartOut',  {  {rl5,24*4-1},{rl5,24*4}}, 1, 0},
	Flash({rl5,40*4}, 2500, 0.5, 0.15),

	{'fade', 'in',  {  {rl5,65*4-0.5},{rl5,65*4}}, 0, 1},
	{'fade', 'quartOut',  {  {rl5,73*4-1},{rl5,73*4}}, 1,0},

	{'fade', 'quartOut',  {  {rl5,179*4-0.5},{rl5,179*4}}, 1, 0},

	{'fade', 'in',  {  {rl5,187*4-0.5},{rl5,187*4-0.5}}, 1, 1},
	{'fade', 'quartOut',  {  {rl5,204*4},{rl5,205*4}}, 1, 0},

	sb.concadd(rl5_move_in(0))
)

storyboard:newObject("sb/MimaInst2.jpg", "Background", "TopCentre", 320, 251):add(
	{'scale',0, { {rl5,114*4-0.5},{rl5,114*4-0.5}}, 0.667, 0.667},

	{'fade', 'in',  {  {rl5,114*4-0.5},{rl5,114*4}}, 0, 1},
	{'fade', 'in',  {  {rl5,122*4-0.5},{rl5,122*4}}, 1, 0},
	sb.concadd(rl5_inst_move(114))
)
storyboard:newObject("sb/MimaInst1.jpg", "Background", "TopCentre", 320, 251):add(
	{'scale',0, { {rl5,114*4-0.5},{rl5,114*4-0.5}}, 0.667, 0.667},

	{'fade', 'in',  {  {rl5,122*4-0.5},{rl5,122*4}}, 0, 1},
	{'fade', 'in',  {  {rl5,130*4-0.5},{rl5,130*4}}, 1, 0},
	sb.concadd(rl5_inst_move(114))
)
storyboard:newObject("sb/MimaInst3.jpg", "Background", "TopCentre", 320, 251):add(
	{'scale',0, { {rl5,114*4-0.5},{rl5,114*4-0.5}}, 0.667, 0.667},

	{'fade', 'in',  {  {rl5,130*4-0.5},{rl5,130*4}}, 0, 1},
	{'fade', 'in',  {  {rl5,138*4-0.5},{rl5,138*4}}, 1, 0},

	{'fade', 'in',  {  {rl5,179*4-0.5},{rl5,179*4}}, 0, 1},
	{'fade', 'in',  {  {rl5,183*4-0.5},{rl5,183*4}}, 1, 0},

	sb.concadd(rl5_inst_move(130))
)
storyboard:newObject("sb/MimaInst4.jpg", "Background", "TopCentre", 320, 251):add(
	{'scale',0, { {rl5,114*4-0.5},{rl5,114*4-0.5}}, 0.667, 0.667},

	{'fade', 'in',  {  {rl5,138*4-0.5},{rl5,138*4}}, 0, 1},
	{'fade', 'in',  {  {rl5,146*4-0.5},{rl5,146*4}}, 1, 0},

	{'fade', 'in',  {  {rl5,183*4-0.5},{rl5,183*4}}, 0, 1},
	{'fade', 'in',  {  {rl5,187*4-0.5},{rl5,187*4}}, 1, 0},

	sb.concadd(rl5_inst_move(130))
)

storyboard:newObject("sb/MimaEnd.jpg", "Background", "TopCentre", 320, 251):add(
	{'scale',0, { {rl5,203*4-0.5},{rl5,203*4-0.5}}, 0.667, 0.667},

	{'fade', 'in',  {  {rl5,203*4-0.5},{rl5,203*4}}, 0, 1},
	{'fade', 'quartOut',  {  {rl5,204*4+4},{rl5,206*4}}, 1, 0}
)

storyboard:newObject("sb/MimaFlash.png", "Background", "TopCentre", 320, 242):add(
	{'protract', {'parameter', { {rl5, 0}, {rl5, 0} }, value='a'}},
	Flash({rl5,0}, 600, 0.4, 0.15),
	Flash({rl5,1*4}, 600, 0.25, 0.15),
	Flash({rl5,2*4}, 1200, 0.25, 0.15),
	Flash({rl5,3*4}, 600, 0.15, 0.15),
	Flash({rl5,4*4}, 600, 0.4, 0.15),
	Flash({rl5,8*4}, 600, 0.2, 0.15),
	Flash({rl5,12*4}, 600, 0.2, 0.15),
	Flash({rl5,16*4}, 300, 0.2, 0.15),
	Flash({rl5,20*4}, 600, 0.2, 0.15),
	Flash({rl5,24*4}, 600, 0.2, 0.15),
	Flash({rl5,28*4}, 400, 0.15, 0.15),
	Flash({rl5,30*4+2}, 400, 0.15, 0.15),
	Flash({rl5,31*4}, 400, 0.15, 0.15),
	Flash({rl5,32*4}, 600, 0.25, 0.15),
	Flash({rl5,38*4}, 400, 0.15, 0.15),
	Flash({rl5,38*4+2}, 400, 0.15, 0.15),
	Flash({rl5,39*4+2}, 400, 0.15, 0.15),
	Flash({rl5,40*4}, 600, 0.25, 0.15),
	Flash({rl5,44*4}, 400, 0.15, 0.15),
	Flash({rl5,47*4}, 400, 0.15, 0.15),
	Flash({rl5,48*4}, 320, 0.25, 0.25),


	Flash({rl5,24*4 + 49*4}, 600, 0.2, 0.15),
	Flash({rl5,28*4 + 49*4}, 400, 0.15, 0.15),
	Flash({rl5,30*4 + 49*4}, 400, 0.15, 0.15),
	Flash({rl5,30*4+2 + 49*4}, 400, 0.15, 0.15),
	Flash({rl5,31*4 + 49*4}, 400, 0.15, 0.15),
	Flash({rl5,32*4 + 49*4}, 600, 0.25, 0.15),
	Flash({rl5,36*4 + 49*4}, 600, 0.25, 0.15),
	Flash({rl5,39*4 + 49*4}, 400, 0.15, 0.15),
	Flash({rl5,40*4 + 49*4}, 400, 0.25, 0.15),
	Flash({rl5,39*4+2 + 49*4}, 320, 0.15, 0.15),--]]
	--Flash({rl5,41*4 + 49*4}, 400, 0.15, 0.15),
	--
	Flash({rl5,107*4}, 400, 0.15, 0.15),
	Flash({rl5,108*4}, 400, 0.15, 0.15),
	Flash({rl5,109*4}, 400, 0.15, 0.15),
	Flash({rl5,110*4}, 400, 0.15, 0.15),
	Flash({rl5,113*4}, 400, 0.25, 0.15),
	Flash({rl5,114*4}, 1200, 0.4, 0.1),

	Flash({rl5,118*4}, 1200, 0.4, 0.1),
	Flash({rl5,122*4}, 320, 0.4, 0.25),
	Flash({rl5,129*4}, 320, 0.2, 0.25),
	Flash({rl5,129*4+1}, 320, 0.2, 0.25),
	Flash({rl5,129*4+3}, 320, 0.15, 0.25),
	Flash({rl5,130*4}, 320, 0.4, 0.25),

	Flash({rl5,150*4}, 320, 0.15, 0.25),
	Flash({rl5,150*4+1}, 320, 0.10, 0.25),
	Flash({rl5,153*4}, 800, 0.25, 0.1),
	Flash({rl5,154*4}, 320, 0.25, 0.1),
	Flash({rl5,155*4}, 800, 0.15, 0.1),
	Flash({rl5,156*4}, 800, 0.15, 0.1),
	Flash({rl5,157*4}, 800, 0.15, 0.1),
	Flash({rl5,158*4}, 800, 0.15, 0.1),
	Flash({rl5,159*4+2}, 320, 0.15, 0.1),

	Flash({rl5,163*4}, 800, 0.25, 0.1),
	Flash({rl5,167*4}, 400, 0.2, 0.15),
	Flash({rl5,168*4}, 400, 0.2, 0.15),
	Flash({rl5,169*4}, 800, 0.4, 0.1),

	Flash({rl5,171*4}, 800, 0.4, 0.1),

	Flash({rl5,175*4}, 320, 0.15, 0.25),
	Flash({rl5,175*4+1}, 800, 0.4, 0.1),

	Flash({rl5,178*4}, 400, 0.2, 0.15),
	Flash({rl5,178*4+2}, 400, 0.15, 0.15),
	Flash({rl5,179*4}, 800, 0.4, 0.1),

	Flash({rl5,183*4}, 320, 0.35, 0.15),

	Flash({rl5,187*4}, 400, 0.4, 0.15),
	Flash({rl5,191*4}, 400, 0.4, 0.15),

	Flash({rl5,194*4}, 320, 0.1, 0.15),
	Flash({rl5,194*4+1}, 320, 0.2, 0.15),

	Flash({rl5,195*4}, 400, 0.25, 0.25),

	Flash({rl5,198*4}, 320, 0.25, 0.15),
	Flash({rl5,199*4}, 320, 0.12, 0.15),
	Flash({rl5,200*4}, 320, 0.12, 0.15),
	Flash({rl5,201*4}, 320, 0.2, 0.15),
	Flash({rl5,201*4+2}, 320, 0.2, 0.15),
	Flash({rl5,202*4}, 320, 0.3, 0.15),
	Flash({rl5,202*4+2}, 320, 0.3, 0.15),

	sb.concadd(rl5_move_in(0), rl5_flashes, kiai_flashes_rl5_func(49), kiai_flashes_rl5_func(90), rl5_inst_move(114),
		rl5_inst_move(130))
)

storyboard:newObject("sb/Black.jpg", "Foreground", "BottomLeft", -106.7, 480):add(
	Flash({rl5,129*4+2}, 320, 0.2, 0.25),

	Flash({rl5,  163*4+1 }, 280, 0.08, 0.085), --57+0.085
	Flash({rl5,  163*4+2 }, 280, 0.08, 0.085),
	Flash({rl5,  163*4+3 }, 280, 0.08, 0.085),
	Flash({rl5,  163*4+4 }, 280, 0.08, 0.085),
	Flash({rl5,  163*4+5 }, 280, 0.08, 0.085),
	Flash({rl5,  163*4+6 }, 280, 0.08, 0.085),
	Flash({rl5,  163*4+7 }, 280, 0.08, 0.085),
	Flash({rl5,  163*4+8 }, 280, 0.08, 0.085),
	Flash({rl5,  163*4+9 }, 280, 0.08, 0.085),
	Flash({rl5,  163*4+10}, 280, 0.08, 0.085),
	Flash({rl5,  163*4+11}, 280, 0.08, 0.085),
	Flash({rl5,  163*4+12}, 280, 0.08, 0.085),
	Flash({rl5,  163*4+13}, 280, 0.08, 0.085),
	Flash({rl5,  163*4+14}, 280, 0.08, 0.085),
	Flash({rl5,  163*4+15}, 280, 0.08, 0.085),--]]

	Flash({rl5,  171*4+1 }, 280, 0.1, 0.15), --57+0.15
	Flash({rl5,  171*4+2 }, 280, 0.1, 0.15),
	Flash({rl5,  171*4+3 }, 280, 0.1, 0.15),
	Flash({rl5,  171*4+4 }, 280, 0.1, 0.15),
	Flash({rl5,  171*4+5 }, 280, 0.1, 0.15),
	Flash({rl5,  171*4+6 }, 280, 0.1, 0.15),
	Flash({rl5,  171*4+7 }, 280, 0.1, 0.15),
	Flash({rl5,  171*4+8 }, 280, 0.1, 0.15),
	Flash({rl5,  171*4+9 }, 280, 0.1, 0.15),
	Flash({rl5,  171*4+10}, 280, 0.1, 0.15),
	Flash({rl5,  171*4+11}, 280, 0.1, 0.15),
	Flash({rl5,  171*4+12}, 280, 0.1, 0.15),
	Flash({rl5,  171*4+13}, 280, 0.1, 0.15),
	Flash({rl5,  171*4+14}, 280, 0.1, 0.15),
	Flash({rl5,  171*4+15}, 280, 0.1, 0.15),--]]

	Flash({rl5,  175*4+2 }, 280, 0.1, 0.15),
	Flash({rl5,  175*4+3 }, 280, 0.1, 0.15),
	Flash({rl5,  175*4+4 }, 280, 0.1, 0.15),
	Flash({rl5,  175*4+5 }, 280, 0.1, 0.15),
	Flash({rl5,  175*4+6 }, 280, 0.1, 0.15),
	Flash({rl5,  175*4+7 }, 280, 0.1, 0.15),
	Flash({rl5,  175*4+8 }, 280, 0.1, 0.15),
	Flash({rl5,  175*4+9 }, 280, 0.1, 0.15),
	Flash({rl5,  175*4+10}, 280, 0.1, 0.15),
	Flash({rl5,  175*4+11}, 280, 0.1, 0.15),

	Flash({rl5,179*4+2}, 320, 0.15, 0.25),
	Flash({rl5,180*4}, 320, 0.15, 0.25),
	Flash({rl5,180*4+2}, 320, 0.15, 0.25),
	Flash({rl5,181*4}, 320, 0.15, 0.25),
	Flash({rl5,181*4+2}, 320, 0.15, 0.25),
	Flash({rl5,182*4}, 320, 0.15, 0.25),
	Flash({rl5,182*4+2}, 320, 0.15, 0.25),

	Flash({rl5,194*4+2}, 320, 0.12, 0.15),


	Flash({rl5,  195*4+1 }, 280, 0.08, 0.085), --57+0.085
	Flash({rl5,  195*4+2 }, 280, 0.08, 0.085),
	Flash({rl5,  195*4+3 }, 280, 0.08, 0.085),
	Flash({rl5,  195*4+4 }, 280, 0.08, 0.085),
	Flash({rl5,  195*4+5 }, 280, 0.08, 0.085),
	Flash({rl5,  195*4+6 }, 280, 0.08, 0.085),
	Flash({rl5,  195*4+7 }, 280, 0.08, 0.085),
	Flash({rl5,  195*4+8 }, 280, 0.08, 0.085),
	Flash({rl5,  195*4+9 }, 280, 0.08, 0.085),
	Flash({rl5,  195*4+10 }, 280, 0.08, 0.085),
	Flash({rl5,  195*4+11 }, 280, 0.08, 0.085),
	Flash({rl5,  195*4+12 }, 280, 0.08, 0.085),
	Flash({rl5,  195*4+13 }, 280, 0.08, 0.085),
	Flash({rl5,  195*4+14 }, 280, 0.08, 0.085),
	Flash({rl5,  195*4+15 }, 280, 0.08, 0.085),

	sb.concadd(rl5_black_flashes, kiai_black_flashes_rl5_func(49), kiai_black_flashes_rl5_func(90))
)

local rl5_text = {180.0, 891154}
storyboard:newObject("sb/star_light.png", "Foreground", "Centre", 242, 294):add(
	{'moverel', 1, { {rl5_text,3}, {rl5_text,3.5} }, {0, 0}, {33,0}},
	{'moverel', 0, { {rl5_text,3.5}, {rl5_text,4} }, {0, 0}, {17,0}},
	{'moverel', 1, { {rl5_text,4}, {rl5_text,25+4} }, {0, 0}, {24,0}},
	{'fade', 1, { {rl5_text,3}, {rl5_text,5} }, 0   ,0.9 },
	{'scale',0, { {rl5_text,3}, {rl5_text,3} }, 0.58,0.58 },
	{'fade', 0, { {rl5_text,32-0.5}, {rl5_text,34-0.5} }, 0.9,0 }
)

storyboard:newObject("sb/completedarkness.png", "Foreground", "Centre", 385, 328):add(
	{'moverel', 1, { {rl5_text,2+8}, {rl5_text,3.5+8} }, {0, 0}, {-43,0}},
	{'moverel', 0, { {rl5_text,3.5+8}, {rl5_text,5.2+8} }, {0, 0}, {-9,0}},
	{'moverel', 1, { {rl5_text,5.2+8}, {rl5_text,26+8} }, {0, 0}, {-18,0}},
	{'fade', 1, { {rl5_text,2+8}, {rl5_text,5+8} }, 0   ,0.9 },
	{'scale',0, { {rl5_text,2+8}, {rl5_text,2+8} }, 0.54,0.54 },
	{'fade', 0, { {rl5_text,32.15-0.6}, {rl5_text,34.15-0.6} }, 0.9,0 }
)

storyboard:newObject("sb/wonderland.png", "Foreground", "Centre", 253, 375):add(
	{'moverel', 1, { {rl5_text,2+15}, {rl5_text,3.5+15} }, {0, 0}, {35,0}},
	{'moverel', 0, { {rl5_text,3.5+15}, {rl5_text,5.2+15} }, {0, 0}, {7,0}},
	{'moverel', 1, { {rl5_text,5.2+15}, {rl5_text,23+8} }, {0, 0}, {16,0}},
	{'fade', 1, { {rl5_text,2+15}, {rl5_text,5+15} }, 0   ,0.9 },
	{'scale',0, { {rl5_text,2+15}, {rl5_text,2+15} }, 0.38,0.38 },
	{'fade', 0, { {rl5_text,32.3-0.6}, {rl5_text,34.3-0.6} }, 0.9,0 }
)

storyboard:newObject("sb/mima.png", "Foreground", "Centre", 395, 407):add(
	{'moverel', 1, { {rl5_text,2+22-0.5}, {rl5_text,3.5+22-0.5} }, {0, 0}, {-59,0}},
	{'moverel', 0, { {rl5_text,3.5+22-0.5}, {rl5_text,4.5+22-0.5} }, {0, 0}, {-07,0}},
	{'moverel', 1, { {rl5_text,4.5+22-0.5}, {rl5_text,34-0.5} }, {0, 0}, {-09,0}},
	{'fade', 1, { {rl5_text,2+22}, {rl5_text,5+22} }, 0   ,0.9 },
	{'scale',0, { {rl5_text,2+22}, {rl5_text,2+22} }, 0.34,0.34 },
	{'fade', 0, { {rl5_text,32.45-0.6}, {rl5_text,34.45-0.6} }, 0.9,0 }
)

storyboard:newObject("sb/180bpm_m.png", "Foreground", "Centre", 320, 446):add(
	{'fade', 1, { {rl5_text,2+22}, {rl5_text,5+22} }, 0   ,0.9 },
	{'scale',0, { {rl5_text,0}, {rl5_text,0} }, 0.47,0.47 },
	{'fade' ,'cubicOut', { {rl5,204*4},{rl5,206*4}}, 0.9, 0}
)

--
-- Songe 6
--
--
--
--
-- Songe 7
--
local rl7 = {240.0, 1448359}
local rl8 = {240.0, 1472359}
local rl9 = {240.0, 1496359}
local rl10 = {240.0, 1563359}
local rl11 = {240.0, 1575359}
local interval_1 = sb.time:convert({rl7,1*4}) - sb.time:convert({rl7,0*4})
local rl11_comp = { 240.0, sb.time:convert('26:48:359') }

local rl7_SV = 0.92
local function rl7_scroller(X,Y, ease, sig, rl)
	local sig = sig or 4
	local rl = rl or rl7
	return function(out) out{'move', ease or 0, { {rl, sig*X}, {rl, sig*Y} }, {-107,252}, {-2565*0.58*rl7_SV - 107,252}} end
end

local rl7_scrolls = {}
for i=-1,15 do
	table.insert(rl7_scrolls, rl7_scroller(i,i+1,0))
end

for i=8,15 do
	table.insert(rl7_scrolls, rl7_scroller(i,i+1,0, 6, rl8))
end

local rl7_move_in = {
	{'scale', 'cubicOut', {{rl7,0*4-0.8},{rl7,16*4}}, 0.85,0.69}
}

storyboard:newObject("sb/Lines.jpg", "Background", "TopLeft", -107, 252):add(
	{'color', 'linear', { {rl7,0*4-0.8} }, {255,0,0} },
	{'vector', 0, { {rl7,0*4-0.8}, {rl7,0*4-0.8} }, {0.58*rl7_SV,0.58}},
	{'fade', 'quartIn', { {rl7,0*4-0.8}, {rl7,0*4+0.5} }, 0, 1},
	{'fade', 'quartIn', { {rl7,16*4-4}, {rl7,16*4+0.5} }, 1, 0},

	{'color', 'linear', { {rl8,8*6-0.8} }, {255,255,255} },
	{'fade', 'quartIn', { {rl8,8*6-0.8}, {rl8,8*6+0.5} }, 0, 1},
	{'fade', 'quartIn', { {rl8,16*6-4}, {rl8,16*6} }, 1, 0},
	sb.concadd(rl7_scrolls)
)

storyboard:newObject("sb/ReisenNegative.png", "Foreground", "Centre", 320, 366):add(
	{'protract', {'parameter', {{rl8, 0}}, value='a'}},
	{'color', 0, {{rl8, 0}}, {255,0,240}},
	{'fade', 'quartOut', { {rl8,0}, {rl8,0.1} }, 0, 0.5},
	{'fade', 'quartOut', { {rl8,0.1}, {rl8,1.5} }, 0.5, 0},
	sb.concadd(rl7_move_in)
)
storyboard:newObject("sb/ReisenEdge.png", "Foreground", "Centre", 320, 366):add(
	{'color', 'linear', { {rl7,0*4-0.8} }, {220,220,220} },
	{'fade', 'quartIn', { {rl7,0*4-0.8}, {rl7,0.5} }, 0, 1},
	{'fade', 'quartIn', { {rl7,16*4-4}, {rl7,16*4} }, 1, 0},
	{'fade', 'quartOut', { {rl8,0*6}, {rl8,0*6+1} }, 0, 1},
	{'fade', 'quartOut', { {rl8,8*6-1}, {rl8,8*6} }, 1, 0},

	{'fade', 'quartOut', { {rl10,0*6}, {rl10,0*6+1} }, 0, 1},
	{'fade', 'quartOut', { {rl10,8*6-1}, {rl10,8*6} }, 1, 0},

	sb.concadd(rl7_move_in)
)

storyboard:newObject("sb/ReisenDark.png", "Background", "Centre", 320, 366):add(
	{'color', 'linear', { {rl7,16*4}, {rl7,16*4+4} }, {10,10,10}, {200,200,200} },	
	{'fade', 'quartOut', { {rl7,16*4}, {rl7,16*4+4} }, 0, 1},
	{'fade', 'quartOut', { {rl7,24*4-1}, {rl7,24*4} }, 1, 0},

	{'fade', 'quartOut', { {rl9,0*4}, {rl9,0*4+4} }, 0, 1},
	{'fade', 'quartOut', { {rl9,16*4-1}, {rl9,16*4} }, 1, 0},
	{'color', 'linear', { {rl9,12*4} }, {200,200,200}, {255,255,255} },	

	{'fade', 'cubicOut', {{rl9,31*4}, {rl9,32*4}}, 0, 0.7},
	{'fade', 'cubicOut', {{rl9,32*4}, {rl9,32*4}}, 0, 0},

	{'fade', 'quartOut', { {rl9,51*4}, {rl9,51*4+4} }, 0, 1},
	{'fade', 'quartOut', { {rl9,67*4-1}, {rl9,67*4} }, 1, 0},
	{'color', 'linear', { {rl9,53*4} }, {200,200,200}, {255,255,255} },	--]]

	{'fade', 'cubicOut', {{rl11,15*4}, {rl11,16*4}}, 0, 0.7},
	{'fade', 'cubicOut', {{rl11,16*4}, {rl11,16*4}}, 0, 0},

	{'fade', 'cubicOut', {{rl11,64*4}, {rl11,65*4}}, 0, 0.7},
	{'fade', 'cubicOut', {{rl11,65*4}, {rl11,65*4}}, 0, 0},

	sb.concadd(rl7_move_in)
)

storyboard:newObject("sb/Reisen.png", "Background", "Centre", 320, 366):add(
	{'fade', 'quartOut', { {rl8,8*6}, {rl8,8*6+2} }, 0, 1},
	{'fade', 'quartOut', { {rl8,16*6}, {rl8,16*6+0.25} }, 1, 0},
	{'fade', 'cubicOut', {{rl9,32*4-1}, {rl9,32*4}}, 0,1},
	{'fade', 'cubicOut', {{rl9,49*4-1}, {rl9,49*4}}, 1,0},
	{'fade', 'cubicOut', {{rl11,16*4-1}, {rl11,16*4}}, 0,1},
	{'fade', 'cubicOut', {{rl11,32*4+2}, {rl11,33*4-1.5}}, 1,0.6},
	{'fade', 'cubicOut', {{rl11,33*4-1}, {rl11,33*4}}, 0.6,0},

	{'fade', 'cubicOut', {{rl11,65*4-1}, {rl11,65*4}}, 0,1},
	{'fade', 'cubicOut', {{rl11,97*4+2}, {rl11,98*4-1.5}}, 1,0.6},
	--{'fade', 'cubicIn', {{rl11,99*4-1}, {rl11,99*4}}, 0.6,1},
	{'fade', 'cubicIn', {{rl11,99*4-1}}, 0},
	--{'fade', 'cubicOut', {{rl11,100*4}, {rl11,101*4}}, 1,0.0},
	sb.concadd(rl7_move_in)
)

local rl7_flashes = {}
local rl7_red_flashes = {}
for i=0,15*4-1 do
	table.insert(rl7_red_flashes, FlashFloor({rl7,i}, 220, 0.05, 0.5, 0.02))
end
for i=15*4,16*4-1,0.5 do
	table.insert(rl7_red_flashes, FlashFloor({rl7,i}, 110, 0.10, 0.5, 0.01))
end
for i=1,16*4-1,0.5 do
	if i~=8*4 and i~=8*4+0.5 then
		table.insert(rl7_flashes, Flash({rl7,i}, 110, 0.2, 0.33))
	end
end
storyboard:newObject("sb/Flash.jpg", "Background", "BottomLeft", -106.7, 480):add(
	{'protract', {'parameter', {{rl7, 0}}, value='a'}},
	{'color', 'linear', { {rl7,0*4-0.8} }, {255,0,0} },
	sb.concadd(rl7_red_flashes)
)

storyboard:newObject("sb/ReisenEdge.png", "Foreground", "Centre", 320, 366):add(
	{'protract', {'parameter', {{rl7, 0}}, value='a'}},
	{'color', 0, {{rl7,0}}, {255,255,255}},
	Flash({rl7,0}, 220, 1.0, 0.1),
	Flash({rl7,8*4}, 220, 1.0, 0.1),
	Flash({rl7,16*4}, 800, 1.0, 0.1),

	Flash({rl8,0*6}, 800, 0.5, 0.1),
	Flash({rl8,2*6}, 1600, 0.75, 0.1),
	{'color', 0, {{rl8,4*6}}, {255,0,0}},
	Flash({rl8,4*6}, 1600, 1.0, 0.1),
	{'color', 0, {{rl8,6*6}}, {255,255,255}},
	Flash({rl8,6*6}, 1600, 0.75, 0.1),
	Flash({rl8,8*6}, 1600, 1.0, 0.1),

	Flash({rl8,16*6}, 800, 1.0, 0.05),

	Flash({rl9,8*4}, 800, 0.7, 0.05),
	Flash({rl9,30*4}, 800, 0.8, 0.05),

	Flash({rl9,59*4}, 800, 0.7, 0.05),

	Flash({rl10,0*4}, 1600, 1.0, 0.025),

	Flash({rl10,2*6}, 1600, 0.75, 0.1),
	{'color', 0, {{rl10,4*6}}, {255,0,0}},
	Flash({rl10,4*6}, 1600, 1.0, 0.1),
	{'color', 0, {{rl10,6*6}}, {255,255,255}},
	Flash({rl10,6*6}, 1600, 0.75, 0.1),
	Flash({rl10,8*6}, 800, 1.0, 0.1),

	Flash({rl11,14*4}, 800, 0.8, 0.05),

	Flash({rl11,32*4}, 800, 0.8, 0.05),

	Flash({rl11,49*4}, 800, 0.8, 0.05),

	--Flash({rl11,37*4}, 400, 0.6, 0.05),

	--Flash({rl11,0*4}, 800, 0.5, 0.1),
	Flash({rl11,57*4}, 800, 1.0, 0.1),

	Flash({rl11,63*4}, 800, 0.8, 0.05),

	Flash({rl11,97*4}, 800, 0.8, 0.05),
	Flash({rl11,98*4}, 800, 0.8, 0.05),
	Flash({rl11,99*4}, 1600, 1.0, 0.05),

	sb.concadd(rl7_move_in, rl7_flashes)
)

local function rl7_negative_flash_func(X, str, rl)
	local rl=rl or rl7
	return function(out)
		local X=X*4
		out{'color',0,{{rl,X}}, {0,0,255}}
		for i=X,X+0.75,0.25 do
			out{'fade',0, {{rl,i}}, str}
			if i~=X+0.75 then out{'fade',0, {{rl,i+0.125}}, str*0.2}	
			             else out{'fade',0, {{rl,i+0.125}}, 0}	
			end
		end
		X=X+1
		out{'color',0, {{rl,X}}, {0,255,0}}
		for i=X,X+0.75,0.25 do
			out{'fade',0, {{rl,i}}, str}	
			if i~=X+0.75 then out{'fade',0, {{rl,i+0.125}}, str*0.2}	
			             else out{'fade',0, {{rl,i+0.125}}, 0}	
			end
		end
		X=X+1
		out{'color',0, {{rl,X}}, {255,0,0}}
		for i=X,X+0.75,0.25 do
			out{'fade',0, {{rl,i}}, str}	
			if i~=X+0.75 then out{'fade',0, {{rl,i+0.125}}, str*0.2}	
			             else out{'fade',0, {{rl,i+0.125}}, 0}	
			end
		end
		X=X+1
		out{'color',0, {{rl,X}}, {0,0,255}}
		for i=X,X+0.75,0.25 do
			out{'fade',0, {{rl,i}}, str}	
			if i~=X+0.75 then out{'fade',0, {{rl,i+0.125}}, str*0.2}	
			             else out{'fade',0, {{rl,i+0.125}}, 0}	
			end
		end
	end
end

local function rl9_color_transitions(X, rl)
	return {
	{'fade', 'cubicOut', {{rl,(X+16)*4}, {rl,(X+16)*4+1}}, 0, 0.7},
	{'color', 'cubicOut', {{rl,(X+16)*4}, {rl,(X+16)*4+1}}, {0,0,255},{0,0,255}},

	{'fade', 'cubicOut', {{rl,(X+18)*4}, {rl,(X+18)*4+1}}, 0.7, 0.55},
	{'fade', 'cubicOut', {{rl,(X+20)*4}, {rl,(X+20)*4+1}}, 0.55, 0.7},
	{'color', 'cubicOut', {{rl,(X+20)*4}, {rl,(X+20)*4+1}}, {0,0,255},{0,255,0}},
	{'fade', 'cubicOut', {{rl,(X+22)*4}, {rl,(X+22)*4+1}}, 0.7, 0.55},
	{'fade', 'cubicOut', {{rl,(X+24)*4}, {rl,(X+24)*4+1}}, 0.55, 0.7},
	{'color', 'cubicOut', {{rl,(X+24)*4}, {rl,(X+24)*4+1}}, {0,255,0},{0,0,255}},
	{'fade', 'cubicOut', {{rl,(X+28)*4}, {rl,(X+28)*4+1}}, 0.7, 0.4},
	{'color', 'cubicOut', {{rl,(X+28)*4}, {rl,(X+28)*4+1}}, {0,0,255},{255,0,0}},
	{'fade', 'cubicOut', {{rl,(X+28)*4+1}, {rl,(X+30)*4+1}}, 0.4, 0.6},

	{'fade', 'cubicOut', {{rl,(X+31)*4-0.5}, {rl,(X+31)*4+4}}, 0.6,0},}
end
storyboard:newObject("sb/ReisenNegative.png", "Foreground", "Centre", 320, 366):add(
	--{'protract', {'parameter', {{rl7, 0}}, value='a'}},
	{'fade',0,{{rl7,19}}, 0},
	rl7_negative_flash_func(19,0.4),
	rl7_negative_flash_func(23,0.4),
	rl7_negative_flash_func(3,0.4,rl9),
	rl7_negative_flash_func(7,0.4,rl9),
	rl7_negative_flash_func(11,0.6,rl9),
	rl7_negative_flash_func(15,0.6,rl9),

	rl7_negative_flash_func(51+3,0.4,rl9),
	rl7_negative_flash_func(51+7,0.4,rl9),
	rl7_negative_flash_func(51+11,0.6,rl9),
	rl7_negative_flash_func(51+15,0.6,rl9),

	sb.concadd(rl7_move_in, rl9_color_transitions(0,rl9), rl9_color_transitions(-16,rl11), rl9_color_transitions(49-16,rl11))
)

local rl7_black_flashes = {}
for i=16*4+1,19*4-1 do
	table.insert(rl7_black_flashes, Flash({rl7,i}, 220, 0.1, 0.5))
end
for i=20*4+1,23*4-1 do
	table.insert(rl7_black_flashes, Flash({rl7,i}, 220, 0.1, 0.5))
end

local function rl7_black_flashes_func(X, rl)
	for i=X*4+1,(X+3)*4-1 ,1 do
		table.insert(rl7_black_flashes, Flash({rl,i}, 220, 0.1, 0.5)) end
	X=X+4
	for i=X*4,(X+3)*4-1 ,1 do
		table.insert(rl7_black_flashes, Flash({rl,i}, 220, 0.1, 0.5)) end
	X=X+4
	for i=X*4+1,(X+3)*4-1 ,1 do
		table.insert(rl7_black_flashes, Flash({rl,i}, 220, 0.1, 0.5)) end
	X=X+4
	for i=X*4,(X+3)*4-1,0.333333 do
		table.insert(rl7_black_flashes, Flash({rl,i}, 110*(2/3), 0.2, 0.5)) end
	X=X+16
	--for i=X*4,(X+2)*4-1,1 do
	--	table.insert(rl7_black_flashes, Flash({rl,i}, 220, 0.1, 0.5)) end
end

for i=0*4,12*4-1 do
	local j=i/4+16
	if (not ((j>=18 and j<20) or (j >=22))) then
		table.insert(rl7_black_flashes, Flash({rl11,i}, 220, 0.05, 0.5))
	end
end
for i=12*4,14*4-1, 0.5 do
	table.insert(rl7_black_flashes, Flash({rl11,i}, 110*(1/2), 0.15, 0.5))
end

for i=16*4,28*4-1 do
	local j=i/4
	if (not ((j>=18 and j<20) or (j >=22))) then
		table.insert(rl7_black_flashes, Flash({rl9,i}, 220, 0.05, 0.5))
	end
end
for i=28*4,30*4-1, 0.5 do
	table.insert(rl7_black_flashes, Flash({rl9,i}, 110*(1/2), 0.15, 0.5))
end

for i=49*4,57*4-1 do
	local j=i/4
	if (not ((j>=51 and j<53) or (j >=55))) then
		table.insert(rl7_black_flashes, Flash({rl11,i}, 220, 0.05, 0.5))
	end
end
for i=61*4,63*4-1, 0.5 do
	table.insert(rl7_black_flashes, Flash({rl11,i}, 110*(1/2), 0.15, 0.5))
end

rl7_black_flashes_func(0, rl9)
rl7_black_flashes_func(51, rl9)

for i=7*6+2,7*6+5,0.3333 do
	table.insert(rl7_black_flashes, Flash({rl10,i}, 110*(2/3), 0.6, 0.25))
end

storyboard:newObject("sb/Black.jpg", "Foreground", "BottomLeft", -106.7, 480):add(
	sb.concadd(rl7_black_flashes)
)

local rl9_post_kiai_flashes = function(X, rl)
	local rl=rl or rl9
	return {
		Flash({rl,X*4}, 600, 0.2, 0.1),
		Flash({rl,(X+8)*4}, 400, 0.5, 0.05),
		Flash({rl,(X+12)*4}, 200, 0.8, 0.05),
		Flash({rl,(X+16)*4}, 800, 0.8, 0.05),
		Flash({rl,(X+30)*4}, 800, 0.8, 0.05),
	}
end
local rl9_kiai_negative = function(X, rl)
	local rl=rl or rl9
	return {
		{'color', 0, {{rl,X}}, {0,255,0}},
		{'fade', 'cubicOut', {{rl,X}, {rl,X+1}}, 0,0.8},
		{'color', 0, {{rl,X+8*4}, {rl,X+8*4+1}}, {0,255,0},{235,0,255}},
		{'fade', 'cubicOut', {{rl,X+16*4}, {rl,X+16*4+1}}, 0.8,0}
	}
end
storyboard:newObject("sb/ReisenNegative2.png", "Foreground", "Centre", 320, 366):add(
	Flash({rl9,51*4}, 600, 0.2, 0.1),
	Flash({rl9,(51+8)*4}, 400, 0.5, 0.05),
	Flash({rl9,(51+12)*4}, 200, 0.8, 0.05),
	Flash({rl9,(51+16)*4}, 800, 0.8, 0.05),

	Flash({rl11,0*4}, 600, 0.2, 0.1),
	Flash({rl11,8*4}, 600, 0.2, 0.1),
	Flash({rl11,14*4}, 800, 0.8, 0.05),

	Flash({rl11,32*4}, 400, 0.8, 0.05),
	Flash({rl11,32*4+2}, 400, 0.3, 0.05),
	Flash({rl11,33*4}, 800, 0.8, 0.05),
	Flash({rl11,37*4}, 400, 0.25, 0.05),
	Flash({rl11,41*4}, 400, 0.25, 0.05),

	Flash({rl11,49*4}, 800, 0.8, 0.05),

	Flash({rl11,57*4}, 600, 0.2, 0.1),
	Flash({rl11,63*4}, 800, 0.8, 0.05),

	Flash({rl11,97*4}, 400, 0.8, 0.05),
	Flash({rl11,97*4+2}, 400, 0.3, 0.05),

	sb.concadd(rl7_move_in,
		rl9_post_kiai_flashes(0, rl9))
)
storyboard:newObject("sb/ReisenNegative2.png", "Foreground", "Centre", 320, 366):add(
	{'protract', {'parameter', {{rl9, 0}}, value='a'}},

	{'color', 0, {{rl11,65*4}}, {0,255,0}},
	{'fade', 'cubicOut', {{rl11,65*4}, {rl11,65*4+1}}, 0,0.8},
	{'color', 0, {{rl11,65*4+8*4}, {rl11,65*4+8*4+1}}, {0,255,0},{0,0,255}},
	{'color', 0, {{rl11,81*4}, {rl11,81*4+1}}, {0,0,255},{255,0,0}},
	{'color', 0, {{rl11,89*4}, {rl11,89*4+1}}, {255,0,0},{230,0,255}},
	{'color', 0, {{rl11,93*4}, {rl11,93*4+1}}, {230,0,255},{0,255,0}},
	{'fade', 'cubicOut', {{rl11,97*4}, {rl11,97*4+1}}, 0.8,0},

	sb.concadd(rl7_move_in,
		rl9_kiai_negative(32*4,rl9), rl9_kiai_negative(16*4,rl11))
)

local function rl11_noisefunc(X)
	local R ={}
	local S = 1.5
	for i= (X-1)/S,15*4+3,6/S do
		table.insert(R, {'fade', 'linear', {{rl11_comp,i},{rl11_comp,i+1.5/S}}, 0,0.66 })
		table.insert(R, {'fade', 'linear', {{rl11_comp,i+1.5/S},{rl11_comp,i+3/S}}, 0.66,0 })
	end
	return R
end
local function rl11_noisefunc2(X)
	local R ={}
	local S = 2.5
	for i= 99*4+(X-1)/S,99*4+3,6/S do
		table.insert(R, {'fade', 'linear', {{rl11,i},{rl11,i+1.5/S}}, 0,0.8 })

		if i==99*4+3 then
			table.insert(R, {'fade', 'linear', {{rl11,i+1.5/S},{rl11,i+4.5/S}}, 0.8,0 })
		else
			table.insert(R, {'fade', 'linear', {{rl11,i+1.5/S},{rl11,i+3/S}}, 0.8,0 })
		end
	end
	return R
end
local rl9_kiai_flashes = function(X, rl, str)
	local R = {}
	local rl=rl or rl9
	for i = X+1,X+8*4-1, 1 do
		if i~=X+4*4 then
			table.insert(R, Flash({rl,i}, 220, str, 0.25))
		else
			table.insert(R, Flash({rl,i}, 220, str*2.0, 0.25))
		end
	end
	table.insert(R, Flash({rl,X}, 220, str*2.0, 0.25))
	return R
end
storyboard:newObject("sb/ReisenNegative.png", "Foreground", "Centre", 320, 366):add(
	{'protract', {'parameter', {{rl9, 0}}, value='a'}},
	sb.concadd(rl7_move_in, rl9_kiai_flashes(32*4,rl9,0.06),rl9_kiai_flashes(40*4,rl9,0.08),
	rl9_kiai_flashes(16*4,rl11,0.08),rl9_kiai_flashes(24*4,rl11,0.10),
	rl9_kiai_flashes(65*4,rl11,0.08),rl9_kiai_flashes(73*4,rl11,0.10),
	rl9_kiai_flashes(81*4,rl11,0.09),rl9_kiai_flashes(89*4,rl11,0.11)
))

local BGN={
	{'scale',0,{{rl11_comp,0}},2.1},
	{'color',0,{{rl11_comp,0}},{50,50,230}},
	{'color','cubicIn',{{rl11_comp,7*4},{rl11_comp,8*4}},{50,50,230},{50*1.3,50*1.2,230*1.12}},
	{'color','cubicout',{{rl11_comp,8*4},{rl11_comp,9*4}},{50*1.3,50*1.2,230*1.12}, {82,44,222}},
	{'color','cubicout',{{rl11,99*4}},{255,0,255}},
}
storyboard:newObject("sb/BGN1.jpg", "Background", "Centre", 320, 366):add(
	sb.concadd(rl11_noisefunc(1), BGN, rl11_noisefunc2(1)))
storyboard:newObject("sb/BGN2.jpg", "Background", "Centre", 320, 366):add(
	sb.concadd(rl11_noisefunc(2),BGN, rl11_noisefunc2(2)))
storyboard:newObject("sb/BGN3.jpg", "Background", "Centre", 320, 366):add(
	sb.concadd(rl11_noisefunc(3), BGN, rl11_noisefunc2(3)))
storyboard:newObject("sb/BGN4.jpg", "Background", "Centre", 320, 366):add(
	sb.concadd(rl11_noisefunc(4), BGN, rl11_noisefunc2(4)))
storyboard:newObject("sb/BGN5.jpg", "Background", "Centre", 320, 366):add(
	sb.concadd(rl11_noisefunc(5), BGN, rl11_noisefunc2(5)))
storyboard:newObject("sb/BGN6.jpg", "Background", "Centre", 320, 366):add(
	sb.concadd(rl11_noisefunc(6), BGN, rl11_noisefunc2(6)))

storyboard:newObject("sb/ReisenComposite1.png", "Background", "Centre", 320, 366):add(
	{'fade', 'cubicOut', {{rl11_comp,0},{rl11_comp,1*4}}, 0, 1},
	{'fade', 'cubicOut', {{rl11_comp,16*4},{rl11_comp,16*4}}, 0, 0}
)
storyboard:newObject("sb/ReisenComposite2.png", "Background", "Centre", 320, 366):add(
	{'fade', 'cubicOut', {{rl11_comp,0},{rl11_comp,1*4}}, 0, 1},
	{'color', 'linear', {{rl11_comp,0},{rl11_comp,0}}, {170*0.5,0,255*0.5}},
	{'color','cubicIn',{{rl11_comp,7*4},{rl11_comp,8*4}},{170*0.5,0,255*0.5},{170*0.8,0,255*0.8}},
	{'color','cubicOut',{{rl11_comp,8*4},{rl11_comp,9*4}},{170*0.8,0,255*0.8}, {190*0.5,0,255*0.5}},
	{'fade', 'cubicOut', {{rl11_comp,16*4-1},{rl11_comp,16*4}}, 1, 0}
)

local rl11_noise_cols = {
	{'color',0,{{rl11_comp,0}},{120,0,50}},
	{'color','cubicIn',{{rl11_comp,7*4},{rl11_comp,8*4}},{120,0,50},{120*1.5,0,50*1.5}},
	{'color','cubicOut',{{rl11_comp,8*4},{rl11_comp,9*4}},{120*1.5,0,50*1.5}, {102,0,21}},
	{'color','cubicOut',{{rl11_comp,15*4+2},{rl11_comp,16*4}},{102,0,21}, {194,0,95}},
}

storyboard:newObject("sb/Noise1.png", "Background", "Centre", 320, 366):add(
	sb.concadd(rl11_noisefunc(1), rl11_noise_cols))
storyboard:newObject("sb/Noise2.png", "Background", "Centre", 320, 366):add(
	sb.concadd(rl11_noisefunc(2), rl11_noise_cols))
storyboard:newObject("sb/Noise3.png", "Background", "Centre", 320, 366):add(
	sb.concadd(rl11_noisefunc(3), rl11_noise_cols))
storyboard:newObject("sb/Noise4.png", "Background", "Centre", 320, 366):add(
	sb.concadd(rl11_noisefunc(4), rl11_noise_cols))
storyboard:newObject("sb/Noise5.png", "Background", "Centre", 320, 366):add(
	sb.concadd(rl11_noisefunc(5), rl11_noise_cols))
storyboard:newObject("sb/Noise6.png", "Background", "Centre", 320, 366):add(
	sb.concadd(rl11_noisefunc(6), rl11_noise_cols))

storyboard:newObject("sb/ReisenComposite1.png", "Background", "Centre", 320, 366):add(
	{'fade', 'cubicOut', {{rl11,100*4-1}}, 0.0},
	{'fade', 'cubicOut', {{rl11,100*4-1}, {rl11,103*4}}, 1,0.0})
storyboard:newObject("sb/Reisen.png", "Background", "Centre", 320, 366):add(
	{'fade', 'cubicOut', {{rl11,99*4-1}}, 0.0},
	{'fade', 'cubicIn', {{rl11,99*4-1}, {rl11,99*4}}, 0.6,1},
	{'fade', 'cubicOut', {{rl11,100*4-1}, {rl11,101*4}}, 1,0.0},
	sb.concadd(rl7_move_in)
)

local function rl7_text_flash_func(X, str, rl)
	local rl=rl or rl7
	return function(out)
		local X=X*4
		out{'color',0,{{rl,X}}, {0,0,255}}
		X=X+1
		out{'color',0, {{rl,X}}, {0,255,0}}
		X=X+1
		out{'color',0, {{rl,X}}, {255,0,0}}
		X=X+1
		out{'color',0, {{rl,X}}, {0,0,255}}
		X=X+1
		out{'color',0, {{rl,X}}, {255,0,0}}
	end
end
local function rl9_text_color_transitions(X, rl)
	return {
		{'color', 'cubicOut', {{rl,(X+16)*4}, {rl,(X+16)*4+1}}, {0,0,255},{0,0,255}},
		{'color', 'cubicOut', {{rl,(X+20)*4}, {rl,(X+20)*4+1}}, {0,0,255},{0,255,0}},
		{'color', 'cubicOut', {{rl,(X+24)*4}, {rl,(X+24)*4+1}}, {0,255,0},{0,0,255}},
		{'color', 'cubicOut', {{rl,(X+28)*4}, {rl,(X+28)*4+1}}, {0,0,255},{255,0,0}}
	}
end
local rl9_text_kiai_negative = function(X, rl)
	local rl=rl or rl9
	return {
		{'color', 0, {{rl,X}}, {0,255,0}},
		{'color', 0, {{rl,X+8*4}, {rl,X+8*4+1}}, {0,255,0},{235,0,255}},
		{'color', 0, {{rl,X+16*4}, {rl,X+16*4+1}}, {235,0,255},{235,0,0}},
	}
end
local rl7_text = {240.0, sb.time:convert('24:24:359')}
storyboard:newObject("sb/m_a_d.png", "Foreground", "Centre", 242, 294):add(
	{'moverel', 1, { {rl7_text,3}, {rl7_text,3.5} }, {0, 0}, {33,0}},
	{'moverel', 0, { {rl7_text,3.5}, {rl7_text,4} }, {0, 0}, {17,0}},
	{'moverel', 1, { {rl7_text,4}, {rl7_text,25+4} }, {0, 0}, {24,0}},
	{'color', 0, { {rl7_text,3} }, {255,0,0} },
	{'fade', 1, { {rl7_text,3}, {rl7_text,5} }, 0   ,0.7 },
	{'scale',0, { {rl7_text,3}, {rl7_text,3} }, 0.58,0.58 },
	{'fade', 0, { {rl7_text,32-0.5}, {rl7_text,34-0.5} }, 0.7,0 },

	rl7_text_flash_func(19,0.4),
	rl7_text_flash_func(23,0.4)
)

storyboard:newObject("sb/invismoon.png", "Foreground", "Centre", 385, 330):add(
	{'moverel', 1, { {rl7_text,2+8}, {rl7_text,3.5+8} }, {0, 0}, {-43,0}},
	{'moverel', 0, { {rl7_text,3.5+8}, {rl7_text,5.2+8} }, {0, 0}, {-9,0}},
	{'moverel', 1, { {rl7_text,5.2+8}, {rl7_text,26+8} }, {0, 0}, {-18,0}},
	{'color', 0, { {rl7_text,2+8} }, {255,0,0} },
	{'fade', 1, { {rl7_text,2+8}, {rl7_text,5+8} }, 0   ,0.7 },
	{'scale',0, { {rl7_text,2+8}, {rl7_text,2+8} }, 0.54,0.54 },
	{'fade', 0, { {rl7_text,32.15-0.6}, {rl7_text,34.15-0.6} }, 0.7,0 },

	rl7_text_flash_func(19,0.4),
	rl7_text_flash_func(23,0.4)
)

storyboard:newObject("sb/imperishable_night.png", "Foreground", "Centre", 253, 375):add(
	{'moverel', 1, { {rl7_text,2+15}, {rl7_text,3.5+15} }, {0, 0}, {35,0}},
	{'moverel', 0, { {rl7_text,3.5+15}, {rl7_text,5.2+15} }, {0, 0}, {7,0}},
	{'moverel', 1, { {rl7_text,5.2+15}, {rl7_text,23+8} }, {0, 0}, {16,0}},
	{'color', 0, { {rl7_text,2+15} }, {255,0,0} },
	{'fade', 1, { {rl7_text,2+15}, {rl7_text,5+15} }, 0   ,0.7 },
	{'scale',0, { {rl7_text,2+15}, {rl7_text,2+15} }, 0.38,0.38 },
	{'fade', 0, { {rl7_text,32.3-0.6}, {rl7_text,34.3-0.6} }, 0.7,0 },

	rl7_text_flash_func(19,0.4),
	rl7_text_flash_func(23,0.4)
)
storyboard:newObject("sb/reisen.png", "Foreground", "Centre", 395, 407):add(
	{'move', 0, { {rl7_text,2+22} }, {395,407} },
	{'moverel', 1, { {rl7_text,2+22-0.5}, {rl7_text,3.5+22-0.5} }, {0, 0}, {-59,0}},
	{'moverel', 0, { {rl7_text,3.5+22-0.5}, {rl7_text,4.5+22-0.5} }, {0, 0}, {-07,0}},
	{'moverel', 1, { {rl7_text,4.5+22-0.5}, {rl7_text,34-0.5} }, {0, 0}, {-09,0}},
	{'color', 0, { {rl7_text,2+22} }, {255,0,0} },
	{'fade', 1, { {rl7_text,2+22}, {rl7_text,5+22} }, 0   ,0.7 },
	{'scale',0, { {rl7_text,2+22}, {rl7_text,2+22} }, 0.34,0.34 },
	{'fade', 0, { {rl7_text,32.45-0.6}, {rl7_text,34.45-0.6} }, 0.7,0 },

	rl7_text_flash_func(19,0.4),
	rl7_text_flash_func(23,0.4)
)
storyboard:newObject("sb/240bpm.png", "Foreground", "Centre", 320, 444):add(
	{'fade', 1, { {rl7,1*4}, {rl7,2*4} }, 0   ,0.8 },
	{'color', 0, { {rl7,1*4} }, {255,0,0} },
	{'scale',0, { {rl7,0}, {rl7,0} }, 0.47,0.47 },
	{'fade' ,'cubicOut', { {rl11,99*4+2},{rl11,101*4}}, 0.8, 0},

	rl7_text_flash_func(19,0.4),
	rl7_text_flash_func(23,0.4),

	rl7_text_flash_func(3,0.4,rl9),
	rl7_text_flash_func(7,0.4,rl9),
	rl7_text_flash_func(11,0.6,rl9),
	rl7_text_flash_func(15,0.6,rl9),

	rl7_text_flash_func(51+3,0.4,rl9),
	rl7_text_flash_func(51+7,0.4,rl9),
	rl7_text_flash_func(51+11,0.6,rl9),
	rl7_text_flash_func(51+15,0.6,rl9),

	{'color', 'linear', {{rl11_comp,0},{rl11_comp,0}}, {140,10,255}},
	{'color','cubicIn',{{rl11_comp,7*4},{rl11_comp,8*4}},{140,10,255},{190,20,255}},
	{'color','cubicOut',{{rl11_comp,8*4},{rl11_comp,9*4}},{190,20,255}, {190,20,255}},
	{'color','cubicout',{{rl11,99*4}},{255,0,255}},

	{'color', 0, {{rl11,65*4}}, {0,255,0}},
	{'color', 0, {{rl11,65*4+8*4}, {rl11,65*4+8*4+1}}, {0,255,0},{0,0,255}},
	{'color', 0, {{rl11,81*4}, {rl11,81*4+1}}, {0,0,255},{255,0,0}},
	{'color', 0, {{rl11,89*4}, {rl11,89*4+1}}, {255,0,0},{230,0,255}},
	{'color', 0, {{rl11,93*4}, {rl11,93*4+1}}, {230,0,255},{0,255,0}},

	sb.concadd(
		rl9_text_color_transitions(0,rl9),
		rl9_text_color_transitions(-16,rl11),
		rl9_text_color_transitions(49-16,rl11),
		rl9_text_kiai_negative(32*4,rl9),
		rl9_text_kiai_negative(16*4,rl11)
	)
)
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
-- Songe 5558485
--

local rl20 = {180.0, 1167774}

local rl20_move_in = {
	{'move', 'linear', {{rl20,0}}, {-107,50}},
	{'moverel', 'cubicout', {{rl20,0}, {rl20,1*4}}, {0,0}, {0,50}},
	{'moverel', 'cubicout', {{rl20,0}, {rl20,8*4}}, {0,0}, {0,119}}
}

storyboard:newObject("sb/RaikoS.jpg", "Background", "TopLeft", -107, 50):add(
	{'scale', 'linear', {{rl20,0}}, 0.667},
	{'fade','cubicout', {{rl20,0},{rl20,0.5}}, 0,0.6},
	{'fade','cubicout', {{rl20,0.5},{rl20,4*4}}, 0.6,0.7},
	{'fade','quintOut', {{rl20,4*4},{rl20,4*6}}, 0.7,1.0},
	{'fade','cubicout', {{rl20,8*4},{rl20,8*4}}, 0},
	sb.concadd(rl20_move_in)
)

storyboard:newObject("sb/Raiko1.jpg", "Background", "TopLeft", -107, 50):add(
	{'scale', 'linear', {{rl20,0}}, 0.667},
	{'fade','cubicout', {{rl20,8*4-0.5},{rl20,8*4}}, 0,1},
	{'fade','cubicout', {{rl20,44*4-0.5},{rl20,44*4}}, 1,0},
	sb.concadd(rl20_move_in)
)

storyboard:newObject("sb/RaikoFlash.png", "Background", "TopLeft", -107, 50):add(
	Flash({rl20,0}, 800, 0.9, 0.1),
	Flash({rl20,2*4}, 500, 0.4, 0.3),
	Flash({rl20,6*4}, 500, 0.3, 0.3),
	Flash({rl20,7*4}, 500, 0.2, 0.3),
	Flash({rl20,8*4}, 800, 0.9, 0.1),
	Flash({rl20,16*4}, 1600, 0.9, 0.1),
	sb.concadd(rl20_move_in)
)

local rl20_text = {180.0, 1167774}
storyboard:newObject("sb/v_h.png", "Foreground", "Centre", 242, 294):add(
	{'moverel', 1, { {rl20_text,3}, {rl20_text,3.5} }, {0, 0}, {33,0}},
	{'moverel', 0, { {rl20_text,3.5}, {rl20_text,4} }, {0, 0}, {17,0}},
	{'moverel', 1, { {rl20_text,4}, {rl20_text,25+4} }, {0, 0}, {24,0}},
	{'fade', 1, { {rl20_text,3}, {rl20_text,5} }, 0   ,0.9 },
	{'scale',0, { {rl20_text,3}, {rl20_text,3} }, 0.58,0.58 },
	{'fade', 0, { {rl20_text,32-0.5}, {rl20_text,34-0.5} }, 0.9,0 }
)

storyboard:newObject("sb/pristine.png", "Foreground", "Centre", 385, 344):add(
	{'moverel', 1, { {rl20_text,2+8}, {rl20_text,3.5+8} }, {0, 0}, {-43,0}},
	{'moverel', 0, { {rl20_text,3.5+8}, {rl20_text,5.2+8} }, {0, 0}, {-9,0}},
	{'moverel', 1, { {rl20_text,5.2+8}, {rl20_text,26+8} }, {0, 0}, {-18,0}},
	{'fade', 1, { {rl20_text,2+8}, {rl20_text,5+8} }, 0   ,0.9 },
	{'scale',0, { {rl20_text,2+8}, {rl20_text,2+8} }, 0.51,0.51 },
	{'fade', 0, { {rl20_text,32.15-0.6}, {rl20_text,34.15-0.6} }, 0.9,0 }
)

storyboard:newObject("sb/double.png", "Foreground", "Centre", 253, 393):add(
	{'moverel', 1, { {rl20_text,2+15}, {rl20_text,3.5+15} }, {0, 0}, {35,0}},
	{'moverel', 0, { {rl20_text,3.5+15}, {rl20_text,5.2+15} }, {0, 0}, {7,0}},
	{'moverel', 1, { {rl20_text,5.2+15}, {rl20_text,23+8} }, {0, 0}, {16,0}},
	{'fade', 1, { {rl20_text,2+15}, {rl20_text,5+15} }, 0   ,0.9 },
	{'scale',0, { {rl20_text,2+15}, {rl20_text,2+15} }, 0.40,0.40 },
	{'fade', 0, { {rl20_text,32.3-0.6}, {rl20_text,34.3-0.6} }, 0.9,0 }
)

storyboard:newObject("sb/raikohorikawa.png", "Foreground", "Centre", 395, 424):add(
	{'moverel', 1, { {rl20_text,2+22-0.5}, {rl20_text,3.5+22-0.5} }, {0, 0}, {-59,0}},
	{'moverel', 0, { {rl20_text,3.5+22-0.5}, {rl20_text,4.5+22-0.5} }, {0, 0}, {-07,0}},
	{'moverel', 1, { {rl20_text,4.5+22-0.5}, {rl20_text,34-0.5} }, {0, 0}, {-09,0}},
	{'fade', 1, { {rl20_text,2+22}, {rl20_text,5+22} }, 0   ,0.9 },
	{'scale',0, { {rl20_text,2+22}, {rl20_text,2+22} }, 0.34,0.34 },
	{'fade', 0, { {rl20_text,32.45-0.6}, {rl20_text,34.45-0.6} }, 0.9,0 }
)

storyboard:newObject("sb/180bpm_r.png", "Foreground", "Centre", 320, 443):add(
	{'fade', 1, { {rl20_text,2+22}, {rl20_text,5+22} }, 0   ,0.9 },
	{'scale',0, { {rl20_text,0}, {rl20_text,0} }, 0.47,0.47 },
	{'fade' ,'cubicOut', { {rl20,206*4},{rl20,208*4}}, 0.9, 0}
)

storyboard:writeToFile2()
