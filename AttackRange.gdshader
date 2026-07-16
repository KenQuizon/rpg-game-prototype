shader_type spatial;

render_mode unshaded, blend_mix, cull_disabled;

uniform vec4 outline_color : source_color = vec4(0.0, 1.0, 0.3, 1.0);
uniform vec4 fill_color : source_color = vec4(0.0, 1.0, 0.3, 0.35);

uniform float radius = 0.45;
uniform float outline_width = 0.02;

// NEW
uniform float fade_width : hint_range(0.01, 1.0) = 0.6;

void fragment()
{
    vec2 center = vec2(0.5);
    float d = distance(UV, center);

    if (d > radius)
        discard;

    //------------------------------------
    // Fill
    //------------------------------------

    float fade_start = radius * (1.0 - fade_width);

    float fill = smoothstep(fade_start, radius, d);

    //------------------------------------
    // Outline
    //------------------------------------

    float outline = step(radius - outline_width, d);

    //------------------------------------
    // Combine
    //------------------------------------

    vec3 color = mix(fill_color.rgb, outline_color.rgb, outline);

    float alpha = max(
        fill * fill_color.a,
        outline * outline_color.a
    );

    ALBEDO = color;
    ALPHA = alpha;
}