shader_type canvas_item;

uniform bool active = false;
uniform float fade : hint_range(0.0, 1.0) = 1.0; // opcional: fade extra animável

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Quando "active", força branco mas preserva a alpha original da textura:
    vec4 base = active ? vec4(1.0, 1.0, 1.0, tex.a) : tex;

    // Pega APENAS a alpha do nó (inclui self_modulate/modulate e hierarquia)
    float node_alpha = COLOR.a;

    // Aplica somente na alpha para não escurecer o RGB
    COLOR = vec4(base.rgb, base.a * node_alpha * fade);
}