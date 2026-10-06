package.path = "./?.lua;./?/init.lua;" .. package.path
local sb = require('sbhelper')

storyboard = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/1876396 Yuzuki - Dear You (DJ Genericname DnB Remix)/Yuzuki - Dear You (DJ Genericname DnB Remix) (NekuMagetsu).osb")
sb.file:setProjectFolder("/home/quake/.local/share/osu-wine/osu!/Songs/1876396 Yuzuki - Dear You (DJ Genericname DnB Remix)/")

--tsarbomba = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/1876396 Yuzuki - Dear You (DJ Genericname DnB Remix)/tsarbomba_events.osb")
nekumagetsu = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/1876396 Yuzuki - Dear You (DJ Genericname DnB Remix)/nekumagetsu_events.osb")
suisei69 = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/1876396 Yuzuki - Dear You (DJ Genericname DnB Remix)/suisei69_events.osb")
theshadowofdark = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/1876396 Yuzuki - Dear You (DJ Genericname DnB Remix)/theshadowofdark_events.osb")
keywee = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/1876396 Yuzuki - Dear You (DJ Genericname DnB Remix)/keywee_events.osb")
--projectgreat = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/1876396 Yuzuki - Dear You (DJ Genericname DnB Remix)/projectgreat_events.osb")

local function Flash(time,dur,strength,peak, ease)
	ease = ease or 1
	local T = sb.time:convert(time)
	return function (out)
		out{'fade',ease,{T,T+dur*peak},0,strength}
		out{'fade',ease,{T+dur*peak,T+dur},strength,0}
	end
end

storyboard:newObject("1.jpg", "Background", "Center", 320, 240):add(
	{'fade', 0, { -500, -500 }, 0,0 })
storyboard:newObject("2.jpg", "Background", "Center", 320, 240):add(
	{'fade', 0, { -500, -500 }, 0,0 })
storyboard:newObject("3.jpg", "Background", "Center", 320, 240):add(
	{'fade', 0, { -500, -500 }, 0,0 })

local T = {174.100,35}
local BG_S = 854/1920

local Scale_in = {
	{'scalerel', 'cubicout', {{T,0}, {T,8*4}}, 1.06, 0.98},
	{'scalerel', 'out', {{T,8*4}, {T,8*4+0.5}}, 1.0, 1/0.98},

	{'scalerel', 'cubicout', {{T,8*4+0.5}, {T,24*4}}, 1.00, 0.99},
	{'scalerel', 'out', {{T,24*4}, {T,24*4+0.5}}, 1.0, 1/0.99},

	{'scalerel', 'cubicout', {{T,24*4+0.5}, {T,48*4}}, 1.00, 0.998},
	{'scalerel', 'out', {{T,48*4}, {T,48*4+0.5}}, 1.0, 1/0.998},

	{'scalerel', 'cubicout', {{T,48*4+0.5}, {T,56*4}}, 1.00, 0.99},
	{'scalerel', 'out', {{T,56*4}, {T,56*4+0.5}}, 1.0, 1/0.99},

	{'scalerel', 'cubicout', {{T,56*4+0.5}, {T,64*4}}, 1.00, 0.99},
	{'scalerel', 'out', {{T,64*4}, {T,64*4+1}}, 1.0, 1/0.99},

	{'scalerel', 'cubicout', {{T,64*4+0.5}, {T,72*4}}, 1.00, 0.99},
	{'scalerel', 'out', {{T,72*4}, {T,72*4+0.5}}, 1.0, 1/0.99}
}

local GRAY = function(X) return {X*255,X*255,X*255} end
storyboard:newObject("sb/1gamma.jpg", "Background", "Centre", 320,240):add(
	{'scale', 0, {{T,0}},  1},
	{'fade', 0, {{T,0}},  1},
	{'color', 'cubicOut', {{T,0},{T,4}},  GRAY(0), GRAY(0.8)},
	{'fade', 0, {{T,8*4}},  0},
	sb.concadd(Scale_in)
)

local Norm1 ={
	{'scale', 0, {{T,0}},  BG_S},
	{'fade', 0, {{T,0}},  1},
	{'color', 0, {{T,0}},  GRAY(0.55)},
	{'fade', 'In', {{T,0},{T,2}},  0,0.2},
	{'fade', 'Out', {{T,2},{T,4*4}},  0.2,0.8},
	{'color', 'cubicin', {{T,8*4-2},{T,8*4-1}},  GRAY(0.55), GRAY(0.75)},
	{'fade', 'CubicIn', {{T,8*4-2},{T,8*4-1}},  0.8,1.0},
	{'color', 'cubicout', {{T,8*4},{T,8*4+1}},  GRAY(0.75), GRAY(0.9)},
	{'fade', 0, {{T,24*4},{T,24*4}},  0},
	{'fade', 0, {{T,40*4+0.5},{T,40*4+0.5}},  1},
	{'color', 'cubicOut', {{T,40*4+1.0},{T,40*4+1.0}}, GRAY(0.6), GRAY(0.8)},
	{'fade', 0, {{T,64*4},{T,64*4}},  0},
	{'color', 'cubicOut', {{T,46*4},{T,46*4+4}}, GRAY(0.8), GRAY(0.55)},
	{'color', 'cubicOut', {{T,48*4},{T,49*4-2}}, GRAY(0.5), GRAY(0.68)},
	{'color', 'cubicOut', {{T,50*4},{T,55*4-2}}, GRAY(0.68), GRAY(0.75)},
	{'color', 'cubicOut', {{T,55*4},{T,56*4}}, GRAY(0.75), GRAY(0.85)},
	{'color', 'cubicOut', {{T,56*4},{T,56*4+1}}, GRAY(0.85), GRAY(1)},


	{'color', 'cubicOut', {{T,56*4+1},{T,56*4+4}}, GRAY(1), GRAY(0.95)},
}
nekumagetsu:newObject("1.jpg", "Background", "Centre", 320,240):add(
	sb.concadd(Scale_in, Norm1)
)
theshadowofdark:newObject("1.jpg", "Background", "Centre", 320,240):add(
	sb.concadd(Scale_in, Norm1)
)

local Alt1 = {
	{'scale', 0, {{T,0}},  BG_S},
	{'fade', 0, {{T,0}},  1},
	{'color', 0, {{T,0}},  GRAY(0.55)},
	{'fade', 'In', {{T,0},{T,2}},  0,0.2},
	{'fade', 'Out', {{T,2},{T,4*4}},  0.2,0.8},
	{'color', 'cubicin', {{T,8*4-2},{T,8*4-1}},  GRAY(0.55), GRAY(0.75)},
	{'fade', 'CubicIn', {{T,8*4-2},{T,8*4-1}},  0.8,1.0},
	{'color', 'cubicout', {{T,8*4},{T,8*4+1}},  GRAY(0.75), GRAY(0.9)},
	{'fade', 0, {{T,24*4},{T,24*4}},  0},
	{'fade', 0, {{T,40*4+0.5},{T,40*4+0.5}},  1},
	{'color', 'cubicOut', {{T,40*4+1.0},{T,40*4+1.0}}, GRAY(0.6), GRAY(0.8)},
	{'fade', 0, {{T,64*4},{T,64*4}},  0},
	{'color', 'cubicOut', {{T,41*4},{T,46*4+4}}, GRAY(0.8), GRAY(0.66)},
	{'color', 'cubicOut', {{T,48*4},{T,49*4-2}}, GRAY(0.66), GRAY(0.75)},
	{'color', 'cubicOut', {{T,50*4},{T,55*4-2}}, GRAY(0.75), GRAY(0.85)},
	{'color', 'cubicOut', {{T,55*4},{T,56*4}}, GRAY(0.85), GRAY(0.90)},
	{'color', 'cubicOut', {{T,56*4},{T,56*4+1}}, GRAY(0.90), GRAY(1)},
	{'color', 'cubicOut', {{T,56*4+1},{T,56*4+4}}, GRAY(1), GRAY(0.95)},
}
keywee:newObject("1.jpg", "Background", "Centre", 320,240):add(
	sb.concadd(Scale_in, Alt1)
)
suisei69:newObject("1.jpg", "Background", "Centre", 320,240):add(
	sb.concadd(Scale_in, Alt1)
)

storyboard:newObject("2.jpg", "Background", "Centre", 320,240):add(
	{'scale', 0, {{T,24*4-2}},  BG_S},
	{'color', 0, {{T,24*4-2}},  GRAY(1.0)},
	{'fade', 'cubicIn', {{T,24*4-2}, {T,24*4}},  0, 1},
	{'color', 'sineOut', {{T,40*4}, {T,40*4+2}},  GRAY(1.0),GRAY(0.7)},
	{'fade', 'in', {{T,40*4+0.5}, {T,40*4+5.0}},  1, 0.4},
	{'fade', 'out', {{T,40*4+5}, {T,40*4+6.5}},  0.4, 0},
	sb.concadd(Scale_in)
)
storyboard:newObject("sb/EndFade.jpg", "Background", "Centre", 320,240):add(
	{'scale', 0, {{T,80*4}},  1.0},
	{'fade', 0, {{T,80*4}}, 0},
	{'fade', 0, {{T,80*4}, {T,80*4+2}}, 1,0.8},
	{'fade', 'cubicOut', {{T,80*4+2}, {T,80*4+12.0}}, 0.8, 0},
	sb.concadd(Scale_in)
)
storyboard:newObject("3.jpg", "Background", "Centre", 320,240):add(
	{'scale', 0, {{T,64*4-2}},  BG_S},
	{'color', 0, {{T,64*4-2}},  GRAY(1.0)},
	{'fade', 'cubicIn', {{T,64*4-2}, {T,64*4}},  0, 1},
	{'fade', 'cubicOut', {{T,80*4}, {T,80*4+4.0}},  1, 0},
	sb.concadd(Scale_in)
)

local CircFlashAttribute = {
	{'fade', 0, {{T,8*4}}, 0},
	{'scale', 0, {{T,8*4}}, 2},
	{'move', 0, {{T,8*4}}, {320,240-31}},
}

local CircFlash1_2 = storyboard:newObject('sb/2_CircFlash1.png','Foreground','Centre',320,240):add(
sb.concadd(Scale_in,CircFlashAttribute))
local CircFlash2_2 = storyboard:newObject('sb/2_CircFlash2.png','Foreground','Centre',320,240):add(
sb.concadd(Scale_in,CircFlashAttribute))
local CircFlash3_2 = storyboard:newObject('sb/1_CircFlash3.png','Foreground','Centre',320,240):add(
sb.concadd(Scale_in,CircFlashAttribute))
local CircFlash4_2 = storyboard:newObject('sb/1_CircFlash4.png','Foreground','Centre',320,240):add(
sb.concadd(Scale_in,CircFlashAttribute))


local CircFlash1_3 = storyboard:newObject('sb/3_CircFlash1.png','Foreground','Centre',320,240):add(
sb.concadd(Scale_in,CircFlashAttribute))
local CircFlash2_3 = storyboard:newObject('sb/3_CircFlash2.png','Foreground','Centre',320,240):add(
sb.concadd(Scale_in,CircFlashAttribute))
local CircFlash3_3 = storyboard:newObject('sb/1_CircFlash3.png','Foreground','Centre',320,240):add(
sb.concadd(Scale_in,CircFlashAttribute))
local CircFlash4_3 = storyboard:newObject('sb/1_CircFlash4.png','Foreground','Centre',320,240):add(
sb.concadd(Scale_in,CircFlashAttribute))
local CircFlash1_1 = storyboard:newObject('sb/1_CircFlash1.png','Foreground','Centre',320,240):add(
sb.concadd(Scale_in,CircFlashAttribute))
local CircFlash2_1 = storyboard:newObject('sb/1_CircFlash2.png','Foreground','Centre',320,240):add(
sb.concadd(Scale_in,CircFlashAttribute))
local CircFlash3_1 = storyboard:newObject('sb/1_CircFlash3.png','Foreground','Centre',320,240):add(
sb.concadd(Scale_in,CircFlashAttribute))
local CircFlash4_1 = storyboard:newObject('sb/1_CircFlash4.png','Foreground','Centre',320,240):add(
sb.concadd(Scale_in,CircFlashAttribute))

local Circ1 = {
	CircFlash1_1, CircFlash2_1, CircFlash3_1, CircFlash_4_1 }
local Circ2 = {
	CircFlash1_2, CircFlash2_2, CircFlash3_2, CircFlash_4_2 }
local Circ3 = {
	CircFlash1_3, CircFlash2_3, CircFlash3_3, CircFlash_4_3 }

local function CircFlash_at(X, str, dur, circ)
	local Int = dur/4.0
	local e = 'linear'
	X=X*4

	Int = Int*0.4
	local Offset = Int*0.5
	circ[1]:add(
		{'fade',e,{{T,X}, {T,X+Offset}},0,str*0.8},
		{'protract', {'param', {{T,X}}, value='a'}},
		{'fade',e,{{T,X+Int}, {T,X+Int+(1.5*Int)}},str*0.8,0}
	)
	X=X+Int
	Int = Int
	circ[2]:add(
		{'fade',e,{{T,X}, {T,X+Offset}},0,str*0.33},
		{'protract', {'param', {{T,X}}, value='a'}},
		{'fade',e,{{T,X+Int*1.2}, {T,X+Int+(1.8*Int)}},str*0.33,0}
	)
	X=X+Int
	Int= Int/0.5
	Offset = Int*0.5
	circ[3]:add(
		{'fade',e,{{T,X}, {T,X+Offset*1}},0,str*0.25},
		{'protract', {'param', {{T,X}}, value='a'}},
		{'fade',e,{{T,X+Int}, {T,X+Int+(2*Int)}},str*0.25,0}
	)
	X=X+Int
	Int= Int/0.95
	CircFlash4_1:add(
		{'fade',e,{{T,X}, {T,X+Offset*1.3}},0,str*0.25},
		{'protract', {'param', {{T,X}}, value='a'}},
		{'fade',e,{{T,X+Int}, {T,X+Int+(2*Int)}},str*0.25,0}
	)
end

local kiai1_flashes = {}
local kiai2_flashes = {}
local kiai3_flashes = {}
for i=8*4+2, 16*4-2, 2 do
	table.insert(kiai1_flashes, Flash({T,i}, 550, 0.08, 0.2))
end
for i=16*4+2, 24*4-2, 2 do
	table.insert(kiai1_flashes, Flash({T,i}, 550, 0.08, 0.2))
end

for i=24*4+4, 40*4-4, 4 do
	if i~=32*4 then
		table.insert(kiai2_flashes, Flash({T,i}, 550, 0.15, 0.2))
	end
end

for i=64*4+2, 72*4-1, 2 do
	table.insert(kiai3_flashes, Flash({T,i}, 360, 0.08, 0.2))
end
for i=72*4+2, 80*4-1, 2 do
	table.insert(kiai3_flashes, Flash({T,i}, 360, 0.13, 0.2))
end

table.insert(kiai2_flashes, Flash({T,39*4+2}, 550, 0.18, 0.2))
storyboard:newObject("sb/1CloudFlash.jpg", "Background", "Centre", 320,240):add(
	{'scale', 0, {{T,8*4}}, 0.99},
	{'protract', {'param', {{T,8*4}}, value='a'}},
	Flash({T,8*4}, 550, 0.4, 0.1),
	Flash({T,16*4}, 550, 0.4, 0.1),
	Flash({T,48*4}, 550*2, 0.45, 0.2),
	Flash({T,56*4}, 550*2, 0.2, 0.2),

	Flash({T,60*4}, 550*2, 0.12, 0.1),
	Flash({T,61*4}, 550*2, 0.17, 0.1),
	Flash({T,62*4}, 550, 0.2, 0.2),
	Flash({T,62*4+2}, 550, 0.2, 0.2),
	Flash({T,62*4+4}, 320, 0.2, 0.2),
	Flash({T,62*4+5}, 320, 0.2, 0.2),
	Flash({T,62*4+6}, 320, 0.3, 0.1),
	Flash({T,62*4+7}, 320, 0.2, 0.2),


	Flash({T,49*4}, 850, 0.10, 0.2),
	Flash({T,50*4}, 850, 0.085, 0.2),
	Flash({T,51*4}, 850, 0.07, 0.2),
	Flash({T,52*4}, 850, 0.10, 0.2),
	Flash({T,53*4}, 850, 0.085, 0.2),
	Flash({T,54*4}, 850, 0.07, 0.2),
	Flash({T,55*4}, 850, 0.10, 0.2),
	Flash({T,55*4+3}, 250, 0.15, 0.35),

	sb.concadd(Scale_in, kiai1_flashes)
)
storyboard:newObject("sb/2CloudFlash.jpg", "Background", "Centre", 320,240):add(
	{'scale', 0, {{T,24*4}}, 0.99},
	{'protract', {'param', {{T,24*4}}, value='a'}},
	Flash({T,24*4}, 550, 0.3, 0.1),
	Flash({T,32*4}, 550, 0.3, 0.1),
	Flash({T,40*4}, 850, 0.3, 0.1),
	Flash({T,80*4}, 550*3, 0.45, 0.2),
	sb.concadd(Scale_in, kiai2_flashes)
)
storyboard:newObject("sb/3CloudFlash.jpg", "Background", "Centre", 320,240):add(
	{'scale', 0, {{T,64*4}}, 0.99},
	{'protract', {'param', {{T,64*4}}, value='a'}},
	Flash({T,64*4}, 320, 0.4, 0.1),
	Flash({T,72*4}, 320, 0.4, 0.1),
	sb.concadd(Scale_in, kiai3_flashes)
)
CircFlash_at(8, 0.55, 1.0, Circ1)
CircFlash_at(16, 0.55, 1.0, Circ1)
CircFlash_at(24, 0.55, 1.0, Circ2)
CircFlash_at(32, 0.55, 1.0, Circ2)
CircFlash_at(40, 0.65, 1.0, Circ2)

CircFlash_at(48, 0.55, 2.0, Circ1)
CircFlash_at(56, 0.55, 2.0, Circ1)

CircFlash_at(64, 0.55, 1.5, Circ3)
CircFlash_at(72, 0.55, 1.5, Circ3)

CircFlash_at(80, 0.70, 2.0, Circ3)

-- Text
local TEXT_S = 0.52
storyboard:newObject('sb/tsarbomba.png', 'Foreground', 'TopLeft', 50,265):add(
		{'scale', 'linear', {{T,42.85*4}}, TEXT_S},
		{'moverel', 'sineOut', {{T,41*4}, {T,41*4+5*4}}, {0,0},{15,0}},
		{'fade', 'cubicOut', {{T,42.85*4}, {T,45.85*4}}, 0,1},
		{'fade', 'cubicOut', {{T,43*4+4*3}, {T,45*4+4*3}}, 1,0}
)
storyboard:newObject('sb/ProjectGreat.png', 'Foreground', 'TopLeft', 50,215):add(
	{'scale', 'linear', {{T,42.05*4}}, TEXT_S},
	{'moverel', 'sineOut', {{T,41*4}, {T,41*4+5*4}}, {0,0},{15,0}},
	{'fade', 'cubicOut', {{T,42.05*4}, {T,45*4}}, 0,1},
	{'fade', 'cubicOut', {{T,42*4+4*3}, {T,44*4+4*3}}, 1,0}
)

local function mapperText(X, img)
	X:newObject(string.format('sb/%s.png',img), 'Foreground', 'TopLeft', 50,165):add(
		{'scale', 'linear', {{T,40.95*4}}, TEXT_S},
		{'moverel', 'sineOut', {{T,41*4}, {T,41*4+5*4}}, {0,0},{15,0}},
		{'fade', 'cubicOut', {{T,40.95*4}, {T,43.9*4}}, 0,1},
		{'fade', 'cubicOut', {{T,40.95*4+4*3}, {T,43*4+4*3}}, 1,0}
	)
end
--mapperText(tsarbomba, 'tsarbomba')
mapperText(nekumagetsu, 'NekuMagetsu')
mapperText(suisei69, 'Suisei69')
mapperText(theshadowofdark, 'TheShadowOfDark')
mapperText(keywee, 'KeyWee')
--mapperText(projectgreat, 'ProjectGreat')

storyboard:writeToFile2()

sb.config['silence-headers'] = true
--tsarbomba:writeToFile()
nekumagetsu:writeToFile()
suisei69:writeToFile()
theshadowofdark:writeToFile()
keywee:writeToFile()
--projectgreat:writeToFile()
