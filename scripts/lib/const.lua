local const            = {}
const.BACKGROUND_COLOR = vmath.vector4(255 / 255, 228 / 255, 245 / 255, 1)

const.SHADOW_SETTINGS  = {
	projection_width  = 30,
	projection_height = 30,
	projection_near   = -100,
	projection_far    = 100,
	depth_bias        = 0.002, -- Usually, it's 0.00002 for perspective and 0.002 for orthographic projection.
	shadow_opacity    = 0.2, -- Shadow opacity
	buffer_size       = 2048
}

const.LIGHT_SETTINGS   = {
	source = '/light_source',
	target = '/light_target',
	diffuse_light_color = vmath.vector3(0.7), -- Diffuse light color
}

const.TRIGGERS         = {
	MOUSE_BUTTON_1 = hash("MOUSE_BUTTON_1"),
	MOUSE_WHEEL_UP = hash("MOUSE_WHEEL_UP"),
	MOUSE_WHEEL_DOWN = hash("MOUSE_WHEEL_DOWN"),
}

const.FACTORIES        = {
	PROBS = {},
	ROOMS = {
		[1] = "/factories#room_1"
	}
}

const.MSG              = {
	PICK_PROBE = hash("pick_probe")
}

const.CURSOR           = "/cursor"

return const
