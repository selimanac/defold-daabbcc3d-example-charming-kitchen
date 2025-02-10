local data = require("scripts.lib.data")
local libcamera = require("scripts.lib.libcamera")
local collision = require("scripts.lib.collision")
local const = require("scripts.lib.const")
local props = require("scripts.lib.props")
local utils = require("scripts.lib.utils")

local cursor = {}


local RAY_DISTANCE = 100
local ray_end_position = vmath.vector3()
local raycast_result = {}
local raycast_count = 0

local prop_query_result = {}
local prop_query_count = 0


local current_prop = {}
local rotated_prop_size = vmath.vector3()
local prop_offset = vmath.vector3()
local is_current_prop = false
local is_prop_active = false

function cursor.update(dt)
	if next(current_prop) == nil then
		return
	end
	ray_end_position = libcamera.position + data.cursor.dir * RAY_DISTANCE

	--Camera to world ray
	raycast_result, raycast_count = collision.raycast_sort(libcamera.position, ray_end_position, nil, true)

	if raycast_result then
		is_prop_active = true
		local ray_collision_response = raycast_result[1]

		--	prop_offset = current_prop.offset
		--	rotated_prop_size = current_prop.size


		if ray_collision_response.normal.y == 0 then
			local normal_rotation = utils.get_rotation_from_normal((ray_collision_response.normal.x), (ray_collision_response.normal.y), (ray_collision_response.normal.z))

			rotated_prop_size = vmath.rotate(normal_rotation, current_prop.size)
			rotated_prop_size.x = math.abs(rotated_prop_size.x)
			rotated_prop_size.y = math.abs(rotated_prop_size.y)
			rotated_prop_size.z = math.abs(rotated_prop_size.z)

			prop_offset = vmath.rotate(normal_rotation, current_prop.offset)

			go.set_rotation(normal_rotation, const.CURSOR)
		end

		data.cursor.position.x = ray_collision_response.contact_point.x
		data.cursor.position.y = ray_collision_response.contact_point.y
		data.cursor.position.z = ray_collision_response.contact_point.z

		local collider_position_offset = vmath.vector3(
			data.cursor.position.x + prop_offset.x,
			data.cursor.position.y + prop_offset.y,
			data.cursor.position.z + prop_offset.z)

		-- TODO Check for correct placement
		-- debug collider
		if data.game_settings.collider_debug then
			if vmath.length(rotated_prop_size) > 0 then
				go.set_scale(rotated_prop_size, "/go")
			end

			go.set_position(collider_position_offset, "/go")
		end


		-- Query rotated AABB of Cursor
		prop_query_result, prop_query_count = collision.query_aabb(collider_position_offset, rotated_prop_size.x, rotated_prop_size.y, rotated_prop_size.z, nil, true)

		if prop_query_result then
			pprint(prop_query_count)
			for i = 1, prop_query_count do
				local query_collision_response = prop_query_result[i]

				local collider_position_offset = vmath.vector3(
					query_collision_response.normal.x * query_collision_response.depth,
					query_collision_response.normal.y * query_collision_response.depth,
					query_collision_response.normal.z * query_collision_response.depth
				)


				data.cursor.position = data.cursor.position + collider_position_offset
			end
		end
	else
		is_prop_active = false
	end


	go.set_position(data.cursor.position, const.CURSOR)
end

local function set_prop()
	is_current_prop = false
	go.set_parent(current_prop.id, "/room", true)

	local pos = go.get_world_position(current_prop.id)

	local collider_position_offset = pos + current_prop.offset

	local prop_aabb_id = collision.insert_aabb(collider_position_offset, current_prop.size.x, current_prop.size.y, current_prop.size.z, collision.bits.props)

	data.room_props[prop_aabb_id] = current_prop



	--	go.set_scale(current_prop.size, "/go")
	--	go.set_position(collider_position_offset, "/go")

	current_prop = {}
end

local function add_prop(name)
	if next(current_prop) ~= nil then
		is_current_prop = false
		go.delete(current_prop.id)
	end
	is_current_prop = true
	current_prop = props.create(name)
	pprint(current_prop.size)
	pprint(current_prop.offset)
end

function cursor.message(message_id, message, sender)
	if message_id == const.MSG.PICK_PROP then
		add_prop(message.name)
	end
end

function cursor.input(action_id, action)
	libcamera.get_mouse_ray(action.x, action.y, data.cursor)
	--pprint(data.cursor)
	local plane_point = vmath.vector3(0, 6, 6)
	local plane_normal = vmath.vector3(0, 0, 1)

	data.cursor.position = libcamera.ray_plane_intersect(data.cursor.origin, data.cursor.dir, plane_point)

	--data.cursor.position = libcamera.ray_plane_intersect_normal(data.cursor.origin, data.cursor.dir, plane_point, plane_normal)

	if action.pressed and action_id == const.TRIGGERS.MOUSE_BUTTON_1 and is_current_prop then
		-- TODO Check for correct placement
		if is_prop_active then
			set_prop()
		end
	end
	-- Cursor rotate
	if action_id == const.TRIGGERS.MOUSE_WHEEL_DOWN then

	elseif action_id == const.TRIGGERS.MOUSE_WHEEL_UP then

	end
end

return cursor
