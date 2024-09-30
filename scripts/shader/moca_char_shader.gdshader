shader_type canvas_item;

uniform vec4 replace_color : source_color = vec4(2,2,2,1);
uniform bool is_hit = false;

void fragment() {
	if (is_hit){
		vec4 tex_color = texture(TEXTURE, UV);
		COLOR = vec4(replace_color.rgb, tex_color.a);
	}

}


