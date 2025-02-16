local data                   = require("scripts.lib.data")
local libcamera              = require("scripts.lib.libcamera")
local collision              = require("scripts.lib.collision")
local const                  = require("scripts.lib.const")
local props                  = require("scripts.lib.props")
local trash                  = require("scripts.lib.trash")

local cursor                 = {}

-- Ray
local RAY_DISTANCE           = 100
local ray_end_position       = vmath.vector3()
local raycast_result         = {}
local raycast_count          = 0
local ray_collision_response = {}

-- Props
local prop_query_result      = {}
local prop_query_count       = 0
local active_prop            = {}
local picked_prop            = {}
local rotated_prop_size      = vmath.vector3()
local prop_offset            = vmath.vector3()
local prop_rotation          = 0
local is_prop_placed         = false
local is_prop_rotated        = false
local is_pick_prop           = false

local collider_position      = vmath.vector3()

local function set_prop()
	data.cursor.is_active = false
	picked_prop = {}
	is_pick_prop = false

	props.set(active_prop, prop_offset, rotated_prop_size)

	active_prop = {}
end

local function remove_prop()
	if next(active_prop) ~= nil then
		data.cursor.is_active = false
		go.delete(active_prop.id)
	end
end

local function create_prop(name)
	remove_prop()

	data.cursor.is_active = true

	active_prop = props.create(name)

	rotated_prop_size = active_prop.size
	prop_offset = active_prop.offset

	go.set_parent(active_prop.id, const.CURSOR, false)
end


local function pick_prop(prop)
	remove_prop()

	props.pick(prop)

	data.cursor.is_active = true
	active_prop = prop

	go.set_position(vmath.vector3(), active_prop.id)
	go.set_parent(active_prop.id, const.CURSOR, false)

	rotated_prop_size = active_prop.size
	prop_offset = active_prop.offset
end

function cursor.update(dt)
	--Camera to world ray
	ray_end_position = libcamera.position + data.cursor.dir * RAY_DISTANCE
	raycast_result, raycast_count = collision.raycast_sort(libcamera.position, ray_end_position, active_prop.ray_collision_bit, true)

	if raycast_count > 0 then
		ray_collision_response = raycast_result[1]
	end

	if next(active_prop) == nil then
		-- Pickup the prop from room
		is_pick_prop = false
		picked_prop = {}

		if raycast_count > 0 and data.gui_scroll == false then
			local room_prop = data.room_props[ray_collision_response.id]
			if room_prop then
				is_pick_prop = true
				picked_prop = room_prop
			end
		end
		return
	end

	collider_position.x = data.cursor.position.x
	collider_position.y = data.cursor.position.y
	collider_position.z = data.cursor.position.z

	if raycast_count > 0 then
		-- Check for trash
		if trash.check(ray_collision_response, active_prop) then
			is_prop_placed = false
			go.set_position(data.cursor.position, const.CURSOR)
			return
		end

		data.cursor.position.x = ray_collision_response.contact_point.x + (rotated_prop_size.x / 2.0)

		-- Snap to the ground
		if active_prop.target == "GROUND" then
			data.cursor.position.y = 0
		else
			data.cursor.position.y = ray_collision_response.contact_point.y
		end

		data.cursor.position.z = ray_collision_response.contact_point.z + (rotated_prop_size.z / 2.0)

		collider_position.x = data.cursor.position.x + prop_offset.x
		collider_position.y = data.cursor.position.y + prop_offset.y
		collider_position.z = data.cursor.position.z + prop_offset.z

		prop_query_result, prop_query_count = collision.query_aabb_sort(collider_position, rotated_prop_size.x, rotated_prop_size.y, rotated_prop_size.z, active_prop.collision_bit, true)

		if prop_query_result then
			for i = 1, prop_query_count do
				is_prop_placed = true

				local query_collision_response = prop_query_result[i]
				local query_collider_position_offset = vmath.vector3()
				local room_prop = data.room_props[query_collision_response.id]
				local room_collider = data.room_colliders[query_collision_response.id]

				query_collider_position_offset.x = query_collision_response.normal.x * query_collision_response.depth
				query_collider_position_offset.y = query_collision_response.normal.y * query_collision_response.depth
				query_collider_position_offset.z = query_collision_response.normal.z * query_collision_response.depth

				-- I don’t remember why I protect z. Let’s keep it for a while. :)
				--	if active_prop.target ~= "WALLS" then
				-- query_collider_position_offset.z = query_collision_response.normal.z * query_collision_response.depth
				--	end

				data.cursor.position = data.cursor.position + query_collider_position_offset

				if active_prop.target == "PROP" and query_collision_response.normal ~= const.VECTOR.UP then -- prop targets only from top
					is_prop_placed = false
				elseif room_collider and room_collider.direction ~= query_collision_response.normal then -- wall - grounds only from facing normal
					is_prop_placed = false
				elseif room_prop and room_prop.name == "extractor_hood" then                    -- don't place anything to extractor. Find a better way if you got time :)
					is_prop_placed = false
				end
			end
		end
	else
		is_prop_placed = false
		if trash.is_trash_prop then
			trash.reset(active_prop)
		end
	end

	go.set_position(data.cursor.position, const.CURSOR)
end

function cursor.message(message_id, message, sender)
	if message_id == const.MSG.ADD_PROP then
		create_prop(message.name)
	end
end

local function rotate_prop(dir)
	is_prop_rotated = true
	prop_rotation = (prop_rotation + 90 * dir) % 360
	rotated_prop_size, prop_offset = props.rotate(vmath.quat_rotation_y(math.rad(prop_rotation)), active_prop)

	timer.delay(0.5, false, function()
		is_prop_rotated = false
	end)
end

local function delete_prop()
	trash.delete()
	go.animate(active_prop.id, "scale", go.PLAYBACK_ONCE_FORWARD, vmath.vector3(0.2, 0.2, 0.2), go.EASING_INSINE, 0.2, 0, function()
		trash.reset(active_prop)
		remove_prop()
		active_prop = {}
	end)
end

function cursor.input(action_id, action)
	libcamera.get_mouse_ray(action.x, action.y, data.cursor)

	data.cursor.position = libcamera.ray_plane_intersect(data.cursor.origin, data.cursor.dir, const.PLANE_POINT)

	-- Alternative
	--local plane_normal = vmath.vector3(0, 0, 1)
	--data.cursor.position = libcamera.ray_plane_intersect_normal(data.cursor.origin, data.cursor.dir, plane_point, plane_normal)

	if action.pressed and action_id == const.TRIGGERS.MOUSE_BUTTON_1 then
		if data.cursor.is_active and is_prop_placed then
			set_prop()
		elseif not data.cursor.is_active and is_pick_prop then
			pick_prop(picked_prop)
		elseif data.cursor.is_active and trash.is_trash_prop then
			delete_prop()
		end
	end

	-- Rotate prop
	if action_id == const.TRIGGERS.MOUSE_WHEEL_DOWN and action.pressed and data.cursor.is_active and data.gui_scroll == false and is_prop_rotated == false then
		rotate_prop(1)
	elseif action_id == const.TRIGGERS.MOUSE_WHEEL_UP and action.pressed and data.cursor.is_active and data.gui_scroll == false and is_prop_rotated == false then
		rotate_prop(-1)
	end
end

return cursor
