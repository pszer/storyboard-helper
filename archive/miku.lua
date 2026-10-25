-- img sources
--
-- https://e-shuushuu.net/images/82356
-- https://safebooru.org/index.php?page=post&s=view&id=121448

package.path = "./?.lua;./?/init.lua;" .. package.path
local sb = require('sbhelper')

storyboard = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/1913606 ClavierP - Hatsune Miku ni yoru Tonsokyoku Ogi Sono 14/ClavierP - Hatsune Miku ni yoru Tonsokyoku Ogi Sono 14 (tsarbomba).osb")
sb.file:setProjectFolder("/home/quake/.local/share/osu-wine/osu!/Songs/1913606 ClavierP - Hatsune Miku ni yoru Tonsokyoku Ogi Sono 14/")

storyboard:newObject("bg.jpg", "Background", "Center", 320, 240):add(
	{'fade', 0, { -300, -300 }, 0,0 })

local T = {119.990, 1256}

local function SheetPath(i)
	return string.format('sb/%s.png', i)
end

local PerSheet = {
	[1] = 4,
	[2] = 3,
	[3] = 3,
	[4] = 3,
	[5] = 3,
	[6] = 3,
	[7] = 3,
	[8] = 3,
	[9] = 3,
	[10] = 2,
	[11] = 2,
	[12] = 3,
	[13] = 2,
	[14] = 2,
	[15] = 2,
	[16] = 2,
	[17] = 2,
	[18] = 2,
	[19] = 2,
	[20] = 2,
	[21] = 3,
	[22] = 3,
	[23] = 3,
	[24] = 3,
	[25] = 3,
	[26] = 3,
	[27] = 3,
	[28] = 3,
	[29] = 3,
	[30] = 2,
	[31] = 2,
	[32] = 2,
	[33] = 3,
	[34] = 2,
	[35] = 2,
	[36] = 2,
	[37] = 2,
	[38] = 2,
	[39] = 2,
	[40] = 2,
	[41] = 2,
	[42] = 3,
	[43] = 3,
}
local PerSheet_Yoff = {
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 0,
	[5] = 0,
	[6] = 0,
	[7] = 0,
	[8] = 0,
	[9] = 0,
	[10] = 0,
	[11] = 0,
	[12] = 0,
	[13] = 1,
	[14] = 2,
	[15] = 3,
	[16] = 3,
	[17] = 0,
	[18] = 0,
	[19] = 0,
	[20] = 0,
	[21] = 1,
	[22] = 0,
	[23] = 0,
	[24] = 0,
	[25] = 0,
	[26] = 0,
	[27] = 0,
	[28] = 0,
	[29] = 0,
	[30] = 0,
	[31] = 1,
	[32] = 1,
	[33] = 2,
	[34] = 4,
	[35] = 4,
	[36] = 2,
	[37] = 1,
	[38] = 1,
	[39] = 1,
	[40] = 1,
	[41] = 1,
	[42] = 2,
	[43] = 6,
}

local SheetLeft = {168,82}
local SheetRight = {800,82}
local SheetLeft_1 = {249,82}
local SheetRight_1 = {800,82}
local PerSheet_Xs = {
	[1]={339,496,655},--816
	[2]={342,577},
	[3]={350,582},
	[4]={360,620},
	[5]={350,573},
	[6]={350,586},
	[7]={340,554},
	[8]={344,570},
	[9]={351,556},
	[10]={499},
	[11]={470},
	[12]={354,560},
	[13]={454},
	[14]={460},
	[15]={438},
	[16]={452},
	[17]={443},
	[18]={466},
	[19]={489},
	[20]={439},
	[21]={414,619},
	[22]={318,531},
	[23]={347,585},
	[24]={339,566},
	[25]={388,586},
	[26]={335,578},
	[27]={349,575},
	[28]={333,597},
	[29]={332,572},
	[30]={441},
	[31]={496},
	[32]={471},
	[33]={356,562},
	[34]={455},
	[35]={460},
	[36]={440},
	[37]={455},
	[38]={445},
	[39]={465},
	[40]={491},
	[41]={439},
	[42]={375,551},
	[43]={435,714},
}
for i,v in ipairs(PerSheet_Xs) do
	for j,w in pairs(v) do
		v[j]=w+50 -- first note in a bar is usually +15px to the right of the bar line
	end

	table.insert(v,856)
	if #v ~= PerSheet[i] then
		error("Mismatch at "..tostring(i))
	end
	v[0] = SheetLeft[1]
	if i==1 then
		v[0] = SheetLeft_1[1]
	end
end

local LineOpacity = 0.9
local SheetLineAtts = {}
local Count=0
for i=1,#PerSheet do
	local R = {
		{'fade', 'cubicOut', {{T,Count*4-0.2} , {T, Count*4+0.05}}, 0, LineOpacity},
		{'fade', 'cubicOut', {{T,(Count+PerSheet[i])*4-0.4} , {T,(Count+PerSheet[i])*4-0.2}}, LineOpacity, 0},
	}
	if i==43 then
		R[2] = {'fade',  0, { {T, 108.5*4}, {T, 110*4}}, 1,0 }
	end

	for j=0,PerSheet[i]-1 do
		table.insert(R, {'move', 0, {{T,Count*4 + j*4-0.15},{T, Count*4 + (j+1)*4-0.15}}, 
			{PerSheet_Xs[i][j], SheetLeft[2]}, {PerSheet_Xs[i][j+1], SheetLeft[2]} })
	end

	-- concatenate
	for _,v in ipairs(R) do
		table.insert(SheetLineAtts,v) end

	Count = Count+PerSheet[i]
end

Count=PerSheet[1]

local SheetX = 309
local SheetPos1 = {SheetX,355}
local SheetPos1_1 = {SheetX,351}
local SheetPos2 = {SheetX,473}

local SheetScale = 0.52

for i=2,43 do
	local Prev = i-1
	local Next = i+1
	
	local From = Count - PerSheet[Prev]
	local To   = Count + PerSheet[i] - 0.5


	local FadeIn = {'fade', 'cubicOut', {{T,From*4-0.2},{T,From*4+0.1}},0,1}
	local FadeOut =  {{'fade', 'cubicOut', {{T,To*4+1.5},{T,To*4+1.9}},1,0}}
	if i==2 then
		FadeIn = {'fade', 'cubicOut', {-1800},0,1}
	end
	if i==43 then
		FadeOut = {{'fade',  0, {{T, 110*4 }}, 0,0 },
		           {'color',  0, { {T, 108.5*4}, {T, 110*4}}, {255,255,255},{0,0,0} }}
	end

	local Coms = {

		FadeIn,
		{'scale',0, {{T,From}}, SheetScale },

		{'move', 0         , {{T,From*4}}, {SheetPos2[1], SheetPos2[2] + PerSheet_Yoff[i]} },
		{'move', 'cubicOut', {{T,(From+PerSheet[Prev])*4-0.75}, {T,(From+PerSheet[Prev])*4+0.2}},
			{SheetPos2[1], SheetPos2[2] + PerSheet_Yoff[i]},
			{SheetPos1[1], SheetPos1[2] + PerSheet_Yoff[i]}},
		sb.concadd(FadeOut)

	}

	storyboard:newObject(SheetPath(i), "Foreground", "BottomCentre", 320,480):add(sb.unpack(Coms))

	Count = Count + PerSheet[i]
end


local function GetSheetXY(t)
	local v = {}
	v[1] = SheetLeft[1] + (SheetRight[1]-SheetLeft[1]) * t
	v[2] = SheetLeft[2]
	return v 
end
local function GetSheetXY_1(t)
	local v = {}
	v[1] = SheetLeft_1[1] + (SheetRight_1[1]-SheetLeft_1[1]) * t
	v[2] = SheetLeft_1[2]
	return v 
end

storyboard:newObject(SheetPath(1), "Foreground", "BottomCentre", SheetX,480):add(
		{'fade', 'cubicOut', {-1800},0,1},
		{'fade', 'cubicOut', {{T,4*4-0.8},{T,4*4-0.2}},1,0},
		{'scale',0, {-1800}, SheetScale },

		{'move', 0         , {-1800}, SheetPos1_1}
		--{'move', 'cubicOut', {{T,(From+PerSheet[Prev])*4-0.4}, {T,(From+PerSheet[Prev])*4+0.1}}, SheetPos2, SheetPos1},
)

local GRADIENT_SCALE = {
	854/148,
	(480-250)/1080,
}
storyboard:newObject("sb/Gradient.jpg", "Background", "BottomCenter", 320, 480):add(
	{'fade',  0, { -1800, -1800 }, 0,1 },
	{'vector',0, { -1800, -1800 }, GRADIENT_SCALE },
	{'fade',  0, { {T,110*4} }, 0,0 },
	{'color',  0, { {T, 108.5*4}, {T, 110*4}}, {255,255,255},{0,0,0} }
)

storyboard:newObject("sb/Paper.png", "Background", "BottomCenter", SheetX, 480):add(
	{'fade',  0, { -1800, -1800 }, 0,1 },
	{'scale',0, { -1800, -1800 }, SheetScale },
	{'fade',  0, { {T,110*4} }, 0,0 },
	{'color',  0, { {T, 108.5*4}, {T, 110*4}}, {255,255,255},{0,0,0} }
)

local MikuAtts = {
	{'scale',0, {-1800}, 0.45 },
	{'move' ,0, {-1800}, {593,475}}
}

local MikuCirc = 3.5
for i=-2,108,4 do
	table.insert(MikuAtts, {'moverel', 'sineOut', {{T,i*4}, {T,i*4+1*4}}, {0,0}, {0,MikuCirc}})
	table.insert(MikuAtts, {'moverel', 'sineIn', {{T,i*4+1*4}, {T,i*4+2*4}}, {0,0}, {0,-MikuCirc}})
	table.insert(MikuAtts, {'moverel', 'sineOut', {{T,i*4+2*4}, {T,i*4+1+3*4}}, {0,0}, {0,-MikuCirc}})
	table.insert(MikuAtts, {'moverel', 'sineIn', {{T,i*4+3*4}, {T,i*4+4*4}}, {0,0}, {0,MikuCirc}})

	table.insert(MikuAtts, {'moverel', 'sineIn', {{T,i*4}, {T,i*4+1*4}}, {0,0}, {MikuCirc,0}})
	table.insert(MikuAtts, {'moverel', 'sineOut', {{T,i*4+1*4}, {T,i*4+2*4}}, {0,0}, {MikuCirc,0}})
	table.insert(MikuAtts, {'moverel', 'sineIn', {{T,i*4+2*4}, {T,i*4+1+3*4}}, {0,0}, {-MikuCirc,0}})
	table.insert(MikuAtts, {'moverel', 'sineOut', {{T,i*4+1+3*4}, {T,i*4+4*4}}, {0,0}, {-MikuCirc,0}})
end

storyboard:newObject("sb/Line.png", "Foreground", "TopCentre", 320, 480):add(
	{'scale',0,{ -1800 }, SheetScale },
	{'color', 0,{ -1800 }, {139,236,196} },
	{'origin_scale',
		translate={SheetX - SheetScale*993*0.5+2, 480-(480+13)*SheetScale+3},
		scale={SheetScale,SheetScale},
		sb.concadd(SheetLineAtts)}
)

storyboard:newObject("sb/MikuShadow.png", "Foreground", "BottomCenter", 320, 480):add(
	{'fade',  0, { -1800, -1800 }, 0,0.12 },
	{'fade',  0, { {T,110*4} }, 0,0 },
	{'color',  0, { {T, 108.5*4}, {T, 110*4}}, {255,255,255},{0,0,0} },
	{'move' ,0, {-1800}, {593,480}}
)

storyboard:newObject("sb/Miku2.png", "Foreground", "BottomCenter", 320, 480):add(
	{'fade',  0, { -1800, -1800 }, 0,1 },
	{'fade',  0, { {T,1} }, 0 },
	{'fade',  0, { {T,53*4} }, 1 },
	{'fade',  0, { {T,56*4+1} }, 0 },
	sb.concadd(MikuAtts)
)
storyboard:newObject("sb/Miku1.png", "Foreground", "BottomCenter", 320, 480):add(
	{'fade',  0, { {T,0}, {T,1} }, 0,1 },
	{'fade',  0, { {T,53*4}, {T,53*4+2} }, 1,0 },
	{'fade',  0, { {T,56*4}, {T,56*4+1} }, 0,1 },
	{'fade',  0, { {T,110*4} }, 0,0 },
	{'color',  0, { {T, 108.5*4}, {T, 110*4}}, {255,255,255},{0,0,0} },
	sb.concadd(MikuAtts)
)

storyboard:newObject("sb/Top.jpg", "Background", "TopCenter", 320, 0):add(
	{'fade',  0, { -1800, -1800 }, 0,1 },
	{'scale',0, { -1800, -1800 }, 0.5 },
	{'fade',  0, { {T,110*4} }, 0,0 },
	{'color',  0, { {T, 108.5*4}, {T, 110*4}}, {255,255,255},{0,0,0} }
)

sb.config["default-easing-keyframing-epsilon"] = 0.5
storyboard:writeToFile2()
