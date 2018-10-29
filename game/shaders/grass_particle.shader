// -----------------------------------------------------------------------------
// VEGETATION PARTICLE SHADER
// -----------------------------------------------------------------------------
// based on many tutorials / final version by Krzysztof Jankowski
// (c) P1X 2018 / fill free to use just don't bother me
// -----------------------------------------------------------------------------

shader_type particles;

// SETTINGS --------------------------------------------------------------------

// SET RANDOM FLOAT FOR EACH VEGETATION TYPE
uniform float RANDOM_SEED = 0.1234;

// TERRAIN SETTINGS
uniform float TERRAIN_SURFACE_SCALE = 4.0;
uniform float TERRAIN_HEIGHT_SCALE = 64.0;
uniform float TERRAIN_WATER_LEVEL = 4.0;
uniform float TERRAIN_MOINTAINS_LEVEL = 0.65;
uniform float TERRAIN_MOINTAINS_SCALE = 3.0;

// VEGETATION SETTINGS
uniform float GRASS_ROWS = 64;
uniform float GRASS_SPACING = 12.0;
uniform float GRASS_TWIST_SCALE_MIN = 0.5;
uniform float GRASS_TWIST_SCALE_MAX = 2.0;
uniform bool ZONE_RED = false;
uniform bool ZONE_GREEN = false;
uniform bool ZONE_BLUE = false;

// MAPS
uniform sampler2D HEIGHT_MAP;
uniform sampler2D FEATURES_MAP;
uniform vec2 MAP_SIZE = vec2(2048.0, 2048.0);


// HELPERS ---------------------------------------------------------------------

// RETURNS HEIGHT FROM HEIGHT_MAP
float get_height(vec2 pos) {
	pos -= 0.5 * MAP_SIZE;
	pos /= MAP_SIZE; // center
	float h = texture(HEIGHT_MAP, pos).r; // read height from texture
	if (h>TERRAIN_MOINTAINS_LEVEL) { // check if we hit the mountain level
		h += (h-TERRAIN_MOINTAINS_LEVEL)*TERRAIN_MOINTAINS_SCALE; // TWIST_SCALE up for mountain effect
	}
	return TERRAIN_HEIGHT_SCALE * h; // adjust for the overall terrain TWIST_SCALE
}

// RANDOM NUMBER GENERATORS
float fake_random(vec2 p){
	return fract(sin(dot(p.xy, vec2(12.9898,78.233))) * 43758.5453);
}
vec2 faker(vec2 p){
	return vec2(fake_random(p),fake_random(p*RANDOM_SEED));
}

// THREE DIMENSIONAL MATRIX MANIPULATION
mat4 enterTheMatrix(vec3 pos, vec3 axis, float angle, float TWIST_SCALE){
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

	// converts matrix for position, angle (for each axix) and TWIST_SCALE
    return mat4(vec4((oc * axis.x * axis.x + c)* TWIST_SCALE,		oc * axis.x * axis.y - axis.z * s,	oc * axis.z * axis.x + axis.y * s,	0.0),
                vec4(oc * axis.x * axis.y + axis.z * s,		(oc * axis.y * axis.y + c) * TWIST_SCALE,	oc * axis.y * axis.z - axis.x * s,	0.0),
                vec4(oc * axis.z * axis.x - axis.y * s,		oc * axis.y * axis.z + axis.x * s,	(oc * axis.z * axis.z + c) * TWIST_SCALE,	0.0),
                vec4(pos.x,									pos.y,								pos.z,								1.0));
}

// VERTEX ----------------------------------------------------------------------

void vertex() {

	vec3 pos = vec3(0.0, 0.0, 0.0);
	pos.z = float(INDEX);
	pos.x = mod(pos.z, GRASS_ROWS);
	pos.z = (pos.z - pos.x) / GRASS_ROWS; // obtain our position based on which particle we're rendering


	pos.x -= GRASS_ROWS * 0.5;
	pos.z -= GRASS_ROWS * 0.5; // center
	pos *= GRASS_SPACING; // apply grass spacing

	// center on our particle location but within our spacing and TWIST_SCALE
	pos.x += (EMISSION_TRANSFORM[3][0] - mod(EMISSION_TRANSFORM[3][0], GRASS_SPACING*TERRAIN_SURFACE_SCALE))/TERRAIN_SURFACE_SCALE;
	pos.z += (EMISSION_TRANSFORM[3][2] - mod(EMISSION_TRANSFORM[3][2], GRASS_SPACING*TERRAIN_SURFACE_SCALE))/TERRAIN_SURFACE_SCALE;


	vec2 noise = faker(pos.xz); // generate some noise based on our _world_ position

	pos.x += (noise.x * 4.0 ) * GRASS_SPACING;
	pos.z += (noise.y * 4.0 ) * GRASS_SPACING; // apply noise and spacing
	pos.y = get_height(pos.xz); // apply height

	// check if on flat land or clif
	float y2 = get_height(pos.xz + vec2(1.0, 0.0));
	float y3 = get_height(pos.xz + vec2(0.0, 1.0)); // get near positions

	vec2 feat_pos = pos.xz;
	feat_pos -= 0.5 * MAP_SIZE;
	feat_pos /= MAP_SIZE; // center

	// prepare terrain mask for each zone
	float terrain_mask = 0.0;
	if (ZONE_RED) {
		terrain_mask += texture(FEATURES_MAP, feat_pos).r;
	}
	if (ZONE_GREEN) {
		terrain_mask += texture(FEATURES_MAP, feat_pos).g;
	}
	if (ZONE_BLUE) {
		terrain_mask += texture(FEATURES_MAP, feat_pos).b;
	}

	// remove particle if
	if (terrain_mask < 0.65 || pos.y < TERRAIN_WATER_LEVEL) { // don't fit any terrain mask or is underwater
		pos.y = -10000.0;
	} else if (abs(y2 - pos.y) > 0.5) { // it's on clif
		pos.y = -10000.0;
	} else if (abs(y3 - pos.y) > 0.5) { // it's on clif
		pos.y = -10000.0;
	}

	// calculate random scaling but within min/max
	float TWIST_SCALE_mod = clamp(noise.x * GRASS_TWIST_SCALE_MAX, GRASS_TWIST_SCALE_MIN, GRASS_TWIST_SCALE_MAX);

	// do the final transformation
	TRANSFORM = enterTheMatrix(
		vec3(pos.x * TERRAIN_SURFACE_SCALE, pos.y * TERRAIN_SURFACE_SCALE, pos.z * TERRAIN_SURFACE_SCALE), // set position
		vec3(0.0, 1.0, 0.0), // lock Y axis
		clamp(noise.y * 320.0, 0.0, 320.0), // rotate 0-360 (over Y)
		TWIST_SCALE_mod); // TWIST_SCALE
}

// -----------------------------------------------------------------------------
// EOF.
// -----------------------------------------------------------------------------
