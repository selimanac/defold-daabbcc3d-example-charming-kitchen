local const = require("scripts.lib.const")
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


room.colliders = {}

function room.init(room_number)
	room_number = room_number and room_number or 1

	local room_ids = collectionfactory.create(const.FACTORIES.ROOMS[1])

	for k, v in pairs(ROOM_COLLIDERS["ROOM_" .. room_number].COLLIDERS) do
		local position = go.get_world_position(room_ids[k])
		local size = go.get_scale(room_ids[k])
		local aabb_id = collision.insert_aabb(position, size.x, size.y, size.z, v.type)
		room.colliders[aabb_id] = { id = room_ids[k], position = position, size = size, aabb_id = aabb_id }
	end
end

return room
