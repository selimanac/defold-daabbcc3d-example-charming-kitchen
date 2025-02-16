local const            = {}

const.PLANE_POINT      = vmath.vector3(2, 6, 6)
const.BACKGROUND_COLOR = vmath.vector4(255 / 255, 228 / 255, 245 / 255, 1)
const.PROPS_DATA       = "/data/props.json"
const.CURSOR           = "/cursor"

const.VECTOR           = {
	UP = vmath.vector3(0, 1, 0),
	BACK = vmath.vector3(0, 0, -1),
	DOWN = vmath.vector3(0, -1, 0),
	FORWARD = vmath.vector3(0, 0, 1),
	LEFT = vmath.vector3(-1, 0, 0),
	RIGHT = vmath.vector3(1, 0, 0)
}

const.SHADOW_SETTINGS  = {
	projection_width  = 20,
	projection_height = 20,
	projection_near   = -80,
	projection_far    = 80,
	depth_bias        = 0.0008, -- Usually, it's 0.00002 for perspective and 0.002 for orthographic projection.
	shadow_opacity    = 0.2, -- Shadow opacity
	buffer_size       = 2048
}

const.LIGHT_SETTINGS   = {
	source = '/container/light_source',
	target = '/container/light_target',
	diffuse_light_color = vmath.vector3(0.7), -- Diffuse light color
}

const.TRIGGERS         = {
	MOUSE_BUTTON_1 = hash("MOUSE_BUTTON_1"),
	MOUSE_BUTTON_3 = hash("MOUSE_BUTTON_3"),
	MOUSE_WHEEL_UP = hash("MOUSE_WHEEL_UP"),
	MOUSE_WHEEL_DOWN = hash("MOUSE_WHEEL_DOWN"),
	KEY_UP = hash("KEY_UP"),
	KEY_SPACE = hash("KEY_SPACE"),
	KEY_D = hash("KEY_D")
}

const.FACTORIES        = {
	PROP = "/container/prop_factories",
	ROOMS = {
		[1] = "/container/factories#room_1"
	}
}

const.MSG              = {
	ADD_PROP = hash("add_prop"),
	SETUP_GUI = hash("setup_gui"),
	SAVE_ROOM = hash("save_room"),
	LOAD_ROOM = hash("load_room"),
	SAVE_LOAD_ROOM_COMPLETE = hash("save_load_room_complete"),
	RESET_ROOM = hash("reset_room")
}

const.URLS             = {
	MANAGER = "/scripts#game",
	GUI = "/game_gui#game",
	ROOM_CONTAINER = "/container/room_container"
}

return const
