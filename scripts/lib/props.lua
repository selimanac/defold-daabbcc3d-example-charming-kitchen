local data = require("scripts.lib.data")
local collision = require("scripts.lib.collision")
local const = require("scripts.lib.const")
local utils = require("scripts.lib.utils")
local audio = require("scripts.lib.audio")

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
	audio.play(audio.FX.PICK)

	prop_position           = prop_position and prop_position or nil
	prop_rotation           = prop_rotation and prop_rotation or nil

	local prop              = utils.table_copy(data.props[prop_name])
	local factory_url       = const.FACTORIES.PROP
	factory_url.fragment    = prop_name

	prop.id                 = factory.create(factory_url, prop_position, prop_rotation)
	prop.model_url          = msg.url(prop.id)
	prop.model_url.fragment = prop.name


	local collision_bits = bit.bor(collision.bits.TRASH)
	for _, collision_bit in ipairs(prop.collider) do
		collision_bits = bit.bor(collision_bits, collision.bits[collision_bit])
	end
	prop.collision_bit = prop.collider and collision_bits or nil


	collision_bits = bit.bor(collision.bits.TRASH)
	for _, collision_bit in ipairs(prop.ray_targets) do
		collision_bits = bit.bor(collision_bits, collision.bits[collision_bit])
	end
	prop.ray_collision_bit = prop.ray_targets and collision_bits or nil

	return prop
end

function props.pick(prop)
	audio.play(audio.FX.PICK)

	collision.remove(prop.aabb_id)

	if prop.is_corner then
		collision.remove(prop.aabb_ids["left"])
		collision.remove(prop.aabb_ids["right"])
	end

	data.room_props[prop.aabb_id] = nil
end

function props.set(prop, prop_offset, rotated_prop_size)
	prop_offset       = prop_offset and prop_offset or vmath.vector3()
	rotated_prop_size = rotated_prop_size and rotated_prop_size or vmath.vector3()

	go.set_parent(prop.id, const.URLS.ROOM_CONTAINER, true)

	audio.play(audio.FX.POP)

	go.animate(prop.id, "scale", go.PLAYBACK_ONCE_PINGPONG, vmath.vector3(0.9, 1.3, 1), go.EASING_INSINE, 0.2)

	prop.position                 = go.get_world_position(prop.id)
	prop.rotation                 = go.get_world_rotation(prop.id)
	prop.prop_offset              = prop_offset
	prop.collider_position_offset = prop.position + prop_offset
	prop.rotated_prop_size        = rotated_prop_size

	if prop.corner then
		prop.is_corner            = true
		prop.aabb_ids             = {}
		local corner_left_size    = vmath.vector3(prop.corner.left.size[1], prop.corner.left.size[2], prop.corner.left.size[3])
		corner_left_size          = vmath.rotate(prop.rotation, corner_left_size)
		corner_left_size.x        = math.abs(corner_left_size.x)
		corner_left_size.y        = math.abs(corner_left_size.y)
		corner_left_size.z        = math.abs(corner_left_size.z)

		local corner_left_offset  = vmath.vector3(prop.corner.left.offset[1], prop.corner.left.offset[2], prop.corner.left.offset[3])
		corner_left_offset        = vmath.rotate(prop.rotation, corner_left_offset)

		prop.aabb_ids["left"]     = collision.insert_aabb(prop.position - corner_left_offset, corner_left_size.x, corner_left_size.y, corner_left_size.z, collision.bits.PROPS)

		local corner_right_size   = vmath.vector3(prop.corner.right.size[1], prop.corner.right.size[2], prop.corner.right.size[3])
		corner_right_size         = vmath.rotate(prop.rotation, corner_right_size)
		corner_right_size.x       = math.abs(corner_right_size.x)
		corner_right_size.y       = math.abs(corner_right_size.y)
		corner_right_size.z       = math.abs(corner_right_size.z)

		local corver_right_offset = vmath.vector3(prop.corner.right.offset[1], prop.corner.right.offset[2], prop.corner.right.offset[3])
		corver_right_offset       = vmath.rotate(prop.rotation, corver_right_offset)

		prop.aabb_ids["right"]    = collision.insert_aabb(prop.position - corver_right_offset, corner_right_size.x, corner_right_size.y, corner_right_size.z, collision.bits.PROPS)


		prop.aabb_id = collision.insert_aabb(prop.collider_position_offset, prop.rotated_prop_size.x, prop.rotated_prop_size.y, prop.rotated_prop_size.z, collision.bits.PROPS_CONTAINER)
	else
		prop.is_corner = false
		prop.aabb_id   = collision.insert_aabb(prop.collider_position_offset, prop.rotated_prop_size.x, prop.rotated_prop_size.y, prop.rotated_prop_size.z, collision.bits.PROPS)
	end

	data.room_props[prop.aabb_id] = prop

	return prop
end

function props.rotate(rotation, active_prop)
	local rotated_prop_size = vmath.rotate(rotation, active_prop.size)
	rotated_prop_size.x = math.abs(rotated_prop_size.x)
	rotated_prop_size.y = math.abs(rotated_prop_size.y)
	rotated_prop_size.z = math.abs(rotated_prop_size.z)

	local prop_offset = vmath.rotate(rotation, active_prop.offset)

	go.set_rotation(rotation, active_prop.id)

	return rotated_prop_size, prop_offset
end

return props
