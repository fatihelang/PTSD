shader_type spatial;
render_mode cull_back;

uniform vec4 grass_light : source_color = vec4(0.55, 0.92, 0.35, 1.0);
uniform vec4 grass_mid : source_color = vec4(0.35, 0.80, 0.30, 1.0);
uniform vec4 grass_dark : source_color = vec4(0.18, 0.62, 0.28, 1.0);

uniform float noise_scale : hint_range(1.0, 40.0) = 16.0;
uniform float wind_speed : hint_range(0.0, 3.0) = 0.7;
uniform float wind_strength : hint_range(0.0, 1.0) = 0.5;
uniform float gust_frequency : hint_range(1.0, 20.0) = 4.0;
uniform float gust_sharpness : hint_range(1.0, 8.0) = 2.5;
uniform vec2 wind_direction = vec2(1.0, 0.35);

uniform int band_count : hint_range(2, 6) = 3;
uniform vec3 light_dir = vec3(0.3, -0.7, 0.4);
uniform float rim_boost : hint_range(0.0, 1.0) = 0.25;


float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
	float value = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 3; i++) {
		value += noise(p) * amp;
		p *= 2.0;
		amp *= 0.5;
	}
	return value;
}

void fragment() {
	vec2 uv = UV * noise_scale;
	vec2 wind_dir_n = normalize(wind_direction);
	vec2 drift = wind_dir_n * TIME * wind_speed;

	float texture_pattern = fbm(uv + drift * 0.5);
	float gust_phase = dot(UV, wind_dir_n) * gust_frequency - TIME * wind_speed * 2.0;
	float gust = pow(max(sin(gust_phase), 0.0), gust_sharpness);
	float final_pattern = clamp(texture_pattern + gust * wind_strength, 0.0, 1.0);

	vec3 grass_color;
	if (final_pattern < 0.45) {
		grass_color = mix(grass_dark.rgb, grass_mid.rgb, final_pattern / 0.45);
	} else {
		grass_color = mix(grass_mid.rgb, grass_light.rgb, (final_pattern - 0.45) / 0.55);
	}

	vec3 n = normalize(NORMAL);
	float ndotl = clamp(dot(n, normalize(-light_dir)), 0.0, 1.0);
	float banded = floor(ndotl * float(band_count)) / float(band_count);
	banded = clamp(banded + 0.55, 0.0, 1.0);

	grass_color += vec3(rim_boost) * gust * 0.3;

	ALBEDO = grass_color * banded;
}