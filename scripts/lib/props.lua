local data = require("scripts.lib.data")
local collision = require("scripts.lib.collision")
local const = require("scripts.lib.const")

local props = {}


function props.init()
	local json_data, error = sys.load_resource(const.PROPS_DATA)

	if error then
		print(error)
		return
	end

	if json_data == nil then
		print("No data")
		return
	end

	data.props = json.decode(json_data)
	local count = 0
	for title, prop in pairs(data.props) do
		prop.size = vmath.vector3(prop.size[1], prop.size[2], prop.size[3])
		prop.offset = vmath.vector3(prop.offset[1], prop.offset[2], prop.offset[3])
		prop.name = title
		count = count + 1
	end
	print("Prop Count: ", count)


	msg.post(const.URLS.GUI, const.MSG.SETUP_GUI)
end

function props.create(prop_name, prop_position, prop_rotation)
	prop_position = prop_position and prop_position or nil
	prop_rotation = prop_rotation and prop_rotation or nil

	local prop = data.props[prop_name]
	local factory_url = const.FACTORIES.PROP
	factory_url.fragment = prop_name

	prop.id = factory.create(factory_url, prop_position, prop_rotation)

	return prop
end

function props.set(prop, prop_offset, rotated_prop_size)
	prop_offset       = prop_offset and prop_offset or vmath.vector3()
	rotated_prop_size = rotated_prop_size and rotated_prop_size or vmath.vector3()

	go.set_parent(prop.id, const.URLS.ROOM_CONTAINER, true)
	go.animate(prop.id, "scale", go.PLAYBACK_ONCE_PINGPONG, vmath.vector3(0.9, 1.3, 1), go.EASING_INSINE, 0.2)

	prop.position                 = go.get_world_position(prop.id)
	prop.rotation                 = go.get_world_rotation(prop.id)
	prop.prop_offset              = prop_offset
	prop.collider_position_offset = prop.position + prop_offset
	prop.rotated_prop_size        = rotated_prop_size
	prop.aabb_id                  = collision.insert_aabb(prop.collider_position_offset, prop.rotated_prop_size.x, prop.rotated_prop_size.y, prop.rotated_prop_size.z, collision.bits.PROPS)

	data.room_props[prop.aabb_id] = prop

	return prop
end

return props
