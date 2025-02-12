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
local active_prop       = {}
local rotated_prop_size = vmath.vector3()
local prop_offset       = vmath.vector3()
local prop_rotation     = 0
local is_prop_placed    = false
local is_prop_rotated   = false
local is_pick_probe     = false

local function rotate_prop(rotation)
	rotated_prop_size = vmath.rotate(rotation, active_prop.size)
	rotated_prop_size.x = math.abs(rotated_prop_size.x)
	rotated_prop_size.y = math.abs(rotated_prop_size.y)
	rotated_prop_size.z = math.abs(rotated_prop_size.z)

	prop_offset = vmath.rotate(rotation, active_prop.offset)

	go.set_rotation(rotation, active_prop.id)
end

function cursor.update(dt)
	if next(active_prop) == nil then
		return
	end


	ray_end_position = libcamera.position + data.cursor.dir * RAY_DISTANCE
	local prop_collision_bit = active_prop.collider and collision.bits[active_prop.collider] or nil

	--Camera to world ray
	raycast_result, raycast_count = collision.raycast_sort(libcamera.position, ray_end_position, prop_collision_bit, true)

	if raycast_result then
		is_prop_placed = true
		local ray_collision_response = raycast_result[1]


		--[[if ray_collision_response.normal.y == 0 and prop_collision_bit == nil then
			local normal_rotation = utils.get_rotation_from_normal((ray_collision_response.normal.x), (ray_collision_response.normal.y), (ray_collision_response.normal.z))

			rotate_prop(normal_rotation)
		end


		if prop_collision_bit == collision.bits.WALLS then
			local normal_rotation = utils.get_rotation_from_normal((ray_collision_response.normal.x), (ray_collision_response.normal.y), (ray_collision_response.normal.z))

			rotate_prop(normal_rotation)
		end]]

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
				go.set_scale(rotated_prop_size, "/container/collision_debug")
			end

			go.set_position(collider_position_offset, "/container/collision_debug")
		end


		-- Query rotated AABB of Cursor
		prop_query_result, prop_query_count = collision.query_aabb_sort(collider_position_offset, rotated_prop_size.x, rotated_prop_size.y, rotated_prop_size.z, nil, true)

		if prop_query_result then
			for i = 1, prop_query_count do
				local query_collision_response = prop_query_result[i]

				local query_collider_position_offset = vmath.vector3(
					(query_collision_response.normal.x) * query_collision_response.depth,
					(query_collision_response.normal.y) * query_collision_response.depth,
					(query_collision_response.normal.z) * query_collision_response.depth
				)
				if query_collision_response.normal.x < 0 or query_collision_response.normal.z < 0 then
					print("WRONG")
					is_prop_placed = false
				end



				data.cursor.position = data.cursor.position + query_collider_position_offset
			end
		end
	else
		is_prop_placed = false
	end

	pprint(is_prop_placed)

	go.set_position(data.cursor.position, const.CURSOR)
end

local function set_prop()
	data.cursor.is_active = false
	local prop = props.set(active_prop, prop_offset, rotated_prop_size)
	print("ADDED")
	pprint(prop)
	-- -- debug collider
	if data.game_settings.collider_debug then
		go.set_scale(rotated_prop_size, "/container/collision_debug")
		go.set_position(active_prop.collider_position_offset, "/container/collision_debug")
	end

	active_prop = {}
end

local function add_prop(name)
	if next(active_prop) ~= nil then
		data.cursor.is_active = false
		go.delete(active_prop.id)
	end
	data.cursor.is_active = true
	active_prop = props.create(name)
	go.set_parent(active_prop.id, const.CURSOR, false)
	rotated_prop_size = active_prop.size
	prop_offset = active_prop.offset
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

	if action.pressed and action_id == const.TRIGGERS.MOUSE_BUTTON_1 then
		-- TODO Check for correct placement
		if data.cursor.is_active and is_prop_placed then
			set_prop()
		end

		if data.cursor.is_active == false and is_pick_probe == false then
			print("data.cursor.is_active", data.cursor.is_active)
			print("is_pick_probe", is_pick_probe)
			is_pick_probe = true
		end
	end


	if action_id == const.TRIGGERS.MOUSE_WHEEL_DOWN and action.pressed and data.cursor.is_active and data.gui_scroll == false and is_prop_rotated == false then
		input_rotate(1)
	elseif action_id == const.TRIGGERS.MOUSE_WHEEL_UP and action.pressed and data.cursor.is_active and data.gui_scroll == false and is_prop_rotated == false then
		input_rotate(-1)
	end
end

return cursor
