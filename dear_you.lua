package.path = "./?.lua;./?/init.lua;" .. package.path
local sb = require('sbhelper')

storyboard = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/1876396 Yuzuki - Dear You (DJ Genericname DnB Remix)/Yuzuki - Dear You (DJ Genericname DnB Remix) (NekuMagetsu).osb")
sb.file:setProjectFolder("/home/quake/.local/share/osu-wine/osu!/Songs/1876396 Yuzuki - Dear You (DJ Genericname DnB Remix)/")

storyboard:newObject("1.jpg", "Background", "Center", 320, 240):add(
	{'fade', 0, { -500, -500 }, 0,0 })
storyboard:newObject("2.jpg", "Background", "Center", 320, 240):add(
	{'fade', 0, { -500, -500 }, 0,0 })
storyboard:newObject("3.jpg", "Background", "Center", 320, 240):add(
	{'fade', 0, { -500, -500 }, 0,0 })

storyboard:writeToFile2()
