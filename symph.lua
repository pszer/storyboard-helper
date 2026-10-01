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

local function FlashScale(time,dur,strength,peak)
	local T = sb.time:convert(time)
	return function (out)
		out{'scalerel',1,{T,T+dur*peak},1,1+strength}
		out{'scalerel',1,{T+dur*peak,T+dur},1,1/(1+strength)}
	end
end

local rl1 = {190,57822}
local rl2 = {190,281400}

local s1_bpm_flashes = {}

storyboard:newObject("sb/190bpm.png", "Foreground", "Centre", 320, 437):add(
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

storyboard:newObject("sb/E3.jpg", "Background", "TopLeft", -107, 249):add(
	{'scale',0, { "0:57:722", "0:57:882"}, 0.667, 0.667},
	{'color',0, { "0:57:722", "0:57:882"}, {241,241,241}, {241,241,241}},
	{'fade', 1, { "0:57:822", "0:59:053" }, 0,0.85 },
	{'fade', 0, { "0:59:053", "1:01:453" }, 0.85,1 },
	{'fade', 'quintIn', { {rl1,32}, {rl1,33} }, 1,0 }
)

storyboard:newObject("sb/E5.jpg", "Background", "TopLeft", -106.7, 249):add(
	{'scale',0 , { {rl1,16*4}, {rl1,16*4} }, 0.6675, 0.6675},
	{'fade', 1,  { {rl1,16*4}, {rl1,16*4} }, 1,1 },
	{'fade', 1, { {rl1,24*4}, {rl1,24*4} }, 0,0 },
	{'fade', 1,  { {rl1,49*4}, {rl1,49*4} }, 1,1 },
	{'fade', 'quintIn', { {rl1,74*4}, {rl1,74*4} }, 0,0 },
	{'fade', 1,  { {rl1,91*4}, {rl1,91*4} }, 1,1 },
	{'fade', 'quintIn', { {rl1,108*4}, {rl1,108*4} }, 0,0 },

	{'fade', 1,  { {rl1,142*4}, {rl1,142*4} }, 1,1 },
	{'fade', 'quintIn', { {rl1,146*4}, {rl1,146*4} }, 0,0 },
	
	{'fade', 1,  { {rl1,150*4}, {rl1,150*4} }, 1,1 },
	{'fade', 'quintIn', { {rl1,167*4}, {rl1,167*4} }, 0,0 },

	{'fade', 1, { {rl2, 33*4}, {rl2,33*4} }, 1,1 },
	{'fade', 'linear', { {rl2, 41*4}, {rl2,43*4} }, 1,0 }
)

storyboard:newObject("sb/E3.jpg", "Background", "TopLeft", -106.7, 249):add(
	{'scale',0 , { {rl1,125*4}, {rl1,125*4} }, 0.6675, 0.6675},
	{'fade', 1,  { {rl1,124*4}, {rl1,125*4} }, 1,1 },
	{'fade', 'quintOut',  { {rl1,127*4}, {rl1,127*4} }, 0,0 }
)

storyboard:newObject("sb/E4.jpg", "Background", "TopLeft", -106.7, 249):add(
	{'scale',0, { {rl1,32}, {rl1,33} }, 0.6675, 0.6675},
	{'color',0, { {rl1,32}, {rl1,33} }, {245,245,245}, {245,245,245}},
	{'fade', 1, { {rl1,32}, {rl1,33} }, 0,1 },

	{'fade', 'quintOut', { {rl1,16*4}, {rl1,17*4} }, 1,0 },
	{'fade', 1, { {rl1,23*4}, {rl1,24*4} }, 0,1 },
	{'fade', 'quintOut', { {rl1,49*4}, {rl1,50*4} }, 1,0 },
	{'fade', 1, { {rl1,73*4}, {rl1,74*4} }, 0,1 },
	{'color',1, { {rl1,73*4},{rl1,73*4} }, {210,210,210}, {210,210,210}},
	{'color',1, { {rl1,74*4},{rl1,74*4+2} }, {210,210,210}, {245,245,245}},

	{'fade', 'quintOut', { {rl1,91*4}, {rl1,91*4} }, 1,0 },
	{'fade', 1, { {rl1,107*4}, {rl1,108*4} }, 0,1 },

	{'fade', 'quintOut',  { {rl1,125*4}, {rl1,125*4+1-0.25} }, 1,0.3 },
	{'fade', 'quintIn',  { {rl1,126*4-1}, {rl1,126*4} }, 0.3,1 },

	{'fade', 'quintOut', { {rl1, 142*4}, {rl1,142*4+4} }, 1,0 },
	{'fade', 1, { {rl1,145*4+2}, {rl1,146*4} }, 0,1 },

	{'fade', 'quintOut', { {rl1, 150*4}, {rl1,150*4+4} }, 1,0 },
	{'fade', 1, { {rl1,166*4}, {rl1,167*4} }, 0,1 },

	{'color',1, { {rl1,91*4},{rl1,91*4+2} }, {240,240,240}, {255,255,255}},
	{'color',2, { {rl1,176*4},{rl1,178*4+3} }, {255,255,255}, {140,140,140}},
	--{'color',1, { {rl2,1*4},{rl2,1*4+2} }, {190,190,190}, {255,255,255}},
	{'fade', 'quintIn', { {rl2,1*4},{rl2,1*4+4} }, 1.0,0 }
)

storyboard:newObject("sb/E6.jpg", "Background", "TopLeft", -106.7, 249):add(
	{'scale',0 , { {rl2, 1*4}, {rl2, 1*4} }, 0.6675, 0.6675},
	{'color',0 , { {rl2, 1*4}, {rl2, 1*4} }, {247,247,247}, {247,247,247}},
	{'color',1 , { {rl2, 9*4}, {rl2, 9*4+1} }, {247,247,247}, {255,255,255}},
	{'fade' ,1 , { {rl2, 1*4}, {rl2, 1*4+2} }, 0,0.93 },
	{'fade' ,1 , { {rl2, 1*4+2}, {rl2, 2*4+2} }, 0.93,1 },
	{'fade', 'quintOut', { {rl2, 33*4}, {rl2,34*4} }, 1,0 }
)
storyboard:newObject("sb/E5.jpg", "Foreground", "TopLeft", -106.7, 249):add(
	{'scale',0, {{rl2,4},{rl2,4}}, 0.667, 0.667},
	{'protract', {'parameter', { {rl2, 4}, {rl2, 4} }, value='a'}},
	Flash({rl2, 4},1200, 0.2, 0.1),
	Flash({rl2, 5*4},1200, 0.2, 0.1),
	Flash({rl2, 9*4},1200, 0.2, 0.1),
	Flash({rl2, 13*4},1200, 0.2, 0.1),
	Flash({rl2, 15*4},1200, 0.2, 0.1),
	Flash({rl2, 17*4},1200, 0.2, 0.1)
)

storyboard:newObject("sb/E3.jpg", "Foreground", "TopLeft", -107, 249):add(
	{'scale',0, {{rl1,0},{rl1,0}}, 0.667, 0.667},
	{'protract', {'parameter', { {rl1, 0}, {rl1, 0} }, value='a'}},
	Flash({rl1, 0},280, 0.4, 0.25),
	Flash({rl1, 1},800, 0.45, 0.1),
	Flash({rl1, 8},280, 0.1, 0.25),
	Flash({rl1, 9},800, 0.15, 0.1),
	Flash({rl1, 16},280, 0.1, 0.25),
	Flash({rl1, 17},800, 0.15, 0.1),

	Flash({rl1, 24},280, 0.1, 0.25),
	Flash({rl1, 25},280, 0.09, 0.1),

	Flash({rl1, 26},280, 0.10, 0.25),
	Flash({rl1, 27},280, 0.11, 0.25),
	Flash({rl1, 28},280, 0.12, 0.25),
	Flash({rl1, 29},280, 0.13, 0.25),
	Flash({rl1, 30},350, 0.14, 0.25)
)

storyboard:newObject("sb/E4.jpg", "Foreground", "TopLeft", -107, 249):add(
	{'protract', {'parameter', { {rl1, 49*4}, {rl1, 49*4} }, value='a'}},	
	{'scale', 0, { {rl1,49*4}, {rl1,49*4} }, 0.6675, 0.6675},
	Flash({rl1, 49*4},800, 0.25, 0.1),
	Flash({rl1, 54*4},800, 0.25, 0.1)
)

local rl3 = {180.0,338600}

--- Songe 2
---
---
---
storyboard:newObject("sb/laplace.jpg", "Background", "TopLeft", -107, 230):add(
	{'scale', 0, { {rl3,0*4-1}, {rl3,0*4-1} }, 0.6675, 0.6675},
	{'moverel', 1, { {rl3,0*4-1.25}, {rl3,0*4} }, {0,0}, {0,10}},
	{'moverel', 1, { {rl3,0*4}, {rl3,2*4} }, {0,0}, {0,9}},
	{'fade', 1, { {rl3,0*4-1.25}, {rl3,0*4-0} }, 0.0, 0.5},
	{'fade', 1, { {rl3,2*4}, {rl3,2*4} }, 0, 0}
)

storyboard:newObject("sb/rem1.jpg", "Background", "TopLeft", -107, 249):add(
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
	{'fade', 'quartIn', { {rl3,224*4}, {rl3,225*4} }, 1,0 }
)

storyboard:newObject("sb/rem2.jpg", "Background", "TopLeft", -107, 230):add(
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

storyboard:newObject("sb/rem2high.png", "Background", "TopLeft", -107, 230):add(
	{'scale', 0, { {rl3,0*4-1}, {rl3,0*4-1} }, 0.6675, 0.6675},
	{'moverel', 1, { {rl3,0*4-1.25}, {rl3,0*4} }, {0,0}, {0,10}},
	{'moverel', 1, { {rl3,0*4}, {rl3,2*4} }, {0,0}, {0,9}},
	{'fade', 'quartIn', { {rl3,0*4-0.75}, {rl3,0.5} }, 0, 0.7},
	{'fade', 'quartIn', { {rl3,8*4-0.6}, {rl3,8*4+0.1} }, 0.7, 0}
)

storyboard:newObject("sb/rem3.jpg", "Background", "TopLeft", -107, 249):add(
	{'scale', 0, { {rl3,140*4}, {rl3,140*4} }, 0.6675, 0.6675},
	{'fade', 2, { {rl3,140*4-0.5}, {rl3,140*4} }, 0, 1},
	{'fade', 2, { {rl3,149*4}, {rl3,149*4} }, 0, 0},


	{'fade', 2, { {rl3,156*4-0.5}, {rl3,156*4} }, 1, 1},
	{'fade', 2, { {rl3,165*4}, {rl3,165*4} }, 0, 0}
)

storyboard:newObject("sb/rem3.jpg", "Foreground", "TopLeft", -107, 249):add(
	{'scale', 0, { {rl3,156*4}, {rl3,156*4} }, 0.6675, 0.6675},
	{'protract', {'parameter', { {rl3, 156*4}, {rl3, 156*4} }, value='a'}},
	Flash({rl3,156*4}, 1600, 0.3, 0.08),
	Flash({rl3,160*4}, 1600, 0.2, 0.08)
)
storyboard:newObject("sb/rem4.jpg", "Background", "TopLeft", -107, 249):add(
	{'scale', 0, { {rl3,148*4}, {rl3,148*4} }, 0.6675, 0.6675},
	{'fade', 2, { {rl3,148*4-0.5}, {rl3,148*4} }, 0, 1},
	{'fade', 2, { {rl3,156*4-0.5}, {rl3,156*4} }, 1, 0},
	{'fade', 2, { {rl3,164*4-0.5}, {rl3,164*4} }, 0, 1},

	{'fade', 0, { {rl3,173*4}, {rl3,174*4-0.25} }, 1, 0.9},
	{'fade', 2, { {rl3,174*4-0.25}, {rl3,174*4+0.25} }, 0.9, 0}
)

storyboard:newObject("sb/rem4.jpg", "Foreground", "TopLeft", -107, 249):add(
	{'scale', 0, { {rl3,164*4}, {rl3,164*4} }, 0.6675, 0.6675},
	{'protract', {'parameter', { {rl3, 164*4}, {rl3, 164*4} }, value='a'}},
	Flash({rl3,164*4}, 1600, 0.3, 0.08),
	Flash({rl3,168*4}, 1600, 0.2, 0.08),
	Flash({rl3,172*4}, 1600, 0.2, 0.08)
)

storyboard:newObject("sb/remFlash.jpg", "Foreground", "TopLeft", -107, 230):add(
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
	Flash({rl3,216*4}, 1200, 0.15, 0.08)
)

storyboard:newObject("sb/rem2.jpg", "Foreground", "TopLeft", -107, 249):add(
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

storyboard:newObject("sb/laplace.jpg", "Foreground", "TopLeft", -107, 249):add(
	{'scale', 0, { {rl3, 127*4}, {rl3, 127*4} }, 0.6675, 0.6675},
	Flash({rl3,127*4}, 2800, 1.0, 0.05))

storyboard:newObject("sb/180bpm.png", "Foreground", "Centre", 318, 435):add(
	{'fade', 1, { {rl3,2+22}, {rl3,5+22} }, 0   ,1.0 },
	{'scale',0, { {rl3,2+22}, {rl3,5+22} }, 0.34,0.34 },
	{'fade', 0, { "10:39:933", "10:39:933" }, 1,0 }
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

storyboard:newObject("sb/eosd_.png", "Foreground", "Centre", 253, 402):add(
	{'moverel', 1, { {rl3,2+15}, {rl3,3.5+15} }, {0, 0}, {35,0}},
	{'moverel', 0, { {rl3,3.5+15}, {rl3,5.2+15} }, {0, 0}, {7,0}},
	{'moverel', 1, { {rl3,5.2+15}, {rl3,23+8} }, {0, 0}, {16,0}},
	{'fade', 1, { {rl3,2+15}, {rl3,5+15} }, 0   ,1.0 },
	{'scale',0, { {rl3,2+15}, {rl3,2+15} }, 0.27,0.27 },
	{'fade', 0, { {rl3,32.3-0.6}, {rl3,34.3-0.6} }, 1.0,0 }
)

storyboard:writeToFile2()
