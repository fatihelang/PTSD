extends Control

const FloatingNumberScene = preload("res://scenes/FloatingNumber.tscn")

@export var world_anchor_path: NodePath
@export var camera_path: NodePath
@export var stack_gap: float = 30.0

@onready var world_anchor: Node3D = get_node(world_anchor_path)
@onready var camera: Camera3D = get_node(camera_path)


func spawn_deltas(trust_delta: int, trauma_delta: int) -> void:
	if world_anchor == null or camera == null:
		return

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
