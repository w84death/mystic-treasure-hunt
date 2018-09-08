shader_type spatial;
//render_mode blend_mix,diffuse_toon,specular_toon;

uniform sampler2D tex_albedo : hint_albedo;


void vertex() {

}

void fragment() {
	vec4 color = texture(tex_albedo, UV);
	ALBEDO = color.rgb;
	ALPHA = 1.0;
	
	SPECULAR = 0.5;
	ROUGHNESS = 1.0;
	METALLIC = 0.2;
}