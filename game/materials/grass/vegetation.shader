shader_type spatial;

uniform float amplitude = 0.2;
uniform vec2 speed = vec2(2.0, 1.5);
uniform vec2 scale = vec2(0.1, 0.2);
uniform float alpha_cut = 0.15;

uniform bool reflections = false;

uniform sampler2D tex_albedo : hint_albedo;


void vertex() {
	if (VERTEX.y > 0.0) {
		vec3 worldpos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
		VERTEX.x += amplitude * sin(worldpos.x * scale.x * 0.75 + TIME * speed.x) * cos(worldpos.z * scale.x + TIME * speed.x * 0.25);
		VERTEX.z += amplitude * sin(worldpos.x * scale.y + TIME * speed.y * 0.35) * cos(worldpos.z * scale.y * 0.80 + TIME * speed.y);
	}
}

void fragment() {
	vec4 color = texture(tex_albedo, UV);
	ALBEDO = color.rgb;
	ALPHA = color.a;
	ALPHA_SCISSOR = alpha_cut;
	
	if (reflections) {
		SPECULAR = 0.8;
		ROUGHNESS = 0.0;
		METALLIC = 1.0;
	}else {
		SPECULAR = 0.1;
		ROUGHNESS = 0.8;
		METALLIC = 0.2;
	}
	TRANSMISSION = color.rgb * 0.25;
}
