extends Node3D

@export var lift_amount: float = 0.04
@export var glow_scale: float = 1.1
@export var lerp_speed: float = 10.0
@onready var effect_label: Label3D = $CardMesh/CardWhiteBorder/CardFace/CardEffectText

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

@onready var label: Label3D = $CardMesh/CardWhiteBorder/CardFace/CardText
@onready var border_black: MeshInstance3D = $CardMesh
@onready var border_white: MeshInstance3D = $CardMesh/CardWhiteBorder
@onready var face: MeshInstance3D = $CardMesh/CardWhiteBorder/CardFace
@onready var icon_sprite: Sprite3D = $CardMesh/CardWhiteBorder/CardFace/CardIcon

var card_data: CardData
var full_text: String = ""
var base_position: Vector3
var is_current: bool = false
var is_inspected: bool = false

var border_normal_material: StandardMaterial3D
var border_glow_material: StandardMaterial3D
var face_material: StandardMaterial3D


func _ready() -> void:
	_setup_materials()


func _setup_materials() -> void:
	border_normal_material = StandardMaterial3D.new()
	border_normal_material.albedo_color = Color.BLACK
	border_black.set_surface_override_material(0, border_normal_material)

	border_glow_material = border_normal_material.duplicate()
	border_glow_material.emission_enabled = true
	border_glow_material.emission = Color(1.0, 0.85, 0.3)
	border_glow_material.emission_energy_multiplier = 1.8

	var white_material := StandardMaterial3D.new()
	white_material.albedo_color = Color.WHITE
	border_white.set_surface_override_material(0, white_material)

	face_material = StandardMaterial3D.new()
	face_material.albedo_color = DEFAULT_FACE_COLOR
	face.set_surface_override_material(0, face_material)


func set_card_data(data: CardData) -> void:
	card_data = data
	full_text = data.card_name
	label.text = data.card_name
	effect_label.text = "Trust %+d | Trauma %+d" % [data.trust_effect, data.trauma_effect]
	_apply_tag_color(data.tag)
	_apply_icon(data.tag)

func _apply_tag_color(tag: String) -> void:
	face_material.albedo_color = TAG_COLORS.get(tag, DEFAULT_FACE_COLOR)


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
	border_black.set_surface_override_material(0, border_glow_material if current else border_normal_material)


func set_inspected(inspected: bool) -> void:
	is_inspected = inspected


func _process(delta: float) -> void:
	if is_inspected:
		return
	var target_y: float = base_position.y + (lift_amount if is_current else 0.0)
	var target_scale: float = glow_scale if is_current else 1.0
	position.y = lerp(position.y, target_y, delta * lerp_speed)
	scale = scale.lerp(Vector3.ONE * target_scale, delta * lerp_speed)
