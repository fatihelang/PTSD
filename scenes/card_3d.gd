extends Node3D

@export var lift_amount: float = 0.04
@export var glow_scale: float = 1.1
@export var lerp_speed: float = 10.0

@onready var label: Label3D = $CardText
@onready var mesh: MeshInstance3D = $CardMesh

var card_data: CardData
var full_text: String = ""
var base_position: Vector3
var is_current: bool = false
var is_inspected: bool = false

var normal_material: StandardMaterial3D
var glow_material: StandardMaterial3D


func _ready() -> void:
	label.visible = false
	_setup_materials()


func _setup_materials() -> void:
	normal_material = StandardMaterial3D.new()
	normal_material.albedo_color = Color(0.95, 0.95, 0.9)
	mesh.set_surface_override_material(0, normal_material)

	glow_material = normal_material.duplicate()
	glow_material.emission_enabled = true
	glow_material.emission = Color(1.0, 0.85, 0.3)
	glow_material.emission_energy_multiplier = 1.8


func set_card_data(data: CardData) -> void:
	card_data = data
	full_text = data.card_name


func set_base_position(pos: Vector3) -> void:
	base_position = pos
	position = pos


func set_current(current: bool) -> void:
	is_current = current
	mesh.set_surface_override_material(0, glow_material if current else normal_material)


func set_inspected(inspected: bool) -> void:
	is_inspected = inspected


func _process(delta: float) -> void:
	if is_inspected:
		return
	var target_y: float = base_position.y + (lift_amount if is_current else 0.0)
	var target_scale: float = glow_scale if is_current else 1.0
	position.y = lerp(position.y, target_y, delta * lerp_speed)
	scale = scale.lerp(Vector3.ONE * target_scale, delta * lerp_speed)
