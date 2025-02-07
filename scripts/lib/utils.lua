local utils = {}
function utils.get_rotation_from_normal(normal_x, normal_y, normal_z)
	local length = math.sqrt(normal_x * normal_x + normal_y * normal_y + normal_z * normal_z)
	normal_x = normal_x / length
	normal_y = normal_y / length
	normal_z = normal_z / length

	-- If the normal is nearly vertical, handle separately
	if math.abs(normal_x) < 1e-6 and math.abs(normal_z) < 1e-6 then
		if normal_y > 0 then
			return vmath.quat()                   -- Identity quaternion, no rotation needed
		else
			return vmath.quat_rotation_x(math.pi) -- Flip 180° if normal is (0, -1, 0)
		end
	end

	local pitch = math.atan2(normal_y, math.sqrt(normal_x * normal_x + normal_z * normal_z))
	local yaw = math.atan2(normal_x, normal_z)
	local quat_y = vmath.quat_rotation_y(yaw)
	local quat_x = vmath.quat_rotation_x(pitch)
	return quat_y * quat_x
end

function utils.get_rotation_from_normal_quad(normal_x, normal_y, normal_z)
	local normal = vmath.normalize(vmath.vector3(normal_x, normal_y, normal_z))
	-- Rotate from the default up vector (0,1,0) to the desired normal
	return vmath.quat_from_to(vmath.vector3(0, 1, 0), normal)
end

return utils
