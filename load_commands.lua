local command = require 'commands'
local sb_verify = require 'verify'
local sb_config = require 'config'
local sb_ir     = require 'ir'
local sb_log    = require 'log'
local sb_eval   = require 'eval'

-- def - command definition
--
--       * if this is a table, then this table is used as a the definition
--
--       * if this is a string, it is treated as a filepath and searched using packing.searchpath, same as
--       require. it is expected that this file returns a table to be used as the definition. this
--       method is preferrable since it loads the file in an environment with various bits of code
--       like like 'command.lua', 'verify.lua' and 'ir.lua' loaded, so that the file doesn't need to
--       manually require() these files.
--
--
-- ... - (variable number of) string keys for the command.
command.___lock_out = false
function command:addDefinition(def, ...)
	if type(def) == "string" then
		local env = setmetatable({
			sb_com    = command,
			sb_verify = sb_verify,
			sb_config = sb_config,
			sb_ir  = sb_ir,
			sb_log = sb_log,
			sb_eval = sb_eval,
		}, {__index=_G})

		local searchf, searcherr = package.searchpath(def, package.path)
		sb_log:assert(searchf, "command.addDefinition(): couldn't get %s, %s", def, searcherr)
		local chunk = loadfile(searchf, "t", env)
		sb_log:assert(chunk, "command.addDefinition(): couldn't loadfile %s", def)
		def = chunk()

		sb_log:assert(type(def)=="table", "command.addDefinition(): expected table, file returned '%s'", type(def))
	elseif type(def) ~= "table" then
		sb_log:error("command.addDefinition(): expected filepath or table, got '%s'.", type(def))
	end

	sb_log:assert(def, "command.addDefinition(): missing command definition.")
	local keys = {...}
	sb_log:assert(#keys > 0, "command.addDefinition(): missing key names to assign to this command")

	local definition_str = " for \'"..keys[1].."\'"

	sb_log:assert(type(def.easing)=="boolean", "command.addDefinition(): malformed easing definition"..definition_str)
	sb_log:assert(type(def.time_points)=="number"
	              and math.type(def.time_points)=="integer"
								and def.time_points >= 0, "command.addDefinition(): malformed time points definition"..definition_str)
	sb_log:assert(type(def.dimension)=="number"
	              and math.type(def.dimension)=="integer"
								and def.time_points >= 0, "command.addDefinition(): malformed dimension(s) definition"..definition_str)

	sb_log:assert(type(def.args)=="table" or type(def.args)=="nil",
								"command.addDefinition(): malformed arg(s) table definition"..definition_str)
	for i,v in ipairs(def.args or {}) do
		sb_log:assert(type(v)=="string", "command.addDefinition(): malformed arg(s) table definition"..definition_str)
	end

	sb_log:assert(type(def.args_valid)=="table" or type(def.args_valid)=="nil",
								"command.addDefinition(): malformed arg(s) valid functions table definition"..definition_str)
	for i,v in pairs(def.args_valid or {}) do
		sb_log:assert(type(v)=="function" or type(v)=="nil", "command.addDefinition(): malformed arg(s) valod functions table definition"..definition_str)
	end
	sb_log:assert(type(def.varargs)=="boolean", "command.addDefinition(): malformed variable args definition"..definition_str)
	sb_log:assert(not (type(def.out)=="function" and command.___lock_out),
		"command.addDefinition(): the out function are fixed for primitives only.")


	sb_log:assert(type(def.overlapping)=="boolean" or def.overlapping==nil, "command.addDefinition(): malformed overlapping flag definition"..definition_str)
	def.overlapping = def.overlapping==true
	if def.overlapping then
		sb_log:assert(type(def.absolute_equal)=="string", "command.addDefinition(): malformed absolute_equal specifier definition"..definition_str)
	end

	sb_log:assert(type(def.eval)=="function" or type(def.eval)=="nil", "command.addDefinition(): malformed eval defintion"..definition_str)

	for i,v in ipairs(keys) do
		local str = v
		sb_log:assert(type(str)=="string",
			"command.addDefinition(): only strings are allowed to be used as keys for commands, got a '%s'.", type(str))
		str = str:lower()
		sb_log:assert(rawget(command,str)==nil, "command.addDefinition(): key [\"%s\"] is already in use.", str)
		command[str] = def
	end
end

command:addDefinition('commands.root'       , '__root__', 'root','eval')
command:addDefinition('commands.move'       , 'm', 'move')
command:addDefinition('commands.movex'      , 'mx', 'movex', 'move_x', 'm_x')
command:addDefinition('commands.movey'      , 'my', 'movey', 'move_y', 'm_y')
command:addDefinition('commands.fade'       , 'f', 'fade')
command:addDefinition('commands.rotate'     , 'r', 'rotate', 'rot')
command:addDefinition('commands.scale'      , 's', 'scale')
command:addDefinition('commands.vector'     , 'v', 'vector', 'vectorscale', 'vector_scale')
command:addDefinition('commands.parameter'  , 'p', 'parameter', 'param')
command:addDefinition('commands.colour'     , 'c', 'col', 'color', 'colour')
command:addDefinition('commands.colouradd'  , 'ca', 'cadd','coladd', 'coloradd', 'colouradd', 'c_add','col_add',
                                              'color_add', 'colour_add')
command:addDefinition('commands.colourmul'  , 'cm', 'cmul','colmul', 'colormul', 'colourmul', 'c_mul','col_mul',
                                              'color_mul', 'colour_mul')
command:addDefinition('commands.moverel'  , 'mr', 'mover', 'moverel', 'moverelative', 'm_r', 'move_r', 'move_rel', 'move_relative')
command:addDefinition('commands.rotaterel', 'rr', 'rotr', 'rotrel', 'rotrelative', 'r_r', 'rot_r', 'rot_rel', 'rot_relative',
                                            'rotater', 'rotaterel', 'rotaterelative', 'rotate_r', 'rotate_rel',
																						'rotate_relative')
command:addDefinition('commands.scalerel' , 'sr', 'scaler', 'scalerel', 'scalerelative', 's_r', 'scale_r', 'scale_rel','scale_relative')
command:addDefinition('commands.vectorrel', 'vr', 'vectorr', 'vectorrel', 'vectorrelative', 'v_r', 'vector_r', 'vector_rel',
                                            'vrel', 'v_rel', 'vector_relative')
command.___lock_out = true -- prevent future command definitions with an 'out' function

command:addDefinition('commands.originscale', 'originscale', 'os', 'origin_scale')
command:addDefinition('commands.protract', 'protract')

return command
