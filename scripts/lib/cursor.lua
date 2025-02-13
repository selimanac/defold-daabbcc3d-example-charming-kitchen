local data                   = require("scripts.lib.data")
local libcamera              = require("scripts.lib.libcamera")
local collision              = require("scripts.lib.collision")
local const                  = require("scripts.lib.const")
local props                  = require("scripts.lib.props")
local utils                  = require("scripts.lib.utils")
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


--[[local function rotate_prop(rotation)
	rotated_prop_size = vmath.rotate(rotation, active_prop.size)
	rotated_prop_size.x = math.abs(rotated_prop_size.x)
	rotated_prop_size.y = math.abs(rotated_prop_size.y)
	rotated_prop_size.z = math.abs(rotated_prop_size.z)

	prop_offset = vmath.rotate(rotation, active_prop.offset)

	go.set_rotation(rotation, active_prop.id)
end

]]


local function set_prop()
	picked_prop = {}
	is_pick_prop = false

	data.cursor.is_active = false
	local prop = props.set(active_prop, prop_offset, rotated_prop_size)
	-- -- debug collider
	if data.game_settings.collider_debug then
		go.set_scale(rotated_prop_size, "/container/collision_debug")
		go.set_position(active_prop.collider_position_offset, "/container/collision_debug")
	end

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
	ray_end_position = libcamera.position + data.cursor.dir * RAY_DISTANCE

	local prop_collision_bit = active_prop.collider and bit.bor(collision.bits[active_prop.collider], collision.bits.TRASH) or nil

	--Camera to world ray
	raycast_result, raycast_count = collision.raycast_sort(libcamera.position, ray_end_position, prop_collision_bit, true)

	if raycast_count > 0 then
		ray_collision_response = raycast_result[1]
		--	pprint(ray_collision_response.normal)
	end


	if next(active_prop) == nil then
		if raycast_count > 0 and data.gui_scroll == false then
			local room_prop = data.room_props[ray_collision_response.id]
			if room_prop then
				is_pick_prop = true
				picked_prop = room_prop
			else
				is_pick_prop = false
				picked_prop = {}
			end
		else
			is_pick_prop = false
			picked_prop = {}
		end
		return
	end



	if raycast_count > 0 then
		-- if ray_collision_response.normal.y == 0 then
		-- 	local normal_rotation = utils.get_rotation_from_normal((ray_collision_response.normal.x), (ray_collision_response.normal.y), (ray_collision_response.normal.z))
		-- 	rotate_prop(normal_rotation)
		-- end

		if trash.check(ray_collision_response, active_prop) then
			is_prop_placed = false
			go.set_position(data.cursor.position, const.CURSOR)
			return
		end

		pprint(ray_collision_response)
		local room_collider_direction = data.room_colliders[ray_collision_response.id].direction

		local collider_position = data.cursor.position
		if ray_collision_response.normal == room_collider_direction then
			print("HIT")

			is_prop_placed = true

			collider_position.x = ray_collision_response.contact_point.x
			collider_position.y = ray_collision_response.contact_point.y
			collider_position.z = ray_collision_response.contact_point.z
		else
			is_prop_placed = false
			print("nothing")
		end


		local collider_position_offset = vmath.vector3(
			collider_position.x + prop_offset.x,
			collider_position.y + prop_offset.y,
			collider_position.z + prop_offset.z
		)


		-- debug collider
		if data.game_settings.collider_debug then
			if vmath.length(rotated_prop_size) > 0 then
				go.set_scale(rotated_prop_size, "/container/collision_debug")
			end

			go.set_position(collider_position_offset, "/container/collision_debug")
		end


		-- Query rotated AABB of Cursor
		prop_query_result, prop_query_count = collision.query_aabb_sort(collider_position_offset, rotated_prop_size.x, rotated_prop_size.y, rotated_prop_size.z, prop_collision_bit, true)
		-- if prop_query_count > 0 then

		-- end
		if prop_query_result then
			for i = 1, prop_query_count do
				local query_collision_response = prop_query_result[i]



				-- local room_collider_direction = data.room_colliders[query_collision_response.id].direction

				-- pprint(query_collision_response)
				-- -- pprint("WALL NORMAL: ", room_collider_direction)
				-- -- pprint("RAY NORMAL:", ray_collision_response.normal)
				-- if (query_collision_response.normal) ~= const.VECTOR.RIGHT then
				-- 	print("WRONG SIDE")
				-- 	pprint(query_collision_response)
				-- end

				-- if query_collision_response.normal == room_collider_direction then
				-- 	print("HIT")
				-- else
				-- 	print("nothing")
				-- end
				local query_collider_position_offset = vmath.vector3()
				if is_prop_placed then
					query_collider_position_offset.x = query_collision_response.normal.x * query_collision_response.depth
					query_collider_position_offset.y = query_collision_response.normal.y * query_collision_response.depth
					query_collider_position_offset.z = query_collision_response.normal.z * query_collision_response.depth
				end


				-- This must be FIXED
				if query_collision_response.normal.y < 0 or query_collision_response.normal.x < 0 or query_collision_response.normal.z < 0 then
					-- TODO CHECK THIS
					print("WRONG")
					--	go.animate(active_prop.model_url, "tint", go.PLAYBACK_LOOP_PINGPONG, vmath.vector4(1.0, 0.5, 0.5, 1), go.EASING_INSINE, 1.0)
					--	is_prop_placed = false
				else
					--data.cursor.position = data.cursor.position + query_collider_position_offset
				end

				data.cursor.position = data.cursor.position + query_collider_position_offset
			end
		end
	else
		is_prop_placed = false
		--print("NOT HIT")
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

	--	rotate_prop()

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
		-- TODO Check for correct placement
		if data.cursor.is_active and is_prop_placed then
			set_prop()
		elseif not data.cursor.is_active and is_pick_prop then
			print("is_pick_prop", is_pick_prop)
			pick_prop(picked_prop)
		elseif data.cursor.is_active and trash.is_trash_prop then
			delete_prop()
		end
	end


	if action_id == const.TRIGGERS.MOUSE_WHEEL_DOWN and action.pressed and data.cursor.is_active and data.gui_scroll == false and is_prop_rotated == false then
		rotate_prop(1)
	elseif action_id == const.TRIGGERS.MOUSE_WHEEL_UP and action.pressed and data.cursor.is_active and data.gui_scroll == false and is_prop_rotated == false then
		rotate_prop(-1)
	end
end

return cursor
