local render_helper            = {}

local VECTOR_UP                = vmath.vector3(0, 1, 0)
local light_source_position    = vmath.vector3()
local light_target_position    = vmath.vector3()
local BIAS_MATRIX              = vmath.matrix4()
BIAS_MATRIX.c0                 = vmath.vector4(0.5, 0.0, 0.0, 0.0)
BIAS_MATRIX.c1                 = vmath.vector4(0.0, 0.5, 0.0, 0.0)
BIAS_MATRIX.c2                 = vmath.vector4(0.0, 0.0, 0.5, 0.0)
BIAS_MATRIX.c3                 = vmath.vector4(0.5, 0.5, 0.5, 1.0)

---Shadow orthographic projection settings. Values are per-scene dependent and must be tweaked accordingly.
render_helper.shadow_settings  = {
	projection_width  = 12,
	projection_height = 12,
	projection_near   = -20,
	projection_far    = 20,
	depth_bias        = vmath.vector4(0.00002), -- Usually it is 0.00002 for perspective. 0.002 for ortho projection
	shadow_opacity    = vmath.vector4(0.3),  -- Shadow opacity
	buffer_size       = 2048
}

---Lights
render_helper.light_projection = vmath.matrix4()
render_helper.light_transform  = vmath.matrix4()
render_helper.mtx_light        = vmath.matrix4()
render_helper.light            = vmath.vector4()
render_helper.render_shadows   = true
render_helper.ambient_light    = vmath.vector4(0.6)

---Set light matrix
local function set_light_matrix()
	render_helper.mtx_light = BIAS_MATRIX * render_helper.light_projection * render_helper.light_transform
end

---Set light projection
local function set_light_projection()
	render_helper.light_projection = vmath.matrix4_orthographic(
		-render_helper.shadow_settings.projection_width / 2,
		render_helper.shadow_settings.projection_width / 2,
		-render_helper.shadow_settings.projection_height / 2,
		render_helper.shadow_settings.projection_height / 2,
		render_helper.shadow_settings.projection_near,
		render_helper.shadow_settings.projection_far
	)
end

---Set light transform
local function set_light_transform()
	render_helper.light_transform = vmath.matrix4_look_at(light_source_position, light_target_position, VECTOR_UP)
end

---Set shadow depth bias
---@param depth_bias number Depth Bias
function render_helper.set_depth_bias(depth_bias)
	render_helper.shadow_settings.depth_bias = vmath.vector4(depth_bias)
end

---Set shadow opacity
---@param shadow_opacity number Shadow opacity
function render_helper.set_shadow_opacity(shadow_opacity)
	render_helper.shadow_settings.shadow_opacity = vmath.vector4(shadow_opacity)
end

---Set Pixel-art models ambient light
---@param ambient_light vector3 Ambient light
function render_helper.set_ambient_light(ambient_light)
	render_helper.ambient_light.x = ambient_light.x
	render_helper.ambient_light.y = ambient_light.y
	render_helper.ambient_light.z = ambient_light.z
end

---Set Light source and target
---@param light_source string Light source gameobject URL
---@param light_target string Light target gameobject URL
function render_helper.set_light(light_source, light_target)
	light_source_position = go.get_position(light_source)
	light_target_position = go.get_position(light_target)


	render_helper.light.x = light_source_position.x
	render_helper.light.y = light_source_position.y
	render_helper.light.z = light_source_position.z
	render_helper.light.w = 1
end

-- Light orthographic projection settings for shadow. Values are per-scene dependant and must be tweaked accordingly.
---@class ShadowSettings
---@field projection_width number Shadow projection width
---@field projection_height number Shadow projection height
---@field projection_near number Shadow projection near plane
---@field projection_far number Shadow projection far plane
---@field depth_bias? number The 'depth_bias' value is per-scene dependant and must be tweaked ccordingly. It is needed to avoid shadow acne, which is basically a  precision issue.
---@field shadow_opacity? number  Shadow opacity

-- Light settings
---@class LightSettings
---@field source string Light source URL.
---@field target string Light target URL.
---@field diffuse_light_color? vector3 Diffuse light color.

-- Pixel-art post-process settings
---@class PixelartSettings
---@field pixel_size integer Pixel size
---@field normal_edge_coefficient number Normal edge for sharpening edges
---@field depth_edge_coefficient number Depth edge for outline

---Pixel-art post-process initial setup
---@param light_settings? LightSettings Light source and target URLs.
---@param shadow_settings? ShadowSettings Table of shadow post-process settings
function render_helper.init(light_settings, shadow_settings)
	if light_settings ~= nil then
		-- Light source positions
		if light_settings.source or light_settings.target then
			assert(light_settings.source, "You must provide 'light_settings.source'")
			assert(light_settings.target, "You must provide 'light_settings.target'")
			render_helper.set_light(light_settings.source, light_settings.target)
		end

		if light_settings.diffuse_light_color ~= nil then
			render_helper.set_ambient_light(light_settings.diffuse_light_color)
		end
	end

	if shadow_settings then
		render_helper.render_shadows = true
		assert(light_settings, "You must provide 'light_settings'")

		if render_helper.render_shadows then
			assert(shadow_settings, "You must provide 'shadow_settings'")
			assert(shadow_settings.projection_width, "You must provide 'shadow_settings.projection_width'")
			assert(shadow_settings.projection_height, "You must provide 'shadow_settings.projection_height'")
			assert(shadow_settings.projection_near, "You must provide 'shadow_settings.projection_near'")
			assert(shadow_settings.projection_far, "You must provide 'shadow_settings.projection_far'")

			render_helper.shadow_settings.projection_width = shadow_settings.projection_width
			render_helper.shadow_settings.projection_height = shadow_settings.projection_height
			render_helper.shadow_settings.projection_near = shadow_settings.projection_near
			render_helper.shadow_settings.projection_far = shadow_settings.projection_far
			render_helper.shadow_settings.buffer_size = shadow_settings.buffer_size

			if shadow_settings.depth_bias then
				render_helper.set_depth_bias(shadow_settings.depth_bias)
			end

			if shadow_settings.shadow_opacity then
				render_helper.set_shadow_opacity(shadow_settings.shadow_opacity)
			end

			-- Setup light
			set_light_transform()
			set_light_projection()
			set_light_matrix()
		end
	elseif shadow_settings == nil then
		render_helper.render_shadows = false
	end
end

return render_helper
