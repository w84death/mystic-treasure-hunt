shader_type spatial;
render_mode cull_disabled,diffuse_toon,specular_toon;

uniform vec2 map_size = vec2(1024.0, 1024.0);
uniform float max_height = 18.0;
uniform float water_height = 0.6;

uniform float mountains_level = 0.7;
uniform float mountains_size = 3.0;

uniform sampler2D height_map;
uniform sampler2D features_map;

uniform sampler2D black_albedo : hint_albedo;
uniform sampler2D red_albedo : hint_albedo;
uniform sampler2D green_albedo : hint_albedo;
uniform sampler2D blue_albedo : hint_albedo;

uniform float uv_scale = 32.0;

float get_height(vec2 pos) {
	pos -= .5 * map_size;
	pos /= map_size;
	float h = texture(height_map, pos).r;
	if (h>mountains_level) {
		h += (h-mountains_level)*mountains_size;
	}
	return max_height * h;
}

void vertex() {
	VERTEX.y = get_height(VERTEX.xz);
	/*float A = 0.2;
	float B = 0.2;
	TANGENT = normalize( vec3(0.0, get_height(VERTEX.xz + vec2(0.0, B)) - get_height(VERTEX.xz + vec2(0.0, -0.1)), A));
	BINORMAL = normalize( vec3(A, get_height(VERTEX.xz + vec2(B, 0.0)) - get_height(VERTEX.xz + vec2(-0.1, 0.0)), 0.0));
	NORMAL = cross(TANGENT, BINORMAL);*/
}

void fragment() {
	vec2 uv2 = UV;
	uv2 *= vec2(-1.0,-1.0); // mirrored
	
	// get zones
	float zone_0 = clamp(1.0 - texture(features_map, uv2).r - texture(features_map, uv2).g - texture(features_map, uv2).b, 0.0, 1.0);
	float zone_r = texture(features_map, uv2).r;
	float zone_g = texture(features_map, uv2).g;
	float zone_b = texture(features_map, uv2).b;
	
	vec3 albedo_0 = texture(black_albedo, uv2 * uv_scale).rgb * zone_0;
	vec3 albedo_r = texture(red_albedo, uv2 * uv_scale).rgb * zone_r;
	vec3 albedo_g = texture(green_albedo, uv2 * uv_scale).rgb * zone_g;
	vec3 albedo_b = texture(blue_albedo, uv2 * uv_scale).rgb * zone_b;
	
	ALBEDO = albedo_0 + albedo_r + albedo_g + albedo_b;
	SPECULAR = 0.3;
	ROUGHNESS = 0.8;
	METALLIC = 0.7;
}
