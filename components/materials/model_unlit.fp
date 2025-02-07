#version 140
in mediump vec2        var_texcoord0;

out vec4               color_out;

uniform lowp sampler2D tex0;

void                   main()
{
    vec4 color = texture(tex0, var_texcoord0.xy);

    color_out = vec4(color.rgb * 1.0, 1.0);
}
