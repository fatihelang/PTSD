extends Node3D

@export var lift_amount: float = 0.04
@export var forward_push: float = 0.02
@export var glow_scale: float = 1.1
@export var lerp_speed: float = 10.0
@export var corner_radius: float = 0.18

const TAG_COLORS := {
	"Evaluasi": Color("6C7A89"),
	"Tunda": Color("E0A458"),
	"Maaf": Color("E0779A"),
	"Subsidi": Color("4CAF50"),
	"Investasi": Color("26A69A"),
	"Transparansi": Color("64B5F6"),
	"Bansos": Color("FF8A65"),
	"Pajak": Color("C9A227"),
	"Impor": Color("8E44AD"),
	"Ekspor": Color("34568B"),
	"Represif": Color("8B1E1E"),
	"Dialog": Color("26C6DA"),
	"Deregulasi": Color("A97449"),
	"Nasionalisasi": Color("1A237E"),
	"Meremehkan": Color("455A64"),
}
const DEFAULT_FACE_COLOR := Color("CCCCCC")

const ROUNDED_SHADER_CODE := """
shader_type spatial;
render_mode unshaded, cull_back, blend_mix;

uniform vec4 base_color : source_color = vec4(1.0);
uniform vec4 emission_color : source_color = vec4(0.0);
uniform float emission_strength : hint_range(0.0, 3.0) = 0.0;
uniform float radius : hint_range(0.0, 0.5) = 0.15;
uniform float aspect = 1.0;

void fragment() {
	vec2 uv = (UV * 2.0 - 1.0);
	uv.x *= aspect;
	vec2 half_size = vec2(aspect, 1.0) - vec2(radius);
	vec2 d = abs(uv) - half_size;
	float dist = length(max(d, 0.0)) - radius;
	if (dist > 0.0) {
		discard;
	}
	ALBEDO = base_color.rgb + emission_color.rgb * emission_strength;
	ALPHA = base_color.a;
}
"""

@onready var label: Label3D = $CardMesh/CardWhiteBorder/CardFace/CardText
@onready var effect_label: Label3D = $CardMesh/CardWhiteBorder/CardFace/CardEffectText
@onready var border_black: MeshInstance3D = $CardMesh
@onready var border_white: MeshInstance3D = $CardMesh/CardWhiteBorder
@onready var face: MeshInstance3D = $CardMesh/CardWhiteBorder/CardFace
@onready var icon_sprite: Sprite3D = $CardMesh/CardWhiteBorder/CardFace/CardIcon

var card_data: CardData
var full_text: String = ""
var base_position: Vector3
var is_current: bool = false
var is_inspected: bool = false

var border_black_mat: ShaderMaterial
var border_white_mat: ShaderMaterial
var face_mat: ShaderMaterial

static var _shared_shader: Shader = null


func _ready() -> void:
	_setup_materials()


func _get_shader() -> Shader:
	if _shared_shader == null:
		_shared_shader = Shader.new()
		_shared_shader.code = ROUNDED_SHADER_CODE
	return _shared_shader


func _make_rounded_material(mesh_inst: MeshInstance3D, color: Color, radius_scale: float) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = _get_shader()
	var mesh_size: Vector2 = (mesh_inst.mesh as QuadMesh).size
	mat.set_shader_parameter("aspect", mesh_size.x / mesh_size.y)
	mat.set_shader_parameter("radius", corner_radius * radius_scale)
	mat.set_shader_parameter("base_color", color)
	mat.set_shader_parameter("emission_color", Color(1.0, 0.85, 0.3))
	mat.set_shader_parameter("emission_strength", 0.0)
	mesh_inst.set_surface_override_material(0, mat)
	return mat


func _setup_materials() -> void:
	border_black_mat = _make_rounded_material(border_black, Color.BLACK, 1.0)
	border_white_mat = _make_rounded_material(border_white, Color.WHITE, 1.05)
	face_mat = _make_rounded_material(face, DEFAULT_FACE_COLOR, 1.1)


func set_card_data(data: CardData) -> void:
	card_data = data
	full_text = data.card_name
	label.text = data.card_name
	effect_label.text = "Trust %+d | Trauma %+d" % [data.trust_effect, data.trauma_effect]
	_apply_tag_color(data.tag)
	_apply_icon(data.tag)


func _apply_tag_color(tag: String) -> void:
	face_mat.set_shader_parameter("base_color", TAG_COLORS.get(tag, DEFAULT_FACE_COLOR))


func _apply_icon(tag: String) -> void:
	if tag.strip_edges() == "":
		icon_sprite.visible = false
		return
	var path := "res://assets/cards/card_icon_%s.png" % tag.to_lower()
	if ResourceLoader.exists(path):
		icon_sprite.texture = load(path)
		icon_sprite.visible = true
	else:
		push_warning("Ikon tidak ditemukan untuk tag: " + tag)
		icon_sprite.visible = false


func set_base_position(pos: Vector3) -> void:
	base_position = pos
	position = pos


func set_current(current: bool) -> void:
	is_current = current
	border_black_mat.set_shader_parameter("emission_strength", 1.8 if current else 0.0)


func set_inspected(inspected: bool) -> void:
	is_inspected = inspected


func play_deal_in(from_position: Vector3, target_rotation: Vector3, delay: float, duration: float) -> void:
	position = from_position
	rotation_degrees = target_rotation + Vector3(0, 0, randf_range(-45, 45))
	await get_tree().create_timer(delay).timeout
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", base_position, duration)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", target_rotation, duration)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	if is_inspected:
		return
	var target_y: float = base_position.y + (lift_amount if is_current else 0.0)
	var target_z: float = base_position.z + (forward_push if is_current else 0.0)
	var target_scale: float = glow_scale if is_current else 1.0
	position.y = lerp(position.y, target_y, delta * lerp_speed)
	position.z = lerp(position.z, target_z, delta * lerp_speed)
	scale = scale.lerp(Vector3.ONE * target_scale, delta * lerp_speed)
