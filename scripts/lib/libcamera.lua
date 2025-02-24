local const = require("scripts.lib.const")
local data = require("scripts.lib.data")

local libcamera = {}

libcamera.CONTAINER_ID = ""
libcamera.ID = ""
libcamera.DISPLAY_WIDTH = sys.get_config_int("display.width")
libcamera.DISPLAY_HEIGHT = sys.get_config_int("display.height")
libcamera.view = vmath.matrix4()
libcamera.projection = vmath.matrix4()
libcamera.inv_view = vmath.matrix4()
libcamera.inv_proj = vmath.matrix4()
libcamera.position = vmath.vector3()
libcamera.rotation = vmath.quat()
libcamera.frustum = vmath.quat()

libcamera.settings = {
	target = "",
	distance = 0,
	distance_min = 0,
	distance_max = 0,
	zoom_speed = 1,
	angle_x = 0,
	angle_y = 0,
	angle_x_min = 0,
	angle_x_max = 0,
	angle_y_min = 0,
	angle_y_max = 0,
	auto_turn = false,
	auto_turn_speed = 5
}

local touch_down = false
local camera_center = vmath.vector3()

local function set_camera()
	camera_center = libcamera.settings.target ~= hash("") and go.get_world_position(libcamera.settings.target) or vmath.vector3(0)

	libcamera.rotation = vmath.quat_rotation_y(libcamera.settings.angle_y) * vmath.quat_rotation_x(libcamera.settings.angle_x)
	libcamera.position = vmath.rotate(libcamera.rotation, vmath.vector3(0, 0, libcamera.settings.distance)) + camera_center

	go.set_rotation(libcamera.rotation, libcamera.CONTAINER_ID)
	go.set_position(libcamera.position, libcamera.CONTAINER_ID)
end

function libcamera.init(camera_settings)
	libcamera.CONTAINER_ID = msg.url("/camera")
	libcamera.ID = msg.url("/camera")
	libcamera.ID.fragment = "camera"

	if camera_settings then
		libcamera.settings = camera_settings

		libcamera.settings.angle_x = math.rad(camera_settings.angle_x)
		libcamera.settings.angle_y = math.rad(camera_settings.angle_y)
		libcamera.settings.angle_x_min = math.rad(camera_settings.angle_x_min)
		libcamera.settings.angle_x_max = math.rad(camera_settings.angle_x_max)
		libcamera.settings.angle_y_min = math.rad(camera_settings.angle_y_min)
		libcamera.settings.angle_y_max = math.rad(camera_settings.angle_y_max)
	end
end

function libcamera.toogle_auto_turn()
	libcamera.settings.auto_turn = not libcamera.settings.auto_turn and true or false
end

function libcamera.update(dt)
	if libcamera.settings.target ~= hash("") and go.get_world_position(libcamera.settings.target) then
		set_camera()
	end

	if not touch_down and libcamera.settings.auto_turn then
		libcamera.settings.angle_y = libcamera.settings.angle_y - (libcamera.settings.auto_turn_speed * dt) * 0.1
		set_camera()
	end
end

function libcamera.input(action_id, action)
	if action_id == const.TRIGGERS.MOUSE_BUTTON_3 then
		touch_down = true
		if action.released then
			touch_down = false
		end
	end

	--[[if action_id == const.TRIGGERS.KEY_SPACE and action.pressed then
		libcamera.toogle_auto_turn()
	end]]

	if touch_down and action_id == nil then
		libcamera.settings.angle_x = libcamera.settings.angle_x + action.dy * 0.01
		libcamera.settings.angle_y = libcamera.settings.angle_y - action.dx * 0.01

		libcamera.settings.angle_x = math.min(libcamera.settings.angle_x, libcamera.settings.angle_x_max)
		libcamera.settings.angle_x = math.max(libcamera.settings.angle_x, libcamera.settings.angle_x_min)

		libcamera.settings.angle_y = math.min(libcamera.settings.angle_y, libcamera.settings.angle_y_max)
		libcamera.settings.angle_y = math.max(libcamera.settings.angle_y, libcamera.settings.angle_y_min)

		set_camera()
	end

	if data.cursor.is_active == false then
		if action_id == const.TRIGGERS.MOUSE_WHEEL_DOWN and data.gui_scroll == false then
			libcamera.settings.distance = libcamera.settings.distance + libcamera.settings.zoom_speed * 0.20
			libcamera.settings.distance = math.min(libcamera.settings.distance, libcamera.settings.distance_max)
			set_camera()
		elseif action_id == const.TRIGGERS.MOUSE_WHEEL_UP and data.gui_scroll == false then
			libcamera.settings.distance = libcamera.settings.distance - libcamera.settings.zoom_speed * 0.20
			libcamera.settings.distance = math.max(libcamera.settings.distance, libcamera.settings.distance_min)
			set_camera()
		end
	end
end

--------------------------
-- Screen to plane stuff
--------------------------

local function unproject(v)
	local p = libcamera.inv_view * (libcamera.inv_proj * v)
	return p / p.w
end

local function get_mouse_ray(action_x, action_y)
	local nx           = (action_x / libcamera.DISPLAY_WIDTH) * 2 - 1
	local ny           = (action_y / libcamera.DISPLAY_HEIGHT) * 2 - 1
	local near_point   = unproject(vmath.vector4(nx, ny, -1, 1))
	local far_point    = unproject(vmath.vector4(nx, ny, 1, 1))

	data.cursor.origin = vmath.vector3(near_point.x, near_point.y, near_point.z)
	data.cursor.dir    = vmath.normalize(vmath.vector3(far_point.x, far_point.y, far_point.z) - data.cursor.origin)
end

local function get_camera_forward()
	return vmath.normalize(vmath.vector3(-libcamera.inv_view.m02, -libcamera.inv_view.m12, -libcamera.inv_view.m22))
end

local function ray_plane_intersect(ray_origin, ray_dir)
	local plane_normal = get_camera_forward()
	local plane_point = libcamera.position + plane_normal * const.PLANE_DISTANCE
	local denom = vmath.dot(ray_dir, plane_normal)

	-- If ray is parallel to the plane
	if math.abs(denom) < 1e-6 then
		return nil
	end

	local t = vmath.dot(plane_point - ray_origin, plane_normal) / denom

	-- If intersection is behind the ray origin
	if t < 0 then
		return nil
	end

	return ray_origin + t * ray_dir
end

function libcamera.screen_to_plane(action_x, action_y)
	get_mouse_ray(action_x, action_y)
	return ray_plane_intersect(data.cursor.origin, data.cursor.dir)
end

return libcamera
