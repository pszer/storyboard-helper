package.path = "./?.lua;./?/init.lua;" .. package.path
local sb = require('sbhelper')

storyboard = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/2512759 Amane - ELECTRONIC GEAR/Rolling Contact - ELECTRONIC GEAR (tsarbomba).osb")
sb.file:setProjectFolder("/home/quake/.local/share/osu-wine/osu!/Songs/2512759 Amane - ELECTRONIC GEAR/")

storyboard:newObject("bg.jpg", "Background", "Center", 320, 240):add(
	{'fade', 0, { -500, -500 }, 0,0 })

local T = {188.000,840}

--[[storyboard:newObject('sb/Flash.jpg', 'Background', 'TopLeft', -107,0):add(
	{'fade', 0, { 1000 }, 1 },
	{'color', 0, { -500 }, {0,150,0} },
	{'vector',0, { -500 }, {1,2.5} },
	{'fade', 0, { {T,228*4} }, 0 }
)--]]

local MASTER=255
local GRAY = function(X) return {X*MASTER,X*MASTER,X*MASTER} end

local function Vec2Add(a,b)
	return {a[1]+b[1], a[2]+b[2]}
end
local function Vec3Mul(a,b)
	return {a[1]*b[1], a[2]*b[2], a[3]*b[3]}
end

local START_STR = 0.72
local START_COL = GRAY(START_STR)
local function Flash(time,dur,strength,peak, ease)
	ease = ease or 1
	local T = sb.time:convert(time)
	return function (out)
		out{'fade',ease,{T,T+dur*peak},0,strength}
		out{'fade',ease,{T+dur*peak,T+dur},strength,0}
	end
end
local function FlashIn(time,dur,strength,peak,floor, ease)
	ease = ease or 1
	local T = sb.time:convert(time)
	return function (out)
		out{'fade',ease,{T,T+dur*peak},0,strength}
		out{'fade',ease,{T+dur*peak,T+dur},strength,floor}
	end
end
local function FlashOut(time,dur,strength,peak,floor, ease)
	ease = ease or 1
	local T = sb.time:convert(time)
	return function (out)
		out{'fade',ease,{T,T+dur*peak},floor,strength}
		out{'fade',ease,{T+dur*peak,T+dur},strength,0}
	end
end
local function FlashCol(time,dur,strength,peak, start_str, ease)
	start_str = start_str or START_STR
	local ease = ease or 1
	local T = sb.time:convert(time)
	return function (out)
		out{'color',ease,{T,T+dur*peak},GRAY(start_str),GRAY(strength)}
		out{'color',ease,{T+dur*peak,T+dur},GRAY(strength),GRAY(start_str)}
	end
end
local function FlashCol2(time,dur,c1,peak, c2, ease)
	start_str = start_str or START_STR
	local ease = ease or 1
	local T = sb.time:convert(time)
	return function (out)
		out{'color',ease,{T,T+dur*peak},c2,c1}
		out{'color',ease,{T+dur*peak,T+dur},c1,c2}
	end
end
local function FlashCol3(time,dur,c1,peak, c2, str, ease)
	start_str = start_str or START_STR
	local ease = ease or 1
	local T = sb.time:convert(time)
	return function (out)
		out{'color',ease,{T,T+dur*peak},Vec3Mul(c2,START_COL),Vec3Mul(c1,{str,str,str})}
		out{'color',ease,{T+dur*peak,T+dur},Vec3Mul(c1,{str,str,str}),Vec3Mul(c2,START_COL)}
	end
end
local function FlashCol4(time,dur,c1,peak, c2, c3, ease)
	start_str = start_str or START_STR
	local ease = ease or 1
	local T = sb.time:convert(time)
	return function (out)
		out{'color',ease,{T,T+dur*peak},c2,c1}
		out{'color',ease,{T+dur*peak,T+dur},c1,c3}
	end
end

local CROSS_START = {-345+223-3,-397+81}
local CROSS_AXIS  = {-85, 306}
local CROSS_I1  = -0.75
local CROSS_I2  = 1.1

local CROSS_A_ROT    = math.pi * (13.5/180.0)
local CROSS_A_ORIGIN = {0,253}
local CROSS_B_ROT = math.pi * (22/180.0)
local CROSS_B_ORIGIN = {650-21,0+115-70}

function getCrossXY(t)
	local d = CROSS_I2 - CROSS_I1
	return {
		CROSS_START[1] + CROSS_AXIS[1]*(CROSS_I1 + t*d),
		CROSS_START[2] + CROSS_AXIS[2]*(CROSS_I1 + t*d),
	}
end

local Tile1_Origin = {538,107-20}
local Tile2_Origin = {349+29,431}
local Tile3_Origin = {43,269}
local Tile4_Origin = {33,86}
local Tile3_Rot = math.pi * (15.75/180.0) 

local Tile1_Tint1 = {0 / 182, 123 / 182, 35 / 182}
local Tile2_Tint1 = {180 / 255, 180 / 255, 255 / 255}
local Tile3_Tint1 = {125 / 182, 32 / 182, 30 / 182}
local Tile4_Tint1 = {8 / 182, 31 / 182, 59 / 182}

local Tile1_Tint2 = {0 / 255, 145 / 255, 26 / 255}
local Tile2_Tint2 = {255 / 255, 255 / 255, 255 / 255}
local Tile3_Tint2 = {112 / 255, 76 / 255, 27 / 255}
local Tile4_Tint2 = {6 / 255, 63 / 255, 44 / 255}

local Tile1_Tint3 = {0 / 170, 123 / 170, 35 / 170}
local Tile2_Tint3 = {180 / 210, 180 / 210, 255 / 230}
local Tile3_Tint3 = {125 / 170, 32 / 170, 30 / 170}
local Tile4_Tint3 = {8 / 170, 31 / 170, 59 / 170}

local Tile1_Tint4 = {125 / 320, 0 / 280, 255 / 320}
local Tile2_Tint4 = {180 / 180, 180 / 180, 240 / 255}
local Tile3_Tint4 = {170 / 360, 10 / 360, 230 / 360}
local Tile4_Tint4 = {125 / 310, 125 / 310, 160 / 310}

local C_MAX = 0.81
local C_MIN = 0.65
local C_MID = (C_MAX+C_MIN) * 0.5

local CrossMove = {
	{'move' , 'cubicIn', { {T,0.8}, {T,4} }, getCrossXY(0.748), getCrossXY(0.77) },

	{'move' , 'sineout', { {T,1*4}, {T,4*4} }, getCrossXY(0.77), getCrossXY(C_MAX) },

	{'move' , 'sinein', { {T,4*4}, {T,20*4} }, getCrossXY(C_MAX), getCrossXY(C_MID) },
	{'move' , 'sineout', { {T,20*4}, {T,36*4} }, getCrossXY(C_MID), getCrossXY(C_MIN) },
	{'move' , 'sinein', { {T,36*4}, {T,48*4} }, getCrossXY(C_MIN), getCrossXY(C_MID) },
	{'move' , 'sineout', { {T,48*4}, {T,64*4} }, getCrossXY(C_MID), getCrossXY(C_MAX) },

	{'move' , 'sinein', { {T,64*4}, {T,80*4} }, getCrossXY(C_MAX), getCrossXY(C_MID) },
	{'move' , 'sineout', { {T,80*4}, {T,96*4} }, getCrossXY(C_MID), getCrossXY(C_MIN) },
	{'move' , 'sinein', { {T,96*4}, {T,112*4} }, getCrossXY(C_MIN), getCrossXY(C_MID) },
	{'move' , 'sineout', { {T,112*4}, {T,128*4} }, getCrossXY(C_MID), getCrossXY(C_MAX) },

	{'move' , 'sinein', { {T,128*4}, {T,144*4} }, getCrossXY(C_MAX), getCrossXY(C_MID) },
	{'move' , 'sineout', { {T,144*4}, {T,160*4} }, getCrossXY(C_MID), getCrossXY(C_MIN) },
	{'move' , 'sinein', { {T,160*4}, {T,176*4} }, getCrossXY(C_MIN), getCrossXY(C_MID) },
	{'move' , 'sineout', { {T,176*4}, {T,192*4} }, getCrossXY(C_MID), getCrossXY(C_MAX) },

	{'move' , 'sinein', { {T,192*4}, {T,208*4} }, getCrossXY(C_MAX), getCrossXY(C_MID) },
	{'move' , 'sineout', { {T,208*4}, {T,224*4} }, getCrossXY(C_MID), getCrossXY(C_MIN) },
}

local BG_SWITCH_DELAY = sb.time:convert({T,4*4}) - sb.time:convert({T,0*4})

local function SwitchBGS(i, delay, offset)
	local result1 = {}
	local result2 = {}
	local result3 = {}
	local delay = delay or BG_SWITCH_DELAY

	local o = (i-1) * delay/9.0 + offset

	local go = false
	for T=sb.time:convert{T,0}, sb.time:convert{T,223*4}, delay do
		if go then
			table.insert( result1, {'fade', 'linear', { o+T+(delay/18.0)*(-1), o+T      }, 0,1 } )
		end
		table.insert( result1, {'fade', 'linear', { o+T+(delay/18.0)*6 , o+T+(delay/18.0)*6  }, 0 } )

		table.insert( result2, {'fade', 'linear', { o+T+(delay/18.0)*5 , o+T+(delay/18.0)*6  }, 0,1 } )
		table.insert( result2, {'fade', 'linear', { o+T+(delay/18.0)*12, o+T+(delay/18.0)*12 }, 0 } )

		table.insert( result3, {'fade', 'linear', { o+T+(delay/18.0)*11, o+T+(delay/18.0)*12 }, 0,1 } )
		table.insert( result3, {'fade', 'linear', { o+T+(delay/18.0)*18, o+T+(delay/18.0)*19 }, 1,0 } )

		go = true
	end

	result1[#result1][5]=1
	result2[#result2][5]=1
	result3[#result3][5]=1

	return result1, result2, result3
end

local FlashesArgs = {
	{{T,1*4}, 450, 0.4, 0.15},

	{{T,16*4+0}, 215, 0.3, 0.15},
	{{T,16*4+1}, 215, 0.3, 0.15},
	{{T,16*4+2}, 215, 0.3, 0.15},
	{{T,16*4+3}, 215, 0.3, 0.15},

	{{T,17*4}, 800, 0.5, 0.3},

	{{T,33*4}, 850, 0.2, 0.25},

	{{T,34*4}, 1200, 0.4, 0.4},
	{{T,42*4}, 800, 0.2, 0.25},
	{{T,50*4}, 800, 0.2, 0.25},

	{{T,51*4}, 800, 0.4, 0.25},
	{{T,52*4}, 800, 0.4, 0.25},
	{{T,53*4}, 800, 0.4, 0.25},
	{{T,54*4}, 800, 0.4, 0.25},
	{{T,55*4}, 800, 0.4, 0.25},
	{{T,56*4}, 800, 0.4, 0.25},
	{{T,57*4}, 800, 0.4, 0.25},
	{{T,58*4}, 800, 0.4, 0.25},
	{{T,59*4}, 800, 0.4, 0.25},
	{{T,60*4}, 800, 0.4, 0.25},
	{{T,61*4}, 800, 0.4, 0.25},
	{{T,62*4}, 800, 0.4, 0.25},
	{{T,63*4}, 800, 0.4, 0.25},
	{{T,64*4}, 800, 0.4, 0.25},
	{{T,65*4}, 800, 0.4, 0.25},
	{{T,66*4}, 650, 0.6, 0.25},

	{{T,67*4}, 450, 0.5, 0.25},
	{{T,68*4}, 450, 0.5, 0.25},
	{{T,68*4+2}, 450, 0.45, 0.25},
	{{T,69*4}, 220, 0.2, 0.3},
	{{T,69*4+1}, 220, 0.2, 0.3},
	{{T,69*4+2}, 220, 0.2, 0.3},
	{{T,69*4+3}, 220, 0.2, 0.3},
	{{T,70*4}, 800, 0.5, 0.3},


	{{T,72*4}, 2000, 0.7, 0.5},
	{{T,104*4}, 600, 0.7, 0.4},
	{{T,124*4}, 1200, 0.4, 0.4},

	{{T,132*4}, 450, 0.5, 0.25},

	{{T,140*4}, 800, 0.4, 0.25},
	{{T,141*4}, 800, 0.4, 0.25},
	{{T,142*4}, 800, 0.4, 0.25},
	{{T,143*4}, 800, 0.4, 0.25},
	{{T,144*4}, 800, 0.4, 0.25},
	{{T,145*4}, 800, 0.4, 0.25},
	{{T,146*4}, 800, 0.4, 0.25},
	{{T,147*4}, 800, 0.4, 0.25},
	{{T,148*4}, 800, 0.4, 0.25},
	{{T,149*4}, 800, 0.4, 0.25},
	{{T,150*4}, 800, 0.4, 0.25},
	{{T,151*4}, 800, 0.4, 0.25},
	{{T,152*4}, 800, 0.4, 0.25},
	{{T,153*4}, 800, 0.4, 0.25},
	{{T,154*4}, 800, 0.4, 0.25},
	{{T,155*4}, 800, 0.4, 0.25},
	{{T,156*4}, 650, 0.4, 0.25},

	{{T,67*4+90*4}, 450, 0.5, 0.25},
	{{T,68*4+90*4}, 450, 0.5, 0.25},
	{{T,68*4+2+90*4}, 450, 0.45, 0.25},
	{{T,69*4+90*4}, 220, 0.2, 0.3},
	{{T,69*4+1+90*4}, 220, 0.2, 0.3},
	{{T,69*4+2+90*4}, 220, 0.2, 0.3},
	{{T,69*4+3+90*4}, 220, 0.2, 0.3},
	{{T,70*4+90*4}, 800, 0.5, 0.3},

	-- kiai
	{{T,80*4}, 600, 0.4, 0.25},
	{{T,87*4}, 250, 0.12, 0.3},
	{{T,87*4+1}, 250, 0.12, 0.3},
	{{T,87*4+2}, 250, 0.12, 0.3},
	{{T,87*4+3}, 250, 0.12, 0.3},
	{{T,88*4}, 600, 0.4, 0.25},
	{{T,96*4}, 600, 0.4, 0.25},
	{{T,103*4}, 250, 0.12, 0.3},
	{{T,103*4+1}, 250, 0.12, 0.3},
	{{T,103*4+2}, 250, 0.12, 0.3},
	{{T,103*4+3}, 250, 0.12, 0.3},
	-- kiai 2
	{{T,80*4+90*4}, 600, 0.4, 0.25},
	{{T,87*4+90*4}, 250, 0.12, 0.3},
	{{T,87*4+1+90*4}, 250, 0.12, 0.3},
	{{T,87*4+2+90*4}, 250, 0.12, 0.3},
	{{T,87*4+3+90*4}, 250, 0.12, 0.3},
	{{T,178*4}, 600, 0.4, 0.25},
	{{T,96*4+90*4}, 600, 0.4, 0.25},
	{{T,103*4+90*4}, 250, 0.12, 0.3},
	{{T,103*4+1+90*4}, 250, 0.12, 0.3},
	{{T,103*4+2+90*4}, 250, 0.12, 0.3},
	{{T,103*4+3+90*4}, 250, 0.12, 0.3},


	{{T,162*4}, 2000, 0.7, 0.5},
	{{T,194*4}, 600, 0.7, 0.4},

	{{T,210*4}, 800, 0.3, 0.2},

	{{T,226*4}, 450, 0.7, 0.15},
}
local FlashesArgs_Tint2 = {
	--{{T, 4*4 + 2}, 530, 255, 0.4},
	--{{T, 8*4 + 2}, 530, 255, 0.4}
}

for i=0+2-0.5,0+16-0.5, 0.5 do
	if (i+1)%8==0 then
		table.insert(FlashesArgs, {{T,i*4}, 450, 0.4, 0.25, 0.7})
	else
		table.insert(FlashesArgs, {{T,i*4}, 450, 0.15, 0.25, 0.7})
	end
end
for i=0+18,0+32-0.5, 0.5 do
	if (i+1)%8==0 then
		table.insert(FlashesArgs, {{T,i*4}, 450, 0.4, 0.25, 0.7})
	else
		table.insert(FlashesArgs, {{T,i*4}, 450, 0.15, 0.25, 0.7})
	end
end

for i=106-0.5,0+120-0.5, 0.5 do
	if (i+1)%8==0 then
		table.insert(FlashesArgs, {{T,i*4}, 450, 0.4, 0.25, 0.7})
	else
		table.insert(FlashesArgs, {{T,i*4}, 450, 0.15, 0.25, 0.7})
	end
end

for i=196-0.5,210-0.5, 0.5 do
	if (i+1)%8==0 then
		table.insert(FlashesArgs, {{T,i*4}, 450, 0.4, 0.25, 0.7})
	else
		table.insert(FlashesArgs, {{T,i*4}, 450, 0.15, 0.25, 0.7})
	end
end

for i=89,95 do
	table.insert(FlashesArgs, {{T,i*4}, 450, 0.15, 0.25, 0.7})
end
for i=97,102 do
	table.insert(FlashesArgs, {{T,i*4}, 450, 0.15, 0.25, 0.7})
end

for i=179,185 do
	table.insert(FlashesArgs, {{T,i*4}, 450, 0.15, 0.25, 0.7})
end
for i=187,192 do
	table.insert(FlashesArgs, {{T,i*4}, 450, 0.15, 0.25, 0.7})
end

local Sec1a,Sec1b = sb.time:convert{T,17*4},sb.time:convert{T,33*4}
local Sec2a,Sec2b = sb.time:convert{T,104*4},sb.time:convert{T,124*4}
local Sec3a,Sec3b = sb.time:convert{T,194*4},sb.time:convert{T,210*4}

local Kiai1a,Kiai1b = sb.time:convert{T,72*4},sb.time:convert{T,104*4}
local Kiai2a,Kiai2b = sb.time:convert{T,162*4},sb.time:convert{T,194*4}

function GetFlashes(tint, tint2, tint3)
	local result = {}
	for i,v in ipairs(FlashesArgs) do
		local time = sb.time:convert(v[1])

		local tint = tint
		local tint0 = tint
		local tint1 = tint

		local BaseCol = Vec3Mul(tint, START_COL)
		if (time >= Sec1a and time <= Sec1b) or
		   (time > Sec2a and time <= Sec2b) or
		   (time > Sec3a and time <= Sec3b) then

			if (time==Sec1a or time==Sec2a or time==Sec3a) then
				tint0 = tint
				tint1 = tint2
			elseif (time==Sec1b or time==Sec2b) then
				tint0 = tint2
				tint1 = tint
			else
				tint0 = tint2
				tint1 = tint2
			end
			tint = tint2

		elseif (time >= Kiai1a and time <= Kiai1b) or
		   (time >= Kiai2a and time <= Kiai2b) then
			if (time==Kiai1a or time==Kiai2a) then
				tint0 = tint
				tint1 = tint3
			elseif (time==Kiai1b or time==Kiai2b) then
				tint0 = tint3
				tint1 = tint2
			else
				tint0 = tint3
				tint1 = tint3
			end
			tint = tint3

		end

		table.insert(result,
			FlashCol4(
				v[1],
				v[2],
				Vec3Mul(tint, GRAY(math.min(1.0,START_STR+v[3]))),
				v[4], Vec3Mul(tint0, START_COL), Vec3Mul(tint1, START_COL)
			)
			)
	end
	return result
end

function GetFlashes_Tint2(tint, base)
	local result = {}
	for i,v in ipairs(FlashesArgs_Tint2) do
		table.insert(result,
			FlashCol3(
				v[1],
				v[2],
				tint,
				v[4], base, v[3]
			)
			)
	end
	return result
end

local TileA_BG1_Fade, TileA_BG2_Fade, TileA_BG3_Fade =
	SwitchBGS(0,nil,2200)
local TileB_BG1_Fade, TileB_BG2_Fade, TileB_BG3_Fade =
	SwitchBGS(1,nil,2200)
local TileC_BG1_Fade, TileC_BG2_Fade, TileC_BG3_Fade =
	SwitchBGS(2,nil,2200)

-- Lower 2 BGS
storyboard:newObject('sb/StarsTiles1.jpg', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile4_Origin,
		{'fade', 0, { {T,1.1},{T,2.1} }, 0,1 },
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile4_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, GetFlashes(Tile4_Tint1, Tile4_Tint3, Tile4_Tint4))
	}
)
-- Tile B
storyboard:newObject('sb/TilingB_Col1.jpg', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile2_Origin,
		{'fade', 2, { {T,1.25},{T,2} }, 0,1 },
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile2_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileB_BG1_Fade, GetFlashes(Tile2_Tint1, Tile2_Tint3, Tile2_Tint4))
	})
storyboard:newObject('sb/TilingB_Col2.jpg', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile2_Origin,
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile2_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileB_BG2_Fade, GetFlashes(Tile2_Tint1, Tile2_Tint3, Tile2_Tint4))
	})
storyboard:newObject('sb/TilingB_Col3.jpg', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile2_Origin,
		--{'fade', 0, { {T,0},{T,2*1} }, 0,1 },
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile2_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileB_BG3_Fade, GetFlashes(Tile2_Tint1, Tile2_Tint3, Tile2_Tint4))
	})

--
--
--
--
-- Upper 2 BGS
--
--
-- Tile A
storyboard:newObject('sb/TilingA_Col1.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile1_Origin,
		{'fade', 0, { {T,1},{T,2} }, 0,1 },
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile1_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileA_BG1_Fade, GetFlashes(Tile1_Tint1, Tile1_Tint3, Tile1_Tint4))
	})
storyboard:newObject('sb/TilingA_Col2.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile1_Origin,
		--{'fade', 0, { {T,0},{T,2*1} }, 0,1 },
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile1_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileA_BG2_Fade, GetFlashes(Tile1_Tint1, Tile1_Tint3, Tile1_Tint4))
	})
storyboard:newObject('sb/TilingA_Col3.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile1_Origin,
		--{'fade', 0, { {T,0},{T,2*1} }, 0,1 },
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile1_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileA_BG3_Fade, GetFlashes(Tile1_Tint1, Tile1_Tint3, Tile1_Tint4))
	})
--
--
--
-- Tile C
storyboard:newObject('sb/TilingC_Col1.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile3_Origin,
		{'fade', 0, { {T,0.9},{T,1.7} }, 0,1 },
		{'rot' , 0, { {T,0} }, Tile3_Rot },
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile3_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileC_BG1_Fade, GetFlashes(Tile3_Tint1, Tile3_Tint3, Tile3_Tint4))
	})
storyboard:newObject('sb/TilingC_Col2.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile3_Origin,
		--{'fade', 0, { {T,0},{T,2*1} }, 0,1 },
		{'rot' , 0, { {T,0} }, Tile3_Rot },
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile3_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileC_BG2_Fade, GetFlashes(Tile3_Tint1, Tile3_Tint3, Tile3_Tint4))
	})
storyboard:newObject('sb/TilingC_Col3.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile3_Origin,
		--{'fade', 0, { {T,0},{T,2*1} }, 0,1 },
		{'rot' , 0, { {T,0} }, Tile3_Rot },
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile3_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileC_BG3_Fade, GetFlashes(Tile3_Tint1, Tile3_Tint3, Tile3_Tint4))
	})

-- Cross
storyboard:newObject('sb/CrossA.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = CROSS_A_ORIGIN,
		{'rot' , 0, { {T,0} }, CROSS_A_ROT },
		{'col' , 0, { {T,0} }, GRAY(0.44) },
		{'fade', 0, { {T,0},{T,2*1} }, 0,1 },
		{'fade', 0, { {T,72*4+2},{T,72*4+2} },0 },
		{'fade', 0, { {T,104*4 },{T,104*4} },1},

		{'fade', 0, { {T,162*4+2},{T,162*4+2} },0 },
		{'fade', 0, { {T,194*4 },{T,194*4} },1},
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove)
	}
)
storyboard:newObject('sb/CrossB.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = CROSS_B_ORIGIN,
		{'rot' , 0, { {T,0} }, CROSS_B_ROT },
		{'col' , 0, { {T,0} }, GRAY(0.44) },
		{'fade', 0, { {T,0},{T,2*1} }, 0,1 },
		{'fade', 0, { {T,72*4+2},{T,72*4+2} },0 },
		{'fade', 0, { {T,104*4 },{T,104*4} },1},
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove)
	}
)
storyboard:newObject('sb/CrossA_B.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Vec2Add(CROSS_A_ORIGIN, {4.5,-20}),
		{'rot' , 0, { {T,72*4+2} }, CROSS_A_ROT },
		{'col' , 0, { {T,72*4+2} }, GRAY(0.44) },
		{'fade', 0, { {T,72*4+1},{T,72*4+2} },0,1 },
		{'fade', 0, { {T,104*4 },{T,104*4+2} },1,0 },
		{'fade', 0, { {T,162*4+1},{T,162*4+2} },0,1 },
		{'fade', 0, { {T,194*4 },{T,194*4+2} },1,0 },
		sb.concadd(CrossMove)
	}
)
storyboard:newObject('sb/CrossB_B.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Vec2Add(CROSS_B_ORIGIN, {-18,-7}),
		{'rot' , 0, { {T,72*4+2} }, CROSS_B_ROT },
		{'col' , 0, { {T,72*4+2} }, GRAY(0.44) },
		{'fade', 0, { {T,72*4+1},{T,72*4+2} },0,1 },
		{'fade', 0, { {T,104*4 },{T,104*4+2} },1,0 },
		{'fade', 0, { {T,162*4+1},{T,162*4+2} },0,1 },
		{'fade', 0, { {T,194*4 },{T,194*4+2} },1,0 },
		sb.concadd(CrossMove)
	}
)

storyboard:newObject('sb/FlashC.jpg', 'Foreground', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = {0,29},
		{'protract', {'param', {{T,0}}, value='a'}},
		Flash({T,1*4}, 450, 0.4, 0.25),
		Flash({T,34*4}, 600, 0.2, 0.4),
		Flash({T,42*4}, 600, 0.2, 0.25),
		Flash({T,50*4}, 600, 0.2, 0.25),


		-- kiai
		Flash({T,80*4}, 600, 0.4, 0.25),
		Flash({T,87*4}, 250, 0.12, 0.3),
		Flash({T,87*4+1}, 250, 0.12, 0.3),
		Flash({T,87*4+2}, 250, 0.12, 0.3),
		Flash({T,87*4+3}, 250, 0.12, 0.3),
		Flash({T,96*4}, 600, 0.4, 0.25),
		Flash({T,103*4}, 250, 0.12, 0.3),
		Flash({T,103*4+1}, 250, 0.12, 0.3),
		Flash({T,103*4+2}, 250, 0.12, 0.3),
		Flash({T,103*4+3}, 250, 0.12, 0.3),
		-- kiai 2
		Flash({T,80*4+90*4}, 600, 0.4, 0.25),
		Flash({T,87*4+90*4}, 250, 0.12, 0.3),
		Flash({T,87*4+1+90*4}, 250, 0.12, 0.3),
		Flash({T,87*4+2+90*4}, 250, 0.12, 0.3),
		Flash({T,87*4+3+90*4}, 250, 0.12, 0.3),
		Flash({T,96*4+90*4}, 600, 0.4, 0.25),
		Flash({T,103*4+90*4}, 250, 0.12, 0.3),
		Flash({T,103*4+1+90*4}, 250, 0.12, 0.3),
		Flash({T,103*4+2+90*4}, 250, 0.12, 0.3),
		Flash({T,103*4+3+90*4}, 250, 0.12, 0.3),


		Flash({T,156*4-90*4}, 600, 0.2, 0.25),
		Flash({T,157*4-90*4}, 450, 0.2, 0.25),
		Flash({T,158*4-90*4}, 450, 0.2, 0.25),
		Flash({T,158*4+2-90*4}, 450, 0.2, 0.25),
		Flash({T,159*4-90*4}, 220, 0.12, 0.3),
		Flash({T,159*4+1-90*4}, 220, 0.12, 0.3),
		Flash({T,159*4+2-90*4}, 220, 0.12, 0.3),
		Flash({T,159*4+3-90*4}, 220, 0.12, 0.3),
		Flash({T,160*4-90*4}, 600, 0.3, 0.25),

		Flash({T,124*4}, 600, 0.2, 0.4),
		Flash({T,132*4}, 600, 0.2, 0.25),
		Flash({T,140*4}, 600, 0.2, 0.25),
		Flash({T,156*4}, 600, 0.2, 0.25),
		Flash({T,157*4}, 450, 0.2, 0.25),
		Flash({T,158*4}, 450, 0.2, 0.25),
		Flash({T,158*4+2}, 450, 0.2, 0.25),
		Flash({T,159*4}, 220, 0.12, 0.3),
		Flash({T,159*4+1}, 220, 0.12, 0.3),
		Flash({T,159*4+2}, 220, 0.12, 0.3),
		Flash({T,159*4+3}, 220, 0.12, 0.3),
		Flash({T,160*4}, 600, 0.3, 0.25),


		Flash({T,226*4}, 1200, 0.5, 0.1),
		Flash({T,72*4}, 600, 0.4, 0.25),
		Flash({T,162*4}, 600, 0.4, 0.25),
		sb.concadd(CrossMove)
	}
)
storyboard:newObject('sb/FlashD.jpg', 'Foreground', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = {0,29},
		{'protract', {'param', {{T,0}}, value='a'}},
		Flash({T,16*4+0}, 215, 0.2, 0.4),
		Flash({T,16*4+1}, 215, 0.2, 0.4),
		Flash({T,16*4+2}, 215, 0.2, 0.4),
		Flash({T,16*4+3}, 215, 0.2, 0.4),

		Flash({T,32*4+0}, 215, 0.2, 0.4),
		Flash({T,32*4+1}, 215, 0.2, 0.4),
		Flash({T,32*4+2}, 215, 0.2, 0.4),
		Flash({T,32*4+3}, 215, 0.2, 0.4),

		sb.concadd(CrossMove)
	}
)

-- bar in case of transparent skins
--
--storyboard:newObject('sb/Black.jpg', 'Foreground', 'TopLeft', -107,141):add(
--	{'fade', 0, { -500 }, 1 },
--	{'vector',0, { -500 }, {1,0.37} },
--	{'fade', 0, { {T,228*4} }, 0 }
--)

storyboard:writeToFile2()
