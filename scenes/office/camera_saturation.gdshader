shader_type canvas_item;

uniform float saturation : hint_range(0.0, 2.0) = 1.0; // valor da saturação, altera pelo inspector

void fragment() {
    vec4 c = texture(TEXTURE, UV);
    float gray = dot(c.rgb, vec3(0.299, 0.587, 0.114));

    c.rgb = mix(vec3(gray), c.rgb, saturation);
    COLOR = c;
}
