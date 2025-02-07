local data = require("scripts.lib.data")
local libcamera = require("scripts.lib.libcamera")


local cursor = {}

local CURSOR_URL = "/cursor"

function cursor.input(action_id, action)
	libcamera.get_mouse_ray(action.x, action.y, data.cursor)
	--	pprint(data.cursor)
end

return cursor
