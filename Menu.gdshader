shader_type canvas_item;

uniform bool crt_enabled = true;

// Godot automatically populates these hints with the camera's viewport data
uniform sampler2D viewportNearest : hint_screen_texture, filter_nearest, repeat_disable;
uniform sampler2D viewportLinear : hint_screen_texture, filter_linear, repeat_disable;

group_uniforms Scanlines;
uniform float scanLineFac : hint_range(0.0, 1.0) = 0.15;
uniform float scanLineWidth : hint_range(0.0, 0.5) = 0.25;
uniform float scanLineSpeed : hint_range(-5.0, 5.0) = 0.5; // Speed of the rolling lines

group_uniforms Flicker_and_Intensity;
uniform float linearFac = 1.3;
uniform float nearestFac = 0.0;
uniform bool flicker_enabled = true;
uniform float flicker_strength : hint_range(0.0, 0.05) = 0.015; // Subtle variation in brightness

group_uniforms Chromatic_Aberration;
uniform bool abberation_enabled = true;
const highp float abberationFac = 0.001;

const vec2 RESOLUTION = vec2(320.0, 180.0);

void fragment() {
    if (crt_enabled) {
        // --- ANIMATED SCANLINES ---
        float fy = fract((SCREEN_UV * RESOLUTION).y + (TIME * scanLineSpeed));
        float scanLine = 0.0;
        float chromaticStrength = abberation_enabled ? 1.0 : 0.0;
        
        if (fy < scanLineWidth || fy > 1.0 - scanLineWidth) {
            scanLine = scanLineFac;
        }
        
        // FIX: Construct the base vec4 cleanly from the textures instead of performing additive math on the canvas
        vec4 resultColor = vec4(0.0, 0.0, 0.0, 1.0);
        
        // Directly assign or blend channels to overwrite the ColorRect's native white layout
        resultColor.r = texture(viewportLinear, SCREEN_UV - vec2(chromaticStrength * abberationFac, 0.0)).r;
        resultColor.b = texture(viewportLinear, SCREEN_UV + vec2(chromaticStrength * abberationFac, 0.0)).b;
        resultColor.g = texture(viewportLinear, SCREEN_UV).g;
        
        // Apply linear scaling and scanlines
        resultColor = mix(resultColor * linearFac, vec4(0.0, 0.0, 0.0, 1.0), scanLine);

        // Mix in the nearest sample blend
        resultColor += texture(viewportNearest, SCREEN_UV) * nearestFac;
        
        // --- ANIMATED SCREEN FLICKER ---
        if (flicker_enabled) {
            float flicker = sin(TIME * 60.0) * flicker_strength;
            resultColor.rgb += vec3(flicker);
        }
        
        COLOR = resultColor;
    }
    else {
        // FIX: Cleanly sample the screen texture instead of adding to it
        COLOR = texture(viewportNearest, SCREEN_UV);
    }
}
