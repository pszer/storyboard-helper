local sb = require 'sbhelper'

storyboard = sb:new("./loop.osb")

--         BPM, offset
redline = {120, 1000}

-- object definition
storyboard:newObject("test.png", "Background", "Center", 320, 240):add(
	{
		'loop', loop_count=50,
		  {"00:01:100"},
			{'move', 0, {0, 100}, {200,200}, {400,200}}
	}
)

storyboard:writeToFile()
