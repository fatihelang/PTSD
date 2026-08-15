extends Node3D

@export var entry_marker_path: NodePath
@export var exit_marker_path: NodePath
@export var stage_marker_path: NodePath
@export var walker_a_path: NodePath
@export var walker_b_path: NodePath
@export var speech_bubble_path: NodePath
@export var player_head_path: NodePath

@export var walk_duration: float = 0.8
@export var jiggle_amplitude: float = 0.03
@export var jiggle_speed: float = 4.0

@export var zoom_duration: float = 0.4
@export var post_type_pause: float = 0.3

@onready var entry_marker: Marker3D = get_node(entry_marker_path)
@onready var exit_marker: Marker3D = get_node(exit_marker_path)
@onready var stage_marker: Marker3D = get_node(stage_marker_path)
@onready var walker_a: NPCWalker = get_node(walker_a_path)
@onready var walker_b: NPCWalker = get_node(walker_b_path)
@onready var speech_bubble: Control = get_node(speech_bubble_path)
@onready var player_head: Node3D = get_node(player_head_path)

var active_walker: NPCWalker
var idle_walker: NPCWalker


func _ready() -> void:
	active_walker = walker_a
	idle_walker = walker_b
	walker_a.visible = false
	walker_b.visible = false
	walker_a.global_position = exit_marker.global_position
	walker_b.global_position = exit_marker.global_position


func transition_to(sprite_id: String) -> void:
	var outgoing: NPCWalker = active_walker
	var incoming: NPCWalker = idle_walker

	hide_bubble()

	incoming.place_at(entry_marker.global_position, sprite_id)

	outgoing.walk_to(exit_marker.global_position, walk_duration, jiggle_amplitude, jiggle_speed, true)
	await incoming.walk_to(stage_marker.global_position, walk_duration, jiggle_amplitude, jiggle_speed, false)

	incoming.sprite.set_expression("idle")
	speech_bubble.set_world_anchor(incoming.speech_anchor)

	active_walker = incoming
	idle_walker = outgoing


func show_new_question(npc_name: String, question_text: String) -> void:
	await _zoom_and_type(npc_name, question_text)


func show_reaction(text: String, category: String) -> void:
	active_walker.sprite.set_expression(category)
	await _zoom_and_type(speech_bubble.name_text.text, text)


func _zoom_and_type(npc_name: String, text: String) -> void:
	player_head.set_input_enabled(false)
	player_head.look_at_target(active_walker.speech_anchor.global_position, zoom_duration)

	await speech_bubble.type_text(npc_name, text)
	await get_tree().create_timer(post_type_pause).timeout

	await player_head.restore_look(zoom_duration)
	player_head.set_input_enabled(true)


func hide_bubble() -> void:
	speech_bubble.hide_question()


func show_bubble() -> void:
	speech_bubble.type_text(speech_bubble.name_text.text, speech_bubble.question_text.text)
