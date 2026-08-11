extends Node3D
#card fan
const Card3DScene = preload("res://scenes/Card3D.tscn")

@export var fan_angle_degrees: float = 55.0
@export var radius: float = 0.55
@export var base_position: Vector3 = Vector3(-0.28, -0.38, -0.55)
@export var throw_arc_height: float = 0.3
@export var throw_duration: float = 0.6
@export var throw_spin_degrees: float = 1080.0
@export var card_z_step: float = 0.01

@export var inspect_position: Vector3 = Vector3(0.0, 0.0, -0.4)
@export var inspect_scale: float = 1.8
@export var inspect_duration: float = 0.25

@export var grab_rotation: Vector3 = Vector3(0, 0, 90)
@export var grab_rotation_duration: float = 0.25

@export var npc_walk_controller_path: NodePath
@export var right_hand_path: NodePath
@export var npc_throw_target_path: NodePath
@export var world_root_path: NodePath
@export var player_head_path: NodePath

@export var inspect_rotate_speed: float = 0.3
@export var inspect_max_pitch: float = 35.0
@export var inspect_max_yaw: float = 60.0

@export var danger_overlay_path: NodePath
@export var severe_threshold: int = 8

@export var deck_origin: Vector3 = Vector3(-0.1, -0.5, -0.4)
@export var deal_stagger: float = 0.07
@export var deal_duration: float = 0.35


var inspect_pitch: float = 0.0
var inspect_yaw: float = 0.0

var cards: Array = []
var current_index: int = 0
var input_locked: bool = true
var is_inspecting: bool = false
var inspect_locked: bool = false
var inspected_card: Node3D = null
var inspected_original_position: Vector3 = Vector3.ZERO
var inspected_original_rotation: Vector3 = Vector3.ZERO

@onready var npc_walk_controller: Node3D = get_node(npc_walk_controller_path)
@onready var right_hand: Node3D = get_node(right_hand_path)
@onready var npc_throw_target: Node3D = get_node(npc_throw_target_path)
@onready var world_root: Node3D = get_node(world_root_path)
@onready var player_head: Node3D = get_node(player_head_path)
@onready var danger_overlay: TextureRect = get_node(danger_overlay_path)

var current_question: QuestionData = null


func _ready() -> void:
	input_locked = true


func show_hand(hand: Array, question: QuestionData = null) -> void:
	current_question = question
	_spawn_fan(hand)
	call_deferred("_update_selection_visual")
	input_locked = false
	player_head.set_input_enabled(true)


func _spawn_fan(hand: Array) -> void:
	for c in cards:
		c.queue_free()
	cards.clear()
	current_index = 0

	var count: int = hand.size()
	for i in range(count):
		var card = Card3DScene.instantiate()
		add_child(card)

		var t: float = 0.0
		if count > 1:
			t = float(i) / float(count - 1)
		var angle_deg: float = lerp(-fan_angle_degrees / 2.0, fan_angle_degrees / 2.0, t)
		var angle_rad: float = deg_to_rad(angle_deg)

		var x = base_position.x + sin(angle_rad) * radius
		var y = base_position.y - (1.0 - cos(angle_rad)) * radius * 0.6
		var z = base_position.z + i * card_z_step

		card.base_position = Vector3(x, y, z)
		card.set_card_data(hand[i])
		card.play_deal_in(deck_origin, Vector3(0, 0, -angle_deg), i * deal_stagger, deal_duration)

		cards.append(card)
	
func _unhandled_input(event: InputEvent) -> void:
	if is_inspecting:
		_handle_inspect_input(event)
		return

	if input_locked or cards.is_empty():
		return

	if event.is_action_pressed("card_left"):
		current_index = wrapi(current_index - 1, 0, cards.size())
		_update_selection_visual()
	elif event.is_action_pressed("card_right"):
		current_index = wrapi(current_index + 1, 0, cards.size())
		_update_selection_visual()
	elif event.is_action_pressed("card_confirm"):
		_play_selected_card()
	elif event.is_action_pressed("card_inspect"):
		_start_inspect()


func _handle_inspect_input(event: InputEvent) -> void:
	if inspect_locked:
		return

	if event is InputEventMouseMotion:
		inspect_pitch = clampf(inspect_pitch - event.relative.y * inspect_rotate_speed * 0.1, -inspect_max_pitch, inspect_max_pitch)
		inspect_yaw = clampf(inspect_yaw + event.relative.x * inspect_rotate_speed * 0.1, -inspect_max_yaw, inspect_max_yaw)
		inspected_card.rotation_degrees = Vector3(inspect_pitch, inspect_yaw, 0)
	elif event.is_action_pressed("card_inspect"):
		_end_inspect()
	elif event.is_action_pressed("card_confirm"):
		_confirm_while_inspecting()

func _is_severe_dislike(card: CardData, question: QuestionData) -> bool:
	if question == null:
		return false
	if not (card.tag in question.dislikes):
		return false
	return abs(card.trust_effect) >= severe_threshold or abs(card.trauma_effect) >= severe_threshold
	

func _update_selection_visual() -> void:
	if cards.is_empty():
		return
	if current_index >= cards.size():
		current_index = cards.size() - 1
	for i in range(cards.size()):
		cards[i].set_current(i == current_index)


func _start_inspect() -> void:
	if cards.is_empty():
		return
	inspect_pitch = 0.0
	inspect_yaw = 0.0
	is_inspecting = true
	inspect_locked = true
	inspected_card = cards[current_index]
	inspected_original_position = inspected_card.position
	inspected_original_rotation = inspected_card.rotation_degrees

	inspected_card.set_inspected(true)
	player_head.set_input_enabled(false)
	
	if _is_severe_dislike(inspected_card.card_data, current_question):
		danger_overlay.show_danger()

	if npc_walk_controller:
		npc_walk_controller.hide_bubble()

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(inspected_card, "position", inspect_position, inspect_duration)
	tween.tween_property(inspected_card, "scale", Vector3.ONE * inspect_scale, inspect_duration)
	tween.tween_property(inspected_card, "rotation_degrees", Vector3.ZERO, inspect_duration)
	await tween.finished

	inspect_locked = false


func _end_inspect() -> void:
	is_inspecting = false
	inspect_locked = true
	player_head.set_input_enabled(true)
	danger_overlay.hide_danger()

	var card_to_reset := inspected_card
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(card_to_reset, "position", inspected_original_position, inspect_duration)
	tween.tween_property(card_to_reset, "scale", Vector3.ONE, inspect_duration)
	tween.tween_property(card_to_reset, "rotation_degrees", inspected_original_rotation, inspect_duration)
	await tween.finished

	card_to_reset.set_inspected(false)
	inspected_card = null
	inspect_locked = false

	if npc_walk_controller:
		npc_walk_controller.show_bubble()

func _confirm_while_inspecting() -> void:
	is_inspecting = false
	danger_overlay.hide_danger()

	var card := inspected_card
	card.set_inspected(false)
	card.scale = Vector3.ONE
	card.rotation_degrees = inspected_original_rotation
	card.position = inspected_original_position
	inspected_card = null

	_play_selected_card()

func _play_selected_card() -> void:
	if cards.is_empty():
		return
	input_locked = true
	player_head.set_input_enabled(false)

	var thrown_card: Node3D = cards[current_index]
	cards.remove_at(current_index)

	player_head.look_at_target(npc_throw_target.global_position, 0.4)
	await _animate_throw(thrown_card)
	var played_data: CardData = thrown_card.card_data
	thrown_card.queue_free()

	await player_head.restore_look(0.4)

	GameManager.choose_card(played_data)


func _animate_throw(card: Node3D) -> void:

	var grab_tween := create_tween()
	grab_tween.set_parallel(true)
	grab_tween.tween_property(right_hand, "position", card.position, 0.2)
	grab_tween.tween_property(right_hand, "rotation_degrees", grab_rotation, grab_rotation_duration)
	await grab_tween.finished

	card.reparent(world_root, true)
	card.rotation_degrees = Vector3(90, card.rotation_degrees.y, 0)

	var start: Vector3 = right_hand.global_position
	var end: Vector3 = npc_throw_target.global_position

	var t: float = 0.0
	while t < 1.0:
		t = min(t + get_process_delta_time() / throw_duration, 1.0)
		var pos: Vector3 = start.lerp(end, t)
		pos.y += sin(t * PI) * throw_arc_height
		card.global_position = pos
		card.rotation_degrees = Vector3(90, throw_spin_degrees * t, 0)
		await get_tree().process_frame

	var return_tween := create_tween()
	return_tween.set_parallel(true)
	return_tween.tween_property(right_hand, "position", right_hand.rest_position, 0.25)
	return_tween.tween_property(right_hand, "rotation_degrees", Vector3.ZERO, 0.25)
	await return_tween.finished
