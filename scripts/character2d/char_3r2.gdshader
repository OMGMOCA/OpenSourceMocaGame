shader_type canvas_item;

//uniform vec2 pixel_count = vec2(64);

uniform float outline_width = 1.0; //描边宽度
uniform vec4 outline_color : source_color = vec4(0,0,0,1);

uniform vec4 replace_color : source_color = vec4(2,2,2,1);
uniform bool is_hit = false;

void fragment() {
	vec2 uv = UV;

	//像素化
	//uv *= pixel_count;
	//uv = floor(uv);
	//uv /= pixel_count;

	//COLOR = texture(TEXTURE, uv);

	//描边
	vec2 uv_up = uv + vec2(0,TEXTURE_PIXEL_SIZE.y) * outline_width;
	vec2 uv_down = uv + vec2(0,-TEXTURE_PIXEL_SIZE.y) * outline_width;
	vec2 uv_left = uv + vec2(TEXTURE_PIXEL_SIZE.x,0) * outline_width;
	vec2 uv_right = uv + vec2(-TEXTURE_PIXEL_SIZE.x,0) * outline_width;

	vec4 color_up = texture(TEXTURE,uv_up);
	vec4 color_down = texture(TEXTURE,uv_down);
	vec4 color_left = texture(TEXTURE,uv_left);
	vec4 color_right = texture(TEXTURE,uv_right);
	vec4 outline = color_up + color_down + color_left + color_right;
	outline.rgb = outline_color.rgb;
	//限制alpha不大于1
	//outline.a = min(outline.a,1.0);
	//if (outline.a > 0.0) {
		//outline = outline_color;
	//}

	//获取原始颜色
	vec4 original_color = texture(TEXTURE,uv);
	//if (original_color.a < 1.0) {
		//original_color.a = 0.0;
	//}


	//混合原始颜色和描边
	COLOR = mix(outline,original_color,original_color.a);
	//COLOR = outline;
	//命中改色
	if (is_hit){
		vec4 tex_color = texture(TEXTURE, UV);
		//COLOR = vec4(replace_color.rgb, tex_color.a);
		vec4 color = mix(tex_color,replace_color,replace_color.a);
		COLOR = vec4(color.rgb, tex_color.a);
	}



}
