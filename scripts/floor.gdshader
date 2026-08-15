shader_type spatial;
render_mode cull_back;

uniform vec4 base_color : source_color = vec4(0.8, 0.8, 0.8, 1.0);
uniform int band_count : hint_range(2, 5) = 3;
uniform vec3 light_dir = vec3(0.3, -0.7, 0.4);

void fragment() {
	vec3 n = normalize(NORMAL);
	float ndotl = clamp(dot(n, normalize(-light_dir)), 0.0, 1.0);
	float banded = floor(ndotl * float(band_count)) / float(band_count);
	banded = clamp(banded + 0.4, 0.0, 1.0);
	ALBEDO = base_color.rgb * banded;
}