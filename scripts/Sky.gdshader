shader_type sky;

uniform vec4 sky_top_color : source_color = vec4(0.25, 0.60, 0.98, 1.0);
uniform vec4 sky_horizon_color : source_color = vec4(0.65, 0.88, 1.0, 1.0);
uniform vec4 ground_color : source_color = vec4(0.55, 0.78, 0.92, 1.0);
uniform float horizon_blur : hint_range(0.0, 0.5) = 0.1;

uniform vec4 cloud_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 cloud_shadow_color : source_color = vec4(0.75, 0.85, 0.95, 1.0);
uniform float cloud_speed : hint_range(0.0, 0.1) = 0.012;
uniform float cloud_scale : hint_range(1.0, 10.0) = 2.5;
uniform float cloud_coverage : hint_range(0.0, 1.0) = 0.4;
uniform float cloud_edge_sharpness : hint_range(1.0, 20.0) = 8.0;


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

void sky() {
	float up = clamp(EYEDIR.y, -1.0, 1.0);

	vec3 col;
	if (up > 0.0) {
		float t = smoothstep(0.0, horizon_blur, up);
		col = mix(sky_horizon_color.rgb, sky_top_color.rgb, t);

		vec2 cloud_uv = EYEDIR.xz / max(up, 0.15) * cloud_scale + vec2(TIME * cloud_speed, 0.0);
		float cloud_n = noise(cloud_uv) * 0.6 + noise(cloud_uv * 2.3) * 0.4;

		float cloud_mask = smoothstep(1.0 - cloud_coverage, 1.0 - cloud_coverage + 1.0 / cloud_edge_sharpness, cloud_n);
		float cloud_shade = smoothstep(1.0 - cloud_coverage - 0.1, 1.0 - cloud_coverage + 0.05, cloud_n);
		vec3 cloud_final = mix(cloud_shadow_color.rgb, cloud_color.rgb, cloud_shade);

		col = mix(col, cloud_final, cloud_mask * smoothstep(0.03, 0.25, up));
	} else {
		col = ground_color.rgb;
	}

	COLOR = col;
}