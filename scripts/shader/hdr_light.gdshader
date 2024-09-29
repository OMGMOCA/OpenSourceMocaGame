shader_type canvas_item;

uniform vec4 replace_color : source_color = vec4(0,0,0,1);
void fragment() {
	// Called for every pixel the material is visible on.
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = vec4(replace_color.rgb, tex_color.a);
}
