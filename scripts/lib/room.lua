local const = require("scripts.lib.const")
local data = require("scripts.lib.data")
local collision = require("scripts.lib.collision")

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
			}
		}
	}
}



function room.init(room_number)
	room_number = room_number and room_number or 1

	local room_ids = collectionfactory.create(const.FACTORIES.ROOMS[1])

	for id, collider in pairs(ROOM_COLLIDERS["ROOM_" .. room_number].COLLIDERS) do
		local position = go.get_world_position(room_ids[id])
		local size = go.get_scale(room_ids[id])
		local aabb_id = collision.insert_aabb(position, size.x, size.y, size.z, collider.type)
		data.room_colliders[aabb_id] = { id = room_ids[id], position = position, size = size, aabb_id = aabb_id, type = collider.type }
	end
end

return room
