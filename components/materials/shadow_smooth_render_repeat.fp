#version 140

in highp vec4     var_position;
in mediump vec3   var_normal;
in mediump vec2   var_texcoord0;
in mediump vec4   var_texcoord0_shadow;
in mediump vec4   var_light;

uniform sampler2D shadow_render_depth_texture;
uniform sampler2D shadow_render_diffuse_texture;
float             repeat_amount = 10;
uniform fs_uniforms
{
    mediump vec4 diffuse_light;
    mediump vec4 bias;
    mediump vec4 shadow_opacity;
};

out vec4 fragColor;

float    rgba_to_float(vec4 rgba)
{
    return dot(rgba, vec4(1.0, 1.0 / 255.0, 1.0 / 65025.0, 1.0 / 16581375.0));
}

vec2 rand(vec2 co)
{
    return vec2(fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453),
                fract(sin(dot(co.yx, vec2(12.9898, 78.233))) * 43758.5453)) *
    0.00047;
}

float shadow_calculation(vec4 depth_data)
{
    // The 'depth_bias' value is per-scene dependant and must be tweaked
    // accordingly. It is needed to avoid shadow acne, which is basically a
    // precision issue.
    float depth_bias = bias.x;
    float shadow = 0.0;
    float texel_size = 1 / 2048.0; // Texture size;
    for (int x = -1; x <= 1; ++x)
    {
        for (int y = -1; y <= 1; ++y)
        {
            vec2  uv = depth_data.st + vec2(x, y) * texel_size;
            vec4  rgba = texture(shadow_render_depth_texture, uv + rand(uv));
            float depth = rgba_to_float(rgba);
            shadow += depth_data.z - depth_bias > depth ? 1.0 : 0.0;
        }
    }
    shadow /= 9.0;

    highp vec2 uv = depth_data.xy;
    if (uv.x < 0.0)
        shadow = 0.0;
    if (uv.x > 1.0)
        shadow = 0.0;
    if (uv.y < 0.0)
        shadow = 0.0;
    if (uv.y > 1.0)
        shadow = 0.0;

    return shadow;
}
/*
float shadow_calculation(vec4 depth_data)
{
    float depth_bias = bias.x;
    // const float depth_bias = 0.00002; // for perspective camera

    float shadow = 0.0;

    ivec2 texture_size =
    ivec2(4096, 4096); // textureSize(shadow_render_depth_texture, 0);

    vec2 texel_size = 1.0 / vec2(float(texture_size.x), float(texture_size.y));
    for (int x = -1; x <= 1; ++x)
    {
        for (int y = -1; y <= 1; ++y)
        {
            float depth =
            rgba_to_float(texture(shadow_render_depth_texture,
                                  depth_data.st + vec2(x, y) * texel_size));
            shadow += depth_data.z - depth_bias > depth ? 0.8 : 0.0;
        }
    }
    shadow /= 9.0;

    return shadow;
}
 */
void main()
{
    vec2  repeat_texcoord = var_texcoord0 * repeat_amount;
    vec2  wrapped_texcoord = fract(repeat_texcoord);

    vec4  color = texture(shadow_render_diffuse_texture, wrapped_texcoord);

    vec4  depth_proj = var_texcoord0_shadow / var_texcoord0_shadow.w;
    float shadow = shadow_calculation(depth_proj.xyzw);

    // Diffuse light calculations
    vec3 ambient_light = diffuse_light.xyz;
    vec3 diff_light = vec3(normalize(var_light.xyz - var_position.xyz));
    diff_light = max(dot(var_normal, diff_light), 0.0) + ambient_light;
    diff_light = clamp(diff_light, 0.0, 1.0);

    vec3 shadow_color = shadow_opacity.xyz * shadow;

    fragColor = vec4(color.rgb * diff_light * (1.0 - shadow_color), 1.0);
}
