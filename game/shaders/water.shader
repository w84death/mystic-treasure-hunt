
shader_type spatial;
//render_mode blend_mix, depth_draw_opaque, cull_back,diffuse_burley,specular_schlick_ggx;

uniform vec2 amplitude = vec2(0.5, 0.3);
uniform vec2 frequency = vec2(.2, .2);
uniform vec2 time_factor = vec2(2.0, 2.0);

uniform float water_height = 2.5;
uniform vec3 water_color = vec3(0.1,0.4,0.8);
uniform vec3 water_color2 = vec3(0.5,0.5,0.5);

uniform float beer_factor = 2.0;
varying float wave_height;

float height(vec2 pos, float time, float noise){
	return (amplitude.x  * sin(pos.x * frequency.x * noise + time * time_factor.x)) + (amplitude.y * sin(pos.y * frequency.y * noise + time * time_factor.y));
}

float fake_random(vec2 p){
	return fract(sin(dot(p.xy, vec2(12.9898,78.233))) * 43758.5453);
}

vec2 faker(vec2 p){
	return vec2(fake_random(p), fake_random(p*124.32));
}

void vertex(){
	float noise = faker(VERTEX.xz).x;
	wave_height = height(VERTEX.xz, TIME, noise);
	VERTEX.y = water_height + wave_height;
	TANGENT = normalize( vec3(0.0, height(VERTEX.xz + vec2(0.0, 0.4), TIME, noise) - height(VERTEX.xz + vec2(0.0, -0.4), TIME, noise), 0.6));
	BINORMAL = normalize( vec3(0.6, height(VERTEX.xz + vec2(0.4, 0.0), TIME, noise) - height(VERTEX.xz + vec2(-0.4, 0.0), TIME, noise), 0.0));
	NORMAL = cross(TANGENT, BINORMAL);
}

void fragment(){
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	depth = depth * 2.0 - 1.0;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	depth = depth + VERTEX.z;
	depth = exp(-depth * beer_factor);
	
	ROUGHNESS = clamp(1.0 - wave_height*0.2, 0.1, 0.8);
	EMISSION = water_color;
	METALLIC = 0.6;
	SPECULAR = 0.0;
	ALPHA = clamp(1.0-depth, 0.0, 1.0);
	ALBEDO = mix(water_color, water_color2, clamp(wave_height, 0.0, 1.0));
}