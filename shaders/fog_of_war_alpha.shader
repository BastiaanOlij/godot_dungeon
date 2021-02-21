shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform float max_distance = 20.0;
uniform float rim_size = 10.0;
uniform vec3 player_1 = vec3(0,0,0);
uniform vec3 player_2 = vec3(0,0,0);
uniform vec3 player_3 = vec3(0,0,0);
uniform vec3 player_4 = vec3(0,0,0);

varying vec3 world_pos;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	
	world_pos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float closest = 100.0;
	closest = min(closest, length(player_1 - world_pos));
	closest = min(closest, length(player_2 - world_pos));
	closest = min(closest, length(player_3 - world_pos));
	closest = min(closest, length(player_4 - world_pos));
	
	float factor = (max_distance - closest) / rim_size;
	if (factor < -1.0) discard;
	
	factor = clamp(factor, 0.0, 1.0);
	
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	albedo_tex *= COLOR;
	ALBEDO = albedo.rgb * albedo_tex.rgb * factor;
	ALPHA = albedo.a * albedo_tex.a;
	METALLIC = metallic * factor;
	ROUGHNESS = 1.0 - ((1.0 - roughness) * factor);
	SPECULAR = specular * factor;
}
