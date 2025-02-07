#version 140
in mediump vec2        var_texcoord0;

out vec4               color_out;
float                  repeat_amount = 8;

float                  repeat_x = 1; // Number of repeats along the X-axis
float                  repeat_y = 1; // Number of repeats along the Y-axis

uniform lowp sampler2D tex0;

void                   main()
{
    //  vec2 repeat_texcoord = var_texcoord0 * repeat_amount;
    // vec2 wrapped_texcoord = fract(repeat_texcoord);

    vec2 repeat_texcoord = vec2(var_texcoord0.x * repeat_x, var_texcoord0.y * repeat_y);
    vec2 wrapped_texcoord = fract(repeat_texcoord);

    vec4 color = texture(tex0, wrapped_texcoord);

    // color_out = texture(tex0, var_texcoord0.xy);

    color_out = vec4(color.rgb * 1.0, 1.0);
}
