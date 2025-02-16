local const = require("scripts.lib.const")
local data = require("scripts.lib.data")
local collision = require("scripts.lib.collision")
local props = require("scripts.lib.props")

local room = {}

local ROOM_COLLIDERS = {
	ROOM_1 = {
		COLLIDERS = {
			[hash("/collider_ground")] = {
				type = collision.bits.GROUND,
				direction = const.VECTOR.UP

			},
			[hash("/collider_wall_1")] = {
				type = collision.bits.WALLS,
				direction = const.VECTOR.FORWARD

			},
			[hash("/collider_wall_2")] = {
				type = collision.bits.WALLS,
				direction = const.VECTOR.RIGHT
			},
			[hash("/collider_trash")] = {
				type = collision.bits.TRASH
			}
		},
		ITEMS = {
			TRASH = hash("/trash")
		}
	}
}

local function add_trash(id)
	data.room_trash.id = id
	data.room_trash.model_url = msg.url(id)
	data.room_trash.model_url.fragment = "trash"
end

function room.init(room_number)
	data.room_number = room_number and room_number or 1

	local room_ids = collectionfactory.create(const.FACTORIES.ROOMS[data.room_number])

	add_trash(room_ids[hash("/trash")])


	for id, collider in pairs(ROOM_COLLIDERS["ROOM_" .. data.room_number].COLLIDERS) do
		local position = go.get_world_position(room_ids[id])
		local size = go.get_scale(room_ids[id])
		local aabb_id = collision.insert_aabb(position, size.x, size.y, size.z, collider.type)

		local item = {
			id = room_ids[id],
			position = position,
			size = size,
			aabb_id = aabb_id,
			type = collider.type,
			direction = collider.direction
		}

		data.room_colliders[aabb_id] = item
	end
end

function room.reset()
	for aabb_id, prop in pairs(data.room_props) do
		collision.remove(aabb_id)
		if prop.is_corner then
			collision.remove(prop.aabb_ids["left"])
			collision.remove(prop.aabb_ids["right"])
		end
		go.delete(prop.id)
	end
	data.room_props = {}
end

function room.generate(room_props)
	for aabb_id, prop in pairs(room_props) do
		local new_prop = props.create(prop.name, prop.position, prop.rotation)
		props.set(new_prop, prop.prop_offset, prop.rotated_prop_size)
	end
end

return room
