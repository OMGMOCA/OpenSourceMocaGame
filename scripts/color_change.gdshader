shader_type canvas_item;

uniform vec2 pixel_count = vec2(256);

uniform float darkness_factor : hint_range(0.0, 2.0) = 1; // 变暗程度
uniform float saturation_factor : hint_range(0.0, 2.0) = 1; // 饱和度降低程度
uniform float hue_factor : hint_range(-1, 1.0) = 0; // 色相

// RGB转HSV函数
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// HSV转RGB函数
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;

	uv *= pixel_count;
	uv = floor(uv);
	uv /= pixel_count;

    vec4 tex_color = texture(TEXTURE, uv);
	
	// 调整色相
	vec3 hsv = rgb2hsv(tex_color.rgb);
	hsv.x = hsv.x + hue_factor;
	vec3 rgb = hsv2rgb(hsv);
	tex_color = vec4(rgb, tex_color.a);

    // 将颜色转换为灰度
    float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    // 混合灰度和原始颜色以降低饱和度
    vec3 desaturated_color = mix(vec3(gray), tex_color.rgb, saturation_factor);

    // 变暗处理
    vec3 darkened_color = desaturated_color * darkness_factor;

    // 设置最终颜色
    COLOR = vec4(darkened_color, tex_color.a);
	
}
