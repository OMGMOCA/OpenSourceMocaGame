shader_type canvas_item;

uniform vec2 pixel_count = vec2(256);

uniform float darkness_factor : hint_range(0.0, 1.0) = 0.5; // 变暗程度
uniform float saturation_factor : hint_range(0.0, 1.0) = 0.5; // 饱和度降低程度

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;

	uv *= pixel_count;
	uv = floor(uv);
	uv /= pixel_count;
	    // 获取原始纹理颜色

	    // 获取原始纹理颜色
    vec4 tex_color = texture(TEXTURE, uv);

    // 将颜色转换为灰度
    float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));

    // 混合灰度和原始颜色以降低饱和度
    vec3 desaturated_color = mix(vec3(gray), tex_color.rgb, saturation_factor);

    // 变暗处理
    vec3 darkened_color = desaturated_color * darkness_factor;

    // 设置最终颜色
    COLOR = vec4(darkened_color, tex_color.a);


}
