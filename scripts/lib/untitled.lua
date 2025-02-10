local rot_ss

function cursor.update(dt)
	if next(current_prob) == nil then
		return
	end
	ray_end_position = libcamera.position + data.cursor.dir * RAY_DISTANCE


	local result, count = collision.raycast_sort(libcamera.position, ray_end_position, nil, true)
	if result then
		local collision_response = result[1]

		local position_offset = vmath.vector3()
		data.cursor.position.x = collision_response.contact_point.x
		data.cursor.position.y = collision_response.contact_point.y
		data.cursor.position.z = collision_response.contact_point.z
		--	data.cursor.position = collision_response.contact_point

		--local rot_ss = current_prob.size
		if collision_response.normal.y == 0 then
			
			local rot = utils.get_rotation_from_normal(math.abs(collision_response.normal.x), math.abs(collision_response.normal.y), math.abs(collision_response.normal.z))
			--pprint(current_prob.size)
			rot_ss = vmath.rotate(rot, current_prob.size)
			--	pprint(rot_ss)
			--if collision_response.normal.x > 0 or collision_response.normal.z > 0 then
			rot_ss.x = math.abs(rot_ss.x)
			rot_ss.y = math.abs(rot_ss.y)
			rot_ss.z = math.abs(rot_ss.z)
			go.set_rotation(rot, const.CURSOR)
			go.set_scale(rot_ss, "/go")
		end




		local offset = vmath.vector3(data.cursor.position.x + current_prob.offset.x, data.cursor.position.y + current_prob.offset.y, data.cursor.position.z + current_prob.offset.z)

		--	go.set_position(offset, "/go")
		--offset = vmath.vector3(data.cursor.position.x, data.cursor.position.y, data.cursor.position.z)
		local result2, count2 = collision.query_aabb_sort(offset, rot_ss.x, rot_ss.y, rot_ss.z, nil, true)



		if result2 then
			--	pprint(result2)
			for i = 1, count2 do
				local collision_response2 = result2[i]

				pprint(collision_response2.normal)
				if collision_response2.normal.x >= 0 and collision_response2.normal.y >= 0 and collision_response2.normal.z >= 0 then
					local vpos_off = vmath.vector3()
					vpos_off.x = (collision_response2.normal.x) * collision_response2.depth
					vpos_off.y = (collision_response2.normal.y) * collision_response2.depth
					vpos_off.z = (collision_response2.normal.z) * collision_response2.depth
					data.cursor.position = data.cursor.position + vpos_off
				end
			end
		end
	end

	go.set_position(data.cursor.position, const.CURSOR)
end