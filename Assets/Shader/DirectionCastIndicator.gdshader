shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_never;

uniform vec4 fill_color : source_color = vec4(0.3, 0.6, 1.0, 0.35);
uniform vec4 outline_color : source_color = vec4(0.3, 0.6, 1.0, 0.9);

uniform float outline_width : hint_range(0.0, 0.2) = 0.03;
uniform float shaft_half_width : hint_range(0.0, 0.5) = 0.06;
uniform float head_half_width : hint_range(0.0, 0.5) = 0.14;
uniform float head_length : hint_range(0.0, 1.0) = 0.2;

// Toggle this in the Inspector if the head renders at the wrong end —
// no code/script change needed, just flip the checkbox and look.
uniform bool flip_head = false;

void fragment() {

	float x = UV.x - 0.5;
	float y = flip_head ? UV.y : 1.0 - UV.y;

	float head_start = 1.0 - head_length;
	float half_width;

	if (y < head_start) {
		half_width = shaft_half_width;
	} else {
		float t = clamp((y - head_start) / max(head_length, 0.0001), 0.0, 1.0);
		half_width = mix(head_half_width, 0.0, t);
	}

	float dist = abs(x) - half_width;

	if (dist > 0.0 || y < 0.0 || y > 1.0) {
		discard;
	}

	float is_outline = step(-outline_width, dist);
	vec4 result = mix(fill_color, outline_color, is_outline);

	ALBEDO = result.rgb;
	ALPHA = result.a;
}