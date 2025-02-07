local libcamera = {}

libcamera.ID = "/camera#camera"
libcamera.DISPLAY_WIDTH = sys.get_config_int("display.width")
libcamera.DISPLAY_HEIGHT = sys.get_config_int("display.height")
libcamera.view = vmath.matrix4()
libcamera.projection = vmath.matrix4()

function libcamera.init()
	libcamera.view = camera.get_view(libcamera.ID)
	libcamera.projection = camera.get_projection(libcamera.ID)
end

local function unproject(v, inv_view, inv_proj)
	local p = inv_view * (inv_proj * v)
	return p / p.w
end


function libcamera.get_mouse_ray(mouse_pos_x, mouse_pos_y)
	libcamera.view   = camera.get_view(libcamera.ID)
	local ndc_x      = (mouse_pos_x / libcamera.DISPLAY_WIDTH) * 2 - 1
	local ndc_y      = (mouse_pos_y / libcamera.DISPLAY_HEIGHT) * 2 - 1

	local inv_view   = vmath.inv(libcamera.view)
	local inv_proj   = vmath.inv(libcamera.projection)
	local near_point = unproject(vmath.vector4(ndc_x, ndc_y, -1, 1), inv_view, inv_proj)
	local far_point  = unproject(vmath.vector4(ndc_x, ndc_y, 1, 1), inv_view, inv_proj)
	local origin     = vmath.vector3(near_point.x, near_point.y, near_point.z)
	local dir        = vmath.normalize(vmath.vector3(far_point.x, far_point.y, far_point.z) - origin)

	return origin, dir
end

-- Computes the intersection of a ray with a plane.
-- plane_point: a point on the plane
-- plane_normal: the plane's normal (should be normalized)

function libcamera.get_camera_forward()
	local inv_view = vmath.inv(libcamera.view)
	return vmath.normalize(vmath.vector3(-inv_view.m02, -inv_view.m12, -inv_view.m22)) -- Extract forward direction
end

function libcamera.ray_plane_intersect(ray_origin, ray_dir, plane_point)
	libcamera.view = camera.get_view(libcamera.ID)
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
