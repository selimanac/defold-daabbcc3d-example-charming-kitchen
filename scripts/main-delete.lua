go.property("wall", resource.texture("/assets/textures/blue.png"))
go.property("checker", resource.texture("/assets/textures/checker.png"))

local libcamera = require("scripts.lib.libcamera")
local utils     = require("scripts.lib.utils")
local manager   = require("scripts.lib.manager")


local group_id        = daabbcc3d.new_group(daabbcc3d.UPDATE_PARTIALREBUILD)
local camera_pos      = vmath.vector3()

local wall1_aabb_id   = 0
local wall2_aabb_id   = 0
local cursor_aabb_id  = 0
local ground_aabb_id  = 0
local ground1_aabb_id = 0
local prob1_aabb_id   = 0

local end_dir
local world_pos       = vmath.vector3()
local cursor_size     = vmath.vector3()
local position_offset = vmath.vector3()
function init(self)
	msg.post(".", "acquire_input_focus")

	profiler.enable_ui(true)
	profiler.set_ui_view_mode(profiler.VIEW_MODE_MINIMIZED)
	world_pos = go.get_position("/cursor")

	manager.init()
	libcamera.init()


	local scale = go.get_scale("/wall1")
	wall1_aabb_id = daabbcc3d.insert_aabb(group_id, go.get_world_position("/wall1"), scale.x, scale.y, scale.z)
	pprint(scale)
	print('wall1_aabb_id', wall1_aabb_id)

	scale = go.get_scale("/wall2")
	wall2_aabb_id = daabbcc3d.insert_aabb(group_id, go.get_world_position("/wall2"), scale.x, scale.y, scale.z)
	pprint(scale)
	print('wall2_aabb_id', wall2_aabb_id)

	scale = go.get_scale("/go2")
	prob1_aabb_id = daabbcc3d.insert_aabb(group_id, go.get_world_position("/go2"), scale.x, scale.y, scale.z)

	scale = go.get_scale("/ground")
	ground_aabb_id = daabbcc3d.insert_aabb(group_id, go.get_world_position("/ground"), scale.x, scale.y, scale.z)
	ground1_aabb_id = daabbcc3d.insert_aabb(group_id, go.get_world_position("/ground1"), scale.x, scale.y, scale.z)


	go.set("/wall1#model", "texture0", self.wall)
	--go.set("/wall2#model", "texture0", self.wall)
	go.set("/ground1#model", "texture0", self.checker)
	go.set("/ground#model", "texture0", self.checker)
	print('ground_aabb_id', ground_aabb_id, 'ground1_aabb_id', ground1_aabb_id)


	--	cursor_size = vmath.vector3(1) --go.get_scale("/go")
	--cursor_aabb_id = daabbcc3d.insert_gameobject(group_id, "/cursor", cursor_size.x, cursor_size.y, cursor_size.z)
	--	print('cursor_aabb_id', cursor_aabb_id)
end

local ss = vmath.vector3(1, 1.0, 1)

function update(self, dt)
	camera_pos       = go.get_position("/camera")
	local camera_rot = go.get_rotation("/camera")


	--daabbcc3d.update_aabb(group_id, cursor_aabb_id, world_pos, 1, 1, 1)

	local start_position = camera_pos -- This should be your camera's world position.
	local distance       = 100     -- For example, the far distance you want to cast to.
	local end_position   = start_position + end_dir * distance

	local result, count  = daabbcc3d.raycast_sort(group_id, start_position, end_position, nil, true)
	if result then
		--	pprint(result)
		local collision_response = result[1]

		local position_offset = vmath.vector3()
		position_offset.x = collision_response.contact_point.x
		position_offset.y = collision_response.contact_point.y
		position_offset.z = collision_response.contact_point.z
		world_pos = position_offset



		local rot = utils.get_rotation_from_normal(math.abs(collision_response.normal.x), math.abs(collision_response.normal.y), math.abs(collision_response.normal.z))

		local rot_ss = vmath.rotate(rot, ss)

		rot_ss.x = math.abs(rot_ss.x)
		rot_ss.y = math.abs(rot_ss.y)
		rot_ss.z = math.abs(rot_ss.z)

		go.set_rotation(rot, "/cursor")
		go.set_scale(rot_ss, "/go1")
		local offset = vmath.vector3(world_pos.x, world_pos.y, world_pos.z) -- SET MODEL OFFSET HERE vmath.vector3(world_pos.x + offset.x, world_pos.y+ offset.y, world_pos.z+ offset.z)
		go.set_position(offset, "/go1")
		local result2, count2 = daabbcc3d.query_aabb_sort(group_id, offset, rot_ss.x, rot_ss.y, rot_ss.z, nil, true)

		if result2 then
			pprint(result2)
			for i = 1, count2 do
				local collision_response2 = result2[i]


				-- vpos_off.x = math.abs(collision_response2.normal.x) * collision_response2.depth
				-- vpos_off.y = math.abs(collision_response2.normal.y) * collision_response2.depth
				-- vpos_off.z = math.abs(collision_response2.normal.z) * collision_response2.depth

				if collision_response2.normal.x >= 0 and collision_response2.normal.y >= 0 and collision_response2.normal.z >= 0 then
					local vpos_off = vmath.vector3()
					vpos_off.x = (collision_response2.normal.x) * collision_response2.depth
					vpos_off.y = (collision_response2.normal.y) * collision_response2.depth
					vpos_off.z = (collision_response2.normal.z) * collision_response2.depth
					world_pos = world_pos + vpos_off
				end
			end
		end



		--	print(collision_response.id)
		--	local rot = utils.get_rotation_from_normal(-collision_response.normal.x, collision_response.normal.y, collision_response.normal.z)
		--	go.set_rotation(rot, "/cursor")


		--[[
		for i = 1, count do
			local collision_response = result[i]

			if collision_response.id ~= cursor_aabb_id then
				print(i, collision_response.id)
				position_offset.x = collision_response.contact_point.x + (collision_response.normal.x * 0.01)
				position_offset.y = collision_response.contact_point.y + (collision_response.normal.y * 0.01)
				position_offset.z = collision_response.contact_point.z + (collision_response.normal.z * 0.01)
				world_pos = position_offset
				--pprint(collision_response.normal)
				local rot = utils.get_rotation_from_normal(-collision_response.normal.x, collision_response.normal.y, collision_response.normal.z)
				go.set_rotation(rot, "/cursor")
			end
		end]]
	end


	--[[
	local result, count = daabbcc3d.query_id(group_id, cursor_aabb_id, nil, true)

	if result then
		for i = 1, count do
			pprint(result[i])
			local collision_response = result[i]
			position_offset.x = collision_response.normal.x * collision_response.depth
			position_offset.y = collision_response.normal.y * collision_response.depth
			position_offset.z = collision_response.normal.z * collision_response.depth
			world_pos = world_pos + position_offset

			local rot = utils.get_rotation_from_normal(collision_response.normal.x, collision_response.normal.y, collision_response.normal.z)
			go.set_rotation(rot, "/cursor")
		end
	end
]]




	go.set_position(world_pos, "/cursor")
end

function on_input(self, action_id, action)
	manager.input(action_id, action)
	local camera_id = msg.url("/camera#camera") -- Replace with your camera component

	local ray_origin, ray_dir = libcamera.get_mouse_ray(action.x, action.y)
	end_dir = ray_dir

	-- Define your target plane. In this example, we use the X-Y plane at Z = 0.
	local plane_point = vmath.vector3(0, 0, 0)


	--	world_pos = libcamera.ray_plane_intersect(ray_origin, ray_dir, plane_point)
end
