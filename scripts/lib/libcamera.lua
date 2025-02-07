local libcamera = {}

libcamera.ID = "test:/camera#camera"
libcamera.DISPLAY_WIDTH = sys.get_config_int("display.width")
libcamera.DISPLAY_HEIGHT = sys.get_config_int("display.height")
libcamera.view = vmath.matrix4()
libcamera.projection = vmath.matrix4()
libcamera.position = vmath.vector3()
libcamera.rotation = vmath.quat()
libcamera.frustum = vmath.quat()

function libcamera.init()
	--	libcamera.update()
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

local function ray_plane_intersect_normal(ray_origin, ray_dir, plane_point, plane_normal)
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
	--	libcamera.view = camera.get_view(libcamera.ID)
	--libcamera.projection = camera.get_projection(libcamera.ID)


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
