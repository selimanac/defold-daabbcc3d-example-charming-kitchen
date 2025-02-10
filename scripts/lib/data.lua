local data = {}

data.props = {}
data.cursor = {
	origin = vmath.vector3(),
	dir = vmath.vector3(),
	position = vmath.vector3(),
	rotation = vmath.quat(),
	is_active = false
}

data.selected_prop = {
	position = vmath.vector3()
}

data.gui_scroll = false
data.room_props = {}
data.room_colliders = {}

data.game_settings =
{
	collider_debug = false,
	profiler = false
}

function data.init(game_settings)
	data.game_settings = game_settings
end

return data
