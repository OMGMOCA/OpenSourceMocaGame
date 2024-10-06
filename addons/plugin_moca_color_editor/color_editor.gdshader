shader_type canvas_item;

uniform vec4 color_palette[256];
uniform vec4 color_palette_new[256];
uniform int palette_length;


void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	for (int i = 0; i < palette_length; i++) {
		if (distance(tex_color,color_palette[i]) < 0.01) {
			tex_color = color_palette_new[i];
		}
	}


    COLOR = tex_color;
}
