extends Node3D

@export var entry_marker_path: NodePath
@export var exit_marker_path: NodePath
@export var stage_marker_path: NodePath
@export var walker_a_path: NodePath
@export var walker_b_path: NodePath
@export var speech_bubble_path: NodePath

@export var walk_duration: float = 0.8
@export var jiggle_amplitude: float = 0.03
@export var jiggle_speed: float = 4.0

@onready var entry_marker: Marker3D = get_node(entry_marker_path)
@onready var exit_marker: Marker3D = get_node(exit_marker_path)
@onready var stage_marker: Marker3D = get_node(stage_marker_path)
@onready var walker_a: NPCWalker = get_node(walker_a_path)
@onready var walker_b: NPCWalker = get_node(walker_b_path)
@onready var speech_bubble: Control = get_node(speech_bubble_path)

var active_walker: NPCWalker
var idle_walker: NPCWalker


func _ready() -> void:
	active_walker = walker_a
	idle_walker = walker_b
	walker_a.global_position = exit_marker.global_position
	walker_b.global_position = exit_marker.global_position


func transition_to(sprite_id: String) -> void:
	var outgoing: NPCWalker = active_walker
	var incoming: NPCWalker = idle_walker

	incoming.place_at(entry_marker.global_position, sprite_id)

	var out_call = outgoing.walk_to(exit_marker.global_position, walk_duration, jiggle_amplitude, jiggle_speed)
	var in_call = incoming.walk_to(stage_marker.global_position, walk_duration, jiggle_amplitude, jiggle_speed)
	await out_call
	await in_call

	incoming.sprite.set_expression("idle")
	speech_bubble.set_world_anchor(incoming.speech_anchor)

	active_walker = incoming
	idle_walker = outgoing


func show_new_question(npc_name: String, question_text: String) -> void:
	speech_bubble.show_question(npc_name, question_text)


func show_reaction(text: String, category: String) -> void:
	active_walker.sprite.set_expression(category)
	speech_bubble.show_question(speech_bubble.name_text.text, text)


func hide_bubble() -> void:
	speech_bubble.hide_question()


func show_bubble() -> void:
	speech_bubble.show_question(speech_bubble.name_text.text, speech_bubble.question_text.text)
