local iqm = require "iqm-exm"

return function ( fpath )

	local function readIQM(fname, save_data, preserve_cw)
		local finfo = love.filesystem.getInfo(fname)
		if not finfo or finfo.type ~= "file" then return nil, string.format("couldn't open model file \"%s\"", fname) end

		local objs = iqm.load(fname, save_data, preserve_cw)
		--local objs = iqm.load(fname, save_data, preserve_cw)
		if not objs then return nil, string.format("invalid IQM file \"%s\"", fname) end

		return objs, ""
	end

	local function readIQMAnimations(fname)
		local finfo = love.filesystem.getInfo(fname)
		if not finfo or finfo.type ~= "file" then return nil, string.format("couldn't open model animation file \"%s\"", fname) end

		local anims = iqm.load_anims(fname)
		if not anims then return nil, string.format("invalid IQM animations in file \"%s\"", fname) end

		return anims, ""
	end

	local objs, err_str = readIQM(fpath, false, preserve_cw)

	if not objs then error("no objs "..err_str) end

	local anims, err_str = nil, ""
	anims, err_str_a = readIQMAnimations(fpath)
	if not anims then
		error("no anims "..err_str) end

	return objs, anims
end
