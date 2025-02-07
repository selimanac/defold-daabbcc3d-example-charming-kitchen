local probs = require("scripts.lib.probs")
local cursor = require("scripts.lib.cursor")
local render_helper = require("render.render_helper")
local const = require("scripts.lib.const")

local manager = {}

local function set_garbage()
	print("collectgarbage before: ", collectgarbage("count"))
	collectgarbage("collect")
	print("collectgarbage after: ", collectgarbage("count"))

	collectgarbage("setstepmul", 1000);
	collectgarbage('setpause', 1000);
end

function manager.init()
	msg.post("@render:", "clear_color", { color = const.BACKGROUND_COLOR })


	probs.init()


	render_helper.init(const.LIGHT_SETTINGS, const.SHADOW_SETTINGS)
	set_garbage()
end

function manager.update(dt)

end

function manager.input(action_id, action)
	cursor.input(action_id, action)
end

return manager
