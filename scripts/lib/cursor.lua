local data = require("scripts.lib.data")
local libcamera = require("scripts.lib.libcamera")
local collision = require("scripts.lib.collision")
local const = require("scripts.lib.const")
local probs = require("scripts.lib.probs")
local utils = require("scripts.lib.utils")

local cursor = {}


local RAY_DISTANCE = 100
local ray_end_position = vmath.vector3()
local current_prob = {}

function cursor.update(dt)
	if next(current_prob) == nil then
		return
	end
	ray_end_position = libcamera.position + data.cursor.dir * RAY_DISTANCE


	local result, count = collision.raycast_sort(libcamera.position, ray_end_position, nil, true)
	if result then
		--pprint(result)
		local collision_response = result[1]
		pprint(collision_response)
		local position_offset = vmath.vector3()
		data.cursor.position.x = collision_response.contact_point.x
		data.cursor.position.y = collision_response.contact_point.y
		data.cursor.position.z = collision_response.contact_point.z
		--	data.cursor.position = collision_response.contact_point

		local rot_ss = current_prob.size
		--	if collision_response.normal.x > 0 or collision_response.normal.z > 0 then
		local rot = utils.get_rotation_from_normal(math.abs(collision_response.normal.x), math.abs(collision_response.normal.y), math.abs(collision_response.normal.z))
		rot_ss = vmath.rotate(rot, current_prob.size)

		rot_ss.x = math.abs(rot_ss.x)
		rot_ss.y = math.abs(rot_ss.y)
		rot_ss.z = math.abs(rot_ss.z)

		if collision_response.normal.x > 0 or collision_response.normal.z > 0 then
			go.set_rotation(rot, const.CURSOR)
		end

		local offset = vmath.vector3(data.cursor.position.x + current_prob.offset.x, data.cursor.position.y + current_prob.offset.y, data.cursor.position.z + current_prob.offset.z)
		--offset = vmath.vector3(data.cursor.position.x, data.cursor.position.y, data.cursor.position.z)
		local result2, count2 = collision.query_aabb_sort(offset, rot_ss.x, rot_ss.y, rot_ss.z, nil, true)

		if result2 then
			--	pprint(result2)
			for i = 1, count2 do
				local collision_response2 = result2[i]


				--	if collision_response2.normal.x >= 0 and collision_response2.normal.y >= 0 and collision_response2.normal.z >= 0 then
				local vpos_off = vmath.vector3()
				vpos_off.x = (collision_response2.normal.x) * collision_response2.depth
				vpos_off.y = (collision_response2.normal.y) * collision_response2.depth
				vpos_off.z = (collision_response2.normal.z) * collision_response2.depth
				data.cursor.position = data.cursor.position + vpos_off
				--	end
			end
		end
	end

	go.set_position(data.cursor.position, const.CURSOR)
end

function cursor.message(message_id, message, sender)
	if message_id == const.MSG.PICK_PROBE then
		--	pprint(message)
		current_prob = probs.create(message.name)
	end
end

function cursor.input(action_id, action)
	libcamera.get_mouse_ray(action.x, action.y, data.cursor)
	--pprint(data.cursor)
	local plane_point = vmath.vector3(0, 6, 6)
	data.cursor.position = libcamera.ray_plane_intersect(data.cursor.origin, data.cursor.dir, plane_point)
end

return cursor
