shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.82, 0.84, 0.86, 1.0); 
uniform vec4 wave_light : source_color = vec4(0.96, 0.96, 0.98, 1.0); 
uniform vec4 wave_dark : source_color = vec4(0.65, 0.67, 0.70, 1.0);  

uniform float wave_speed : hint_range(0.1, 5.0) = 1.2;
uniform float wave_scale : hint_range(1.0, 50.0) = 18.0;
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.03;

void fragment() {
    vec2 uv = UV;

    float wave1 = sin(uv.x * wave_scale + TIME * wave_speed);
    float wave2 = cos(uv.y * (wave_scale * 0.7) - TIME * (wave_speed * 1.3));
    float wave3 = sin((uv.x + uv.y) * (wave_scale * 0.5) + TIME * (wave_speed * 0.8));

    float wave_height = (wave1 + wave2 + wave3) / 3.0;

    vec2 offset = vec2(wave1, wave2) * distortion_strength;
    vec2 distorted_uv = uv + offset;

    float micro_ripple = sin(distorted_uv.x * wave_scale * 2.0 + TIME * wave_speed * 2.0) 
                       * cos(distorted_uv.y * wave_scale * 2.0 - TIME * wave_speed * 1.5);

    vec4 final_color = base_color;
    
    final_color = mix(final_color, wave_dark, smoothstep(0.0, -0.8, wave_height) * 0.6);
    
    float highlights = smoothstep(0.2, 0.9, wave_height + micro_ripple * 0.3);
    final_color = mix(final_color, wave_light, highlights * 0.7);

    COLOR = final_color;
}