local props         = require("scripts.lib.props")
local cursor        = require("scripts.lib.cursor")
local render_helper = require("render.render_helper")
local const         = require("scripts.lib.const")
local libcamera     = require("scripts.lib.libcamera")
local room          = require("scripts.lib.room")
local data          = require("scripts.lib.data")
local file          = require("scripts.lib.file")
local audio         = require("scripts.lib.audio")

local manager       = {}

local function collect_garbage()
	print("garbage before: ", collectgarbage("count"))
	collectgarbage("collect")
	print("garbage after: ", collectgarbage("count"))

	collectgarbage("setstepmul", 1000);
	collectgarbage('setpause', 1000);
end

local function toogle_profiler()
	data.game_settings.profiler = not data.game_settings.profiler and true or false
	data.game_settings.collider_debug = not data.game_settings.collider_debug and true or false

	if profiler then
		profiler.enable_ui(data.game_settings.profiler)
		profiler.set_ui_view_mode(profiler.VIEW_MODE_MINIMIZED)
	end
end

local function setup_urls()
	for key, url in pairs(const.URLS) do
		const.URLS[key] = msg.url(url)
	end

	for factory_key, factory_url in pairs(const.FACTORIES) do
		if type(factory_url) == "table" then
			for i, v in ipairs(factory_url) do
				factory_url[i] = msg.url(v)
			end
		else
			const.FACTORIES[factory_key] = msg.url(factory_url)
		end
	end
end

function manager.init(camera_settings, game_settings)
	msg.post("@render:", "clear_color", { color = const.BACKGROUND_COLOR })

	setup_urls()

	data.init(game_settings)
	props.init()
	libcamera.init(camera_settings)
	render_helper.init(const.LIGHT_SETTINGS, const.SHADOW_SETTINGS)
	room.init()

	collect_garbage()

	audio.init()
end

function manager.message(message_id, message, sender)
	cursor.message(message_id, message, sender)
	file.message(message_id, message, sender)
end

function manager.update(dt)
	libcamera.update(dt)
	cursor.update(dt)
	audio.update(dt)
end

function manager.input(action_id, action)
	cursor.input(action_id, action)
	libcamera.input(action_id, action)

	if action_id == const.TRIGGERS.KEY_D and action.pressed then
		toogle_profiler()
	end
end

return manager
