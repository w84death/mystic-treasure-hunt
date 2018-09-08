shader_type spatial;
render_mode cull_disabled,diffuse_toon,specular_toon;

uniform float amplitude = 0.2;
uniform vec2 speed = vec2(2.0, 1.5);
uniform vec2 scale = vec2(0.1, 0.2);
uniform float alpha_cut = 0.15;

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
	
	SPECULAR = 0.2;
	ROUGHNESS = 0.2;
	METALLIC = 0.7;
	TRANSMISSION = color.rgb * 0.25;
}
