shader_type canvas_item;
uniform float sector : hint_range(0.0, 1.0) = 0.5;
uniform float bg_color_down : hint_range(0.0, 1.0) = 0.2;
float greater_than(float x, float y) {return max(sign(x - y), 0.0);}
void fragment() {
	vec2 uv = UV*2.0-1.0;
	float a = (atan(uv.y, uv.x) + PI) / TAU;
	vec3 bg_clr=COLOR.rgb-vec3(bg_color_down);
	COLOR.rgb = mix(COLOR.rgb, bg_clr, COLOR.a * (greater_than(a, sector)));
}