local probs = require("scripts.lib.probs")
local cursor = require("scripts.lib.cursor")
local render_helper = require("render.render_helper")
local const = require("scripts.lib.const")
local libcamera = require("scripts.lib.libcamera")
local room = require("scripts.lib.room")
local data = require("scripts.lib.data")

local manager = {}

local function set_garbage()
	print("collectgarbage before: ", collectgarbage("count"))
	collectgarbage("collect")
	print("collectgarbage after: ", collectgarbage("count"))

	collectgarbage("setstepmul", 1000);
	collectgarbage('setpause', 1000);
end

function manager.init(camera_settings)
	msg.post("@render:", "clear_color", { color = const.BACKGROUND_COLOR })
	if profiler then
		profiler.enable_ui(true)
		profiler.set_ui_view_mode(profiler.VIEW_MODE_MINIMIZED)
	end
	data.game_manager = msg.url(".")
	pprint(data.game_manager)
	probs.init()
	libcamera.init(camera_settings)
	render_helper.init(const.LIGHT_SETTINGS, const.SHADOW_SETTINGS)
	room.init()

	set_garbage()
end

function manager.message(message_id, message, sender)
	cursor.message(message_id, message, sender)
end

function manager.update(dt)
	libcamera.update(dt)
	cursor.update(dt)
end

function manager.input(action_id, action)
	cursor.input(action_id, action)
	libcamera.input(action_id, action)
end

return manager
