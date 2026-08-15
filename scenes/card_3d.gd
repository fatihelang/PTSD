extends Node3D

@export var lift_amount: float = 0.04
@export var forward_push: float = 0.02
@export var lerp_speed: float = 10.0
@export var base_render_priority: int = 0


@onready var label: Label3D = $CardText
@onready var effect_label: Label3D = $CardEffectText
@onready var art: Sprite3D = $CardArt

var card_data: CardData
var full_text: String = ""
var base_position: Vector3
var is_current: bool = false
var is_inspected: bool = false


func _ready() -> void:
	return
	
	


func set_card_data(data: CardData) -> void:
	card_data = data
	full_text = data.card_name
	if label:
		label.text = data.card_name
	if effect_label:
		effect_label.text = "Trust %+d | Trauma %+d" % [data.trust_effect, data.trauma_effect]
	_apply_art(data.card_id)


func _apply_art(card_id: String) -> void:
	if card_id.strip_edges() == "":
		push_warning("card_id kosong, gambar kartu nggak bisa dimuat")
		return
	var path := "res://assets/cards/%s.png" % card_id
	if ResourceLoader.exists(path):
		art.texture = load(path)
	else:
		push_warning("Art kartu tidak ditemukan: " + path)


func set_base_position(pos: Vector3) -> void:
	base_position = pos
	position = pos


func set_render_index(index: int) -> void:
	base_render_priority = index
	art.render_priority = index


func set_current(current: bool) -> void:
	is_current = current
	art.render_priority = base_render_priority + (50 if current else 0)




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
	position.y = lerp(position.y, target_y, delta * lerp_speed)
	position.z = lerp(position.z, target_z, delta * lerp_speed)
