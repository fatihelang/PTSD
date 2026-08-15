extends Control

const FloatingNumberScene = preload("res://scenes/FloatingNumber.tscn")

@export var world_anchor_path: NodePath
@export var camera_path: NodePath
@export var stat_bars_path: NodePath
@export var bar_target_offset: Vector2 = Vector2(240, 20)
@export var stack_gap: float = 30.0
@export var spawn_vertical_gap: float = 40.0
@export var icon_trust: Texture2D
@export var icon_trauma: Texture2D

@onready var world_anchor: Node3D = get_node(world_anchor_path)
@onready var camera: Camera3D = get_node(camera_path)
@onready var stat_bars: Control = get_node(stat_bars_path)


func spawn_deltas(trust_delta: int, trauma_delta: int) -> void:
	if world_anchor == null or camera == null:
		return

	var base_spawn_pos: Vector2 = camera.unproject_position(world_anchor.global_position)
	var bar_target: Vector2 = stat_bars.global_position + bar_target_offset

	if trust_delta != 0:
		var spawn_pos := base_spawn_pos + Vector2(0, -spawn_vertical_gap / 2.0)
		_spawn_one(spawn_pos, bar_target, icon_trust, "%+d" % trust_delta, trust_delta > 0)
		bar_target.y += stack_gap

	if trauma_delta != 0:
		var spawn_pos := base_spawn_pos + Vector2(0, spawn_vertical_gap / 2.0)
		_spawn_one(spawn_pos, bar_target, icon_trauma, "%+d" % trauma_delta, trauma_delta < 0)


func _spawn_one(spawn_pos: Vector2, target_pos: Vector2, icon: Texture2D, text: String, is_favorable: bool) -> void:
	var fn = FloatingNumberScene.instantiate()
	add_child(fn)
	fn.position = spawn_pos
	var color := Color(0.4, 1.0, 0.4) if is_favorable else Color(1.0, 0.4, 0.4)
	fn.setup(icon, text, color, target_pos)
