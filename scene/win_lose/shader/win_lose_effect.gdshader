shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(0.0, 1.0, 0.0, 1.0); // Verde come colore di base
uniform float tint_strength : hint_range(0.0, 1.0) = 0.2; // Intensità della tinta verde

void fragment() {
    vec4 original_color = texture(TEXTURE, UV); // Colore originale della texture
    vec4 green_tint = tint_color * tint_strength;
    COLOR = mix(original_color, green_tint, tint_strength); // Mescola colore originale con tinta
}