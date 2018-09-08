shader_type particles;

uniform float uniq = 0.1234;
uniform float terrain_scale = 4.0;
uniform float rows = 12;
uniform float spacing = 1.0;
uniform float size_scale_min = 0.5;
uniform float size_scale_max = 2.0;
uniform bool red_zone = false;
uniform bool green_zone = false;
uniform bool blue_zone = false;
uniform sampler2D height_map;
uniform sampler2D features_map;
uniform float max_height = 18.0;
uniform float water_level = 54.0;
uniform vec2 heightmap_size = vec2(512.0, 512.0);
uniform float mountains_level = 0.6;
uniform float mountains_size = 6.0;

float get_height(vec2 pos) {
	pos -= 0.5 * heightmap_size;
	pos /= heightmap_size;
	float h = texture(height_map, pos).r;
	if (h>mountains_level) {
		h += (h-mountains_level)*mountains_size;
	}
	return max_height * h;
}

float fake_random(vec2 p){
	return fract(sin(dot(p.xy, vec2(12.9898,78.233))) * 43758.5453);
}
vec2 faker(vec2 p){
	return vec2(fake_random(p),fake_random(p*uniq));
}

mat4 enterTheMatrix(vec3 pos, vec3 axis, float angle, float scale){
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat4(vec4((oc * axis.x * axis.x + c)* scale,		oc * axis.x * axis.y - axis.z * s,	oc * axis.z * axis.x + axis.y * s,	0.0),
                vec4(oc * axis.x * axis.y + axis.z * s,		(oc * axis.y * axis.y + c) * scale,	oc * axis.y * axis.z - axis.x * s,	0.0),
                vec4(oc * axis.z * axis.x - axis.y * s,		oc * axis.y * axis.z + axis.x * s,	(oc * axis.z * axis.z + c) * scale,	0.0),
                vec4(pos.x,									pos.y,								pos.z,								1.0));
}

void vertex() {
	// obtain our position based on which particle we're rendering
	vec3 pos = vec3(0.0, 0.0, 0.0);
	pos.z = float(INDEX);
	pos.x = mod(pos.z, rows);
	pos.z = (pos.z - pos.x) / rows;
	
	// center this
	pos.x -= rows * 0.5;
	pos.z -= rows * 0.5;
	
	// and now apply our spacing
	pos *= spacing;
	
	// now center on our particle location but within our spacing
	pos.x += (EMISSION_TRANSFORM[3][0] - mod(EMISSION_TRANSFORM[3][0], spacing*terrain_scale))/terrain_scale;
	pos.z += (EMISSION_TRANSFORM[3][2] - mod(EMISSION_TRANSFORM[3][2], spacing*terrain_scale))/terrain_scale;

	// now add some noise based on our _world_ position
	vec2 noise = faker(pos.xz);

	pos.x += (noise.x * 4.0 ) * spacing;
	pos.z += (noise.y * 4.0 ) * spacing;
	
	// apply our height
	pos.y = get_height(pos.xz);
	
	float y2 = get_height(pos.xz + vec2(1.0, 0.0));
	float y3 = get_height(pos.xz + vec2(0.0, 1.0));

	vec2 feat_pos = pos.xz;
	feat_pos -= 0.5 * heightmap_size;
	feat_pos /= heightmap_size;
	
	float terrain_mask = 0.0;
	if (red_zone) {
		terrain_mask += texture(features_map, feat_pos).r;
	}
	if (green_zone) {
		terrain_mask += texture(features_map, feat_pos).g;
	}
	if (blue_zone) {
		terrain_mask += texture(features_map, feat_pos).b;
	}
	
	if (terrain_mask < 0.65 || pos.y < water_level) {
		pos.y = -10000.0;
	} else if (abs(y2 - pos.y) > 0.5) {
		pos.y = -10000.0;
	} else if (abs(y3 - pos.y) > 0.5) {
		pos.y = -10000.0;
	}
	
	float scale_mod = clamp(noise.x * size_scale_max, size_scale_min, size_scale_max);

	TRANSFORM = enterTheMatrix(
		vec3(pos.x * terrain_scale, pos.y * terrain_scale, pos.z * terrain_scale), 
		vec3(0.0, 1.0, 0.0), 
		clamp(noise.y * 320.0, 0.0, 320.0), 
		scale_mod);
}