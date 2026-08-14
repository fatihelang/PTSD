extends Control

const FloatingNumberScene = preload("res://scenes/FloatingNumber.tscn")

@export var world_anchor_path: NodePath
@export var camera_path: NodePath
<<<<<<< HEAD
@export var stat_bars_path: NodePath
@export var bar_target_offset: Vector2 = Vector2(240, 20)
=======
>>>>>>> parent of 8dfa8bc (a)
@export var stack_gap: float = 30.0
@export var spawn_vertical_gap: float = 40.0

@onready var world_anchor: Node3D = get_node(world_anchor_path)
@onready var camera: Camera3D = get_node(camera_path)
<<<<<<< HEAD
@onready var stat_bars: Control = get_node(stat_bars_path)
=======
>>>>>>> parent of 8dfa8bc (a)


func spawn_deltas(trust_delta: int, trauma_delta: int) -> void:
	if world_anchor == null or camera == null:
		return
<<<<<<< HEAD

	var base_spawn_pos: Vector2 = camera.unproject_position(world_anchor.global_position)
	var bar_target: Vector2 = stat_bars.global_position + bar_target_offset

	if trust_delta != 0:
		var spawn_pos := base_spawn_pos + Vector2(0, -spawn_vertical_gap / 2.0)
		_spawn_one(spawn_pos, bar_target, "Kepercayaan %+d" % trust_delta, trust_delta > 0)
		bar_target.y += stack_gap

	if trauma_delta != 0:
		var spawn_pos := base_spawn_pos + Vector2(0, spawn_vertical_gap / 2.0)
		_spawn_one(spawn_pos, bar_target, "Trauma %+d" % trauma_delta, trauma_delta < 0)


func _spawn_one(spawn_pos: Vector2, target_pos: Vector2, text: String, is_favorable: bool) -> void:
	var fn = FloatingNumberScene.instantiate()
	add_child(fn)
	fn.position = spawn_pos
	var color := Color(0.4, 1.0, 0.4) if is_favorable else Color(1.0, 0.4, 0.4)
	fn.setup(text, color, target_pos)
=======

	var screen_pos: Vector2 = camera.unproject_position(world_anchor.global_position)

	if trauma_delta != 0:
		_spawn_one(screen_pos, "Trauma %+d" % trauma_delta, trauma_delta > 0)
		screen_pos.y -= stack_gap
		
	if trust_delta != 0:
		_spawn_one(screen_pos, "Kepercayaan %+d" % trust_delta, trust_delta > 0)
		

	


func _spawn_one(screen_pos: Vector2, text: String, is_positive: bool) -> void:
	var fn = FloatingNumberScene.instantiate()
	add_child(fn)
	fn.position = screen_pos
	var color := Color(0.4, 1.0, 0.4) if is_positive else Color(1.0, 0.4, 0.4)
	fn.setup(text, color)
>>>>>>> parent of 8dfa8bc (a)
