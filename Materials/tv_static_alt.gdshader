shader_type spatial;

uniform lowp sampler2D TEXTURE: hint_screen_texture;
uniform lowp float amount = 40.0;

void fragment() {
	lowp vec2 uv = UV*0.05;
	lowp float a = fract(sin(dot(UV, vec2(12.9898, 78.233) * TIME / 8.0)) * 438.5453) * 1.9;
	lowp vec4 col = texture(TEXTURE, UV);
	col.a *= pow(a, amount);
	ALBEDO = vec3(a,a,a);
}