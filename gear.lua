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

local START_STR = 0.75
local START_COL = GRAY(START_STR)
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

local CROSS_START = {-345+223-15,-397+81}
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

local Tile1_Tint1 = {0 / 255, 123 / 255, 47 / 255}
local Tile2_Tint1 = {180 / 255, 180 / 255, 255 / 255}
local Tile3_Tint1 = {125 / 255, 32 / 255, 30 / 255}
local Tile4_Tint1 = {8 / 255, 31 / 255, 59 / 255}

local Tile1_Tint2 = {138 / 255, 239 / 255, 88 / 255}
local Tile2_Tint2 = {255 / 255, 255 / 255, 255 / 255}
local Tile3_Tint2 = {164 / 255, 198 / 255, 102 / 255}
local Tile4_Tint2 = {63 / 255, 102 / 255, 49 / 255}

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
	{'move' , 'sinein', { {T,96*4}, {T,110*4} }, getCrossXY(C_MIN), getCrossXY(C_MID) },
	{'move' , 'sineout', { {T,110*4}, {T,126*4} }, getCrossXY(C_MID), getCrossXY(C_MAX) },

	{'move' , 'sinein', { {T,64*4 + 64*4}, {T,80*4 + 64*4} }, getCrossXY(C_MAX), getCrossXY(C_MID) },
	{'move' , 'sineout', { {T,80*4 + 64*4}, {T,96*4 + 64*4} }, getCrossXY(C_MID), getCrossXY(C_MIN) },
	{'move' , 'sinein', { {T,96*4 + 64*4}, {T,110*4 + 64*4} }, getCrossXY(C_MIN), getCrossXY(C_MID) },
	{'move' , 'sineout', { {T,110*4 + 64*4}, {T,190*4} }, getCrossXY(C_MID), getCrossXY(C_MAX) },

	{'move' , 'sinein', { {T,206*4}, {T,222*4} } , getCrossXY(C_MAX), getCrossXY(C_MID) },
}

local function Vec2Add(a,b)
	return {a[1]+b[1], a[2]+b[2]}
end
local function Vec3Mul(a,b)
	return {a[1]*b[1], a[2]*b[2], a[3]*b[3]}
end

local BG_SWITCH_DELAY = sb.time:convert({T,9*4}) - sb.time:convert({T,0*4})

local function SwitchBGS(i, delay, offset)
	local result1 = {}
	local result2 = {}
	local result3 = {}
	local delay = delay or BG_SWITCH_DELAY

	local o = (i-1) * delay/9.0 + offset

	local go = false
	for T=sb.time:convert{T,0}, sb.time:convert{T,224*4}, delay do
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

	return result1, result2, result3
end

local FlashesArgs = {
	{{T,1*4}, 450, 0.25, 0.15}
}
local FlashesArgs_Tint2 = {
	{{T,4*4+2}, 450, 0.25, 0.15}
}

for i=2-0.5,15,0.5 do
	table.insert(FlashesArgs, {{T,i*4}, 450, 0.17, 0.25, 0.7})
end

function GetFlashes(tint)
	local result = {}
	for i,v in ipairs(FlashesArgs) do
		table.insert(result,
			FlashCol2(
				v[1],
				v[2],
				Vec3Mul(tint, GRAY(math.min(1.0,START_STR+v[3]))),
				v[4], Vec3Mul(tint, START_COL)
			)
			)
	end
	return result
end

function GetFlashes_Tint2(tint, base)
	local result = {}
	for i,v in ipairs(FlashesArgs_Tint2) do
		table.insert(result,
			FlashCol2(
				v[1],
				v[2],
				tint,
				v[4], Vec3Mul(base, START_COL)
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
		sb.concadd(CrossMove, Flashes)
	}
)
-- Tile B
storyboard:newObject('sb/TilingB_Col1.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile2_Origin,
		{'fade', 0, { {T,1},{T,2} }, 0,1 },
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile2_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileB_BG1_Fade, GetFlashes(Tile2_Tint1))
	})
storyboard:newObject('sb/TilingB_Col2.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile2_Origin,
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile2_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileB_BG2_Fade, GetFlashes(Tile2_Tint1))
	})
storyboard:newObject('sb/TilingB_Col3.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile2_Origin,
		--{'fade', 0, { {T,0},{T,2*1} }, 0,1 },
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile2_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileB_BG3_Fade, GetFlashes(Tile2_Tint1))
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
		sb.concadd(CrossMove, TileA_BG1_Fade, GetFlashes(Tile1_Tint1))
	})
storyboard:newObject('sb/TilingA_Col2.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile1_Origin,
		--{'fade', 0, { {T,0},{T,2*1} }, 0,1 },
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile1_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileA_BG2_Fade, GetFlashes(Tile1_Tint1))
	})
storyboard:newObject('sb/TilingA_Col3.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile1_Origin,
		--{'fade', 0, { {T,0},{T,2*1} }, 0,1 },
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile1_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileA_BG3_Fade, GetFlashes(Tile1_Tint1))
	})
--
--
--
-- Tile C
storyboard:newObject('sb/TilingC_Col1.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile3_Origin,
		{'fade', 0, { {T,1},{T,2} }, 0,1 },
		{'rot' , 0, { {T,0} }, Tile3_Rot },
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile3_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileC_BG1_Fade, GetFlashes(Tile3_Tint1))
	})
storyboard:newObject('sb/TilingC_Col2.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile3_Origin,
		--{'fade', 0, { {T,0},{T,2*1} }, 0,1 },
		{'rot' , 0, { {T,0} }, Tile3_Rot },
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile3_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileC_BG2_Fade, GetFlashes(Tile3_Tint1))
	})
storyboard:newObject('sb/TilingC_Col3.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile3_Origin,
		--{'fade', 0, { {T,0},{T,2*1} }, 0,1 },
		{'rot' , 0, { {T,0} }, Tile3_Rot },
		{'color',0, { {T,0},{T,0} }, Vec3Mul( START_COL, Tile3_Tint1 ) },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove, TileC_BG3_Fade, GetFlashes(Tile3_Tint1))
	})

-- Black tile overlays
storyboard:newObject('sb/TilingA.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile1_Origin,
		{'fade', 0, { {T,0},{T,1*1} }, 0,1 },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove)
	}
)
storyboard:newObject('sb/TilingB.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile2_Origin,
		{'fade', 0, { {T,0},{T,1*1} }, 0,1 },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove)
	}
)
storyboard:newObject('sb/TilingC.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = Tile3_Origin,
		{'fade', 0, { {T,0},{T,1*1} }, 0,1 },
		{'rot' , 0, { {T,0} }, Tile3_Rot },
		{'fade', 0, { {T,228*4} }, 0 },
		sb.concadd(CrossMove)
	}
)

-- Cross
storyboard:newObject('sb/CrossA.png', 'Background', 'TopLeft', 550,357):add(
	{'origin_scale',
		translate = CROSS_A_ORIGIN,
		{'rot' , 0, { {T,0} }, CROSS_A_ROT },
		{'col' , 0, { {T,0} }, GRAY(0.44) },
		{'fade', 0, { {T,0},{T,2*1} }, 0,1 },
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
		{'fade', 0, { {T,228*4} }, 0 },
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
