local data = require("scripts.lib.data")
local libcamera = require("scripts.lib.libcamera")
local collision = require("scripts.lib.collision")
local const = require("scripts.lib.const")
local props = require("scripts.lib.props")
local utils = require("scripts.lib.utils")

local cursor = {}


local RAY_DISTANCE      = 100
local ray_end_position  = vmath.vector3()
local raycast_result    = {}
local raycast_count     = 0

local plane_point       = vmath.vector3(0, 6, 6)

local prop_query_result = {}
local prop_query_count  = 0
local current_prop      = {}
local rotated_prop_size = vmath.vector3()
local prop_offset       = vmath.vector3()
local prop_rotation     = 0
local is_prop_placed    = false
local is_prop_rotated   = false
local is_correct_target = false
local prop_target_count = 0

local function rotate_prop(rotation)
	rotated_prop_size = vmath.rotate(rotation, current_prop.size)
	rotated_prop_size.x = math.abs(rotated_prop_size.x)
	rotated_prop_size.y = math.abs(rotated_prop_size.y)
	rotated_prop_size.z = math.abs(rotated_prop_size.z)

	prop_offset = vmath.rotate(rotation, current_prop.offset)

	go.set_rotation(rotation, const.CURSOR)
end

function cursor.update(dt)
	if next(current_prop) == nil then
		return
	end
	ray_end_position = libcamera.position + data.cursor.dir * RAY_DISTANCE

	local prop_collision_bit = current_prop.collider and collision.bits[current_prop.collider] or nil

	--Camera to world ray
	raycast_result, raycast_count = collision.raycast_sort(libcamera.position, ray_end_position, prop_collision_bit, true)

	if raycast_result then
		is_prop_placed = true
		local ray_collision_response = raycast_result[1]

		if ray_collision_response.normal.y == 0 then
			local normal_rotation = utils.get_rotation_from_normal((ray_collision_response.normal.x), (ray_collision_response.normal.y), (ray_collision_response.normal.z))

			rotate_prop(normal_rotation)
		end

		data.cursor.position.x = ray_collision_response.contact_point.x
		data.cursor.position.y = ray_collision_response.contact_point.y
		data.cursor.position.z = ray_collision_response.contact_point.z

		local collider_position_offset = vmath.vector3(
			data.cursor.position.x + prop_offset.x,
			data.cursor.position.y + prop_offset.y,
			data.cursor.position.z + prop_offset.z)

		-- TODO Check for correct placement
		--[[	local prop_target_type = current_prop.target and collision.bits[current_prop.target] or nil
		--	pprint(query_collision_response)

		if data.room_colliders[ray_collision_response.id] then
			local room_collider = data.room_colliders[query_collision_response.id]

			if prop_target_type and prop_target_type == room_collider.type then
				--	print("FOUND")
				prop_target_count = prop_target_count + 1
				is_correct_target = true
			end
		end]]


		-- debug collider
		if data.game_settings.collider_debug then
			if vmath.length(rotated_prop_size) > 0 then
				go.set_scale(rotated_prop_size, "/collision_debug")
			end

			go.set_position(collider_position_offset, "/collision_debug")
		end


		-- Query rotated AABB of Cursor
		prop_query_result, prop_query_count = collision.query_aabb(collider_position_offset, rotated_prop_size.x, rotated_prop_size.y, rotated_prop_size.z, nil, true)

		if prop_query_result then
			prop_target_count = 0
			for i = 1, prop_query_count do
				local query_collision_response = prop_query_result[i]

				local collider_position_offset = vmath.vector3(
					(query_collision_response.normal.x) * query_collision_response.depth,
					(query_collision_response.normal.y) * query_collision_response.depth,
					(query_collision_response.normal.z) * query_collision_response.depth
				)
				if query_collision_response.normal.x < 0 or query_collision_response.normal.z < 0 then
					print("WRONG")
				end



				data.cursor.position = data.cursor.position + collider_position_offset
			end
		end
	else
		is_prop_placed = false
	end

	--[[	print(prop_target_count)
	if prop_target_count > 0 then
		is_correct_target = true
		print(is_correct_target)
	else
		is_correct_target = false
		print(is_correct_target)
	end]]
	--pprint(prop_target_count)


	go.set_position(data.cursor.position, const.CURSOR)
end

local function set_prop()
	data.cursor.is_active = false
	go.set_parent(current_prop.id, const.URLS.ROOM_CONTAINER, true)

	go.animate(current_prop.id, "scale", go.PLAYBACK_ONCE_PINGPONG, vmath.vector3(0.9, 1.3, 1), go.EASING_INSINE, 0.2)

	local pos = go.get_world_position(current_prop.id)

	local collider_position_offset = pos + prop_offset

	local prop_aabb_id = collision.insert_aabb(collider_position_offset, rotated_prop_size.x, rotated_prop_size.y, rotated_prop_size.z, collision.bits.PROPS)

	data.room_props[prop_aabb_id] = current_prop

	pprint(pos)
	-- debug collider
	if data.game_settings.collider_debug then
		go.set_scale(rotated_prop_size, "/collision_debug")
		go.set_position(collider_position_offset, "/collision_debug")
	end

	current_prop = {}
end

local function add_prop(name)
	if next(current_prop) ~= nil then
		data.cursor.is_active = false
		go.delete(current_prop.id)
	end
	data.cursor.is_active = true
	current_prop = props.create(name)
end

function cursor.message(message_id, message, sender)
	if message_id == const.MSG.PICK_PROP then
		add_prop(message.name)
	end
end

local function input_rotate(dir)
	is_prop_rotated = true
	prop_rotation = (prop_rotation + 90 * dir) % 360

	rotate_prop(vmath.quat_rotation_y(math.rad(prop_rotation)))

	timer.delay(0.5, false, function()
		is_prop_rotated = false
	end)
end

function cursor.input(action_id, action)
	libcamera.get_mouse_ray(action.x, action.y, data.cursor)

	data.cursor.position = libcamera.ray_plane_intersect(data.cursor.origin, data.cursor.dir, plane_point)

	--local plane_normal = vmath.vector3(0, 0, 1)
	--data.cursor.position = libcamera.ray_plane_intersect_normal(data.cursor.origin, data.cursor.dir, plane_point, plane_normal)

	if action.pressed and action_id == const.TRIGGERS.MOUSE_BUTTON_1 and data.cursor.is_active then
		-- TODO Check for correct placement
		if is_prop_placed then
			set_prop()
		end
	end


	if action_id == const.TRIGGERS.MOUSE_WHEEL_DOWN and action.pressed and data.cursor.is_active and data.gui_scroll == false and is_prop_rotated == false then
		input_rotate(1)
	elseif action_id == const.TRIGGERS.MOUSE_WHEEL_UP and action.pressed and data.cursor.is_active and data.gui_scroll == false and is_prop_rotated == false then
		input_rotate(-1)
	end
end

return cursor
