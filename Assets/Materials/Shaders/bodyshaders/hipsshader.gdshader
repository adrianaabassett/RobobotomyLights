shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Cell shader WITH texture by Adri
//hips

group_uniforms Standard_Properties;
uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);
uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;
uniform float specular : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float metallic : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform vec3 uv1_scale = vec3(1.0);
uniform vec3 uv1_offset = vec3(0.0);
uniform vec3 uv2_scale = vec3(1.0);
uniform vec3 uv2_offset = vec3(0.0);

// cell shader stuff starts here
group_uniforms Cel_Lighting;
uniform bool use_stepped = true;
uniform float steps = 1.0;
uniform float step_smoothness : hint_range(0.0, 1.0, 0.05) = 0.0;
uniform vec4 shadow_tint : source_color;
uniform float shadow_tint_amount : hint_range(0.0, 1.0, 0.1) = 0.4;
uniform vec4 diffuse_color : source_color = vec4(1.0);

group_uniforms Normal_Map;
uniform float normal_strength : hint_range(0.0, 1.0, 0.05) = 0.0;
uniform sampler2D normal_texture : hint_normal, filter_linear_mipmap, repeat_enable; 

varying vec4 node_position;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

float shape_value(float value, vec2 uv, vec2 screen_size){
	float aspect = screen_size.y / screen_size.x;
	return aspect;
}

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
	node_position = (PROJECTION_MATRIX * vec4(NODE_POSITION_VIEW, 1.0));
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	albedo_tex *= COLOR; 
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	vec4 normal_map = texture(normal_texture, base_uv);
	NORMAL_MAP = mix(vec3(0.5, 0.5, 1.0), normal_map.rgb, normal_strength);

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	
	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	
	SPECULAR = specular;
}
void light () {
	float ndotl = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION;
	float light = ndotl;

	if (use_stepped) {
		float light_mult = light * steps;
		float step_base = floor(light_mult);
		float light_factor = light_mult - step_base;

		light_factor = smoothstep(0.5 - step_smoothness, 0.5 + step_smoothness, light_factor);
		light = (step_base + light_factor) / steps;
	}
	vec3 diffuse = vec3(light) * (LIGHT_COLOR / PI);
	diffuse = (shadow_tint.rgb * (1.0 - (light)) * shadow_tint_amount) + diffuse * light;
	
	if(false){
		diffuse += diffuse_color.rgb ;
	}

	DIFFUSE_LIGHT += diffuse;
	SPECULAR_LIGHT += vec3(pow(light, 50.0)) * specular;
}