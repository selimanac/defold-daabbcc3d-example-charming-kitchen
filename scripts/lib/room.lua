local const = require("scripts.lib.const")
local data = require("scripts.lib.data")
local collision = require("scripts.lib.collision")
local props = require("scripts.lib.props")


local room = {}

local ROOM_COLLIDERS = {
	ROOM_1 = {
		COLLIDERS = {
			[hash("/collider_ground")] = {
				type = collision.bits.GROUND

			},
			[hash("/collider_wall_1")] = {
				type = collision.bits.WALLS

			},
			[hash("/collider_wall_2")] = {
				type = collision.bits.WALLS
			},
			[hash("/collider_trash")] = {
				type = collision.bits.TRASH
			}
		}
	}
}



function room.init(room_number)
	data.room_number = room_number and room_number or 1

	local room_ids = collectionfactory.create(const.FACTORIES.ROOMS[data.room_number])

	for id, collider in pairs(ROOM_COLLIDERS["ROOM_" .. data.room_number].COLLIDERS) do
		local position = go.get_world_position(room_ids[id])
		local size = go.get_scale(room_ids[id])
		local aabb_id = collision.insert_aabb(position, size.x, size.y, size.z, collider.type)
		data.room_colliders[aabb_id] = { id = room_ids[id], position = position, size = size, aabb_id = aabb_id, type = collider.type }
	end
end

function room.reset()
	for aabb_id, prop in pairs(data.room_props) do
		collision.remove(aabb_id)
		go.delete(prop.id)
	end
	data.room_props = {}
end

function room.generate(room_props)
	for aabb_id, prop in pairs(room_props) do
		local new_prop = props.create(prop.name, prop.position, prop.rotation)

		props.set(new_prop, prop.prop_offset, prop.rotated_prop_size)

		-- if data.game_settings.collider_debug then
		-- 	go.set_scale(set_prop.rotated_prop_size, "/container/collision_debug")
		-- 	go.set_position(set_prop.collider_position_offset, "/container/collision_debug")
		-- end
	end

	for k, v in pairs(data.room_props) do
		pprint(v)
	end
end

return room
