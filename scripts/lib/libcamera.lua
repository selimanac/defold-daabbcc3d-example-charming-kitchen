local const = require("scripts.lib.const")
local data = require("scripts.lib.data")

local libcamera = {}

libcamera.CONTAINER_ID = ""
libcamera.ID = ""
libcamera.DISPLAY_WIDTH = sys.get_config_int("display.width")
libcamera.DISPLAY_HEIGHT = sys.get_config_int("display.height")
libcamera.view = vmath.matrix4()
libcamera.projection = vmath.matrix4()
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
	angle_min = 0,
	angle_max = 0,
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
		libcamera.settings.angle_min = math.rad(camera_settings.angle_min)
		libcamera.settings.angle_max = math.rad(camera_settings.angle_max)
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

	if action_id == const.TRIGGERS.KEY_SPACE and action.pressed then
		libcamera.toogle_auto_turn()
	end

	if touch_down and action_id == nil then
		libcamera.settings.angle_x = libcamera.settings.angle_x + action.dy * 0.01
		libcamera.settings.angle_y = libcamera.settings.angle_y - action.dx * 0.01

		libcamera.settings.angle_x = math.min(libcamera.settings.angle_x, libcamera.settings.angle_max)
		libcamera.settings.angle_x = math.max(libcamera.settings.angle_x, libcamera.settings.angle_min)

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

local function unproject(v, inv_view, inv_proj)
	local p = inv_view * (inv_proj * v)
	return p / p.w
end


function libcamera.get_mouse_ray(mouse_pos_x, mouse_pos_y, result_ray)
	--	libcamera.view      = camera.get_view(libcamera.ID)
	local ndc_x         = (mouse_pos_x / libcamera.DISPLAY_WIDTH) * 2 - 1
	local ndc_y         = (mouse_pos_y / libcamera.DISPLAY_HEIGHT) * 2 - 1

	local inv_view      = vmath.inv(libcamera.view)
	local inv_proj      = vmath.inv(libcamera.projection)
	local near_point    = unproject(vmath.vector4(ndc_x, ndc_y, -1, 1), inv_view, inv_proj)
	local far_point     = unproject(vmath.vector4(ndc_x, ndc_y, 1, 1), inv_view, inv_proj)
	local origin        = vmath.vector3(near_point.x, near_point.y, near_point.z)

	result_ray.origin.x = near_point.x
	result_ray.origin.y = near_point.y
	result_ray.origin.z = near_point.z


	result_ray.dir = vmath.normalize(vmath.vector3(far_point.x, far_point.y, far_point.z) - origin)
end

-- Computes the intersection of a ray with a plane.
-- plane_point: a point on the plane
-- plane_normal: the plane's normal (should be normalized)

function libcamera.get_camera_forward()
	local inv_view = vmath.inv(libcamera.view)
	return vmath.normalize(vmath.vector3(-inv_view.m02, -inv_view.m12, -inv_view.m22)) -- Extract forward direction
end

-- Computes the intersection of a ray with a plane.
-- plane_point: a point on the plane
-- plane_normal: the plane's normal (should be normalized)
-- local plane_point = vmath.vector3(0, 0, 0)
-- local plane_normal = vmath.vector3(0, 0, 1)  -- Adjust this if your ground is oriented differently

-- local world_pos = ray_plane_intersect(ray_origin, ray_dir, plane_point, plane_normal)

function libcamera.ray_plane_intersect_normal(ray_origin, ray_dir, plane_point, plane_normal)
	local denom = vmath.dot(ray_dir, plane_normal)
	if math.abs(denom) < 1e-6 then
		-- The ray is parallel to the plane; no valid intersection.
		return nil
	end
	local t = vmath.dot(plane_point - ray_origin, plane_normal) / denom
	if t < 0 then
		-- The intersection point is behind the ray's origin.
		return nil
	end
	return ray_origin + t * ray_dir
end

function libcamera.ray_plane_intersect(ray_origin, ray_dir, plane_point)
	local plane_normal = libcamera.get_camera_forward() -- Plane always faces camera
	local denom = vmath.dot(ray_dir, plane_normal)

	if math.abs(denom) < 1e-6 then
		return nil -- Ray is parallel to the plane
	end

	local t = vmath.dot(plane_point - ray_origin, plane_normal) / denom
	if t < 0 then
		return nil -- Intersection is behind the ray origin
	end

	return ray_origin + t * ray_dir
end

return libcamera
