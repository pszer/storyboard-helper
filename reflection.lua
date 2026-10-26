package.path = "./?.lua;./?/init.lua;" .. package.path
local sb = require('sbhelper')

storyboard = sb:new("/home/quake/.local/share/osu-wine/osu!/Songs/2593386 tofubeats - REFLECTION (feat Kaho Nakamura)/tofubeats - REFLECTION (feat. Kaho Nakamura) (Tukura).osb")
sb.file:setProjectFolder("/home/quake/.local/share/osu-wine/osu!/Songs/2593386 tofubeats - REFLECTION (feat Kaho Nakamura)/")

local T = {184.100, 0}

sb.tri:initTriSet(256,210,'T/')
sb.config["3d-disable-vertex-shading"] = false

local camera_frames = sb.c3d:loadFile('camera_animation.lua')
--local pos,quat,fov = sb.c3d:getCameraFrame(camera_frames, 500.0, false)
--print(pos[1],pos[2],pos[3],quat,fov)

local params = { pool_sprites = sb.tri.file_set }
--sb.config['silence-headers'] = true
-- disable pooling 4 compile speeed
params = nil
storyboard:writeToFile2(nil, params)
