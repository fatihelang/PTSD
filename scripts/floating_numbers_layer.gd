extends Control

const FloatingNumberScene = preload("res://scenes/FloatingNumber.tscn")

@export var stat_bars_path: NodePath
@export var spawn_offset: Vector2 = Vector2(240, 20)
@export var stack_gap: float = 30.0

@onready var stat_bars: Control = get_node(stat_bars_path)


func spawn_deltas(trust_delta: int, trauma_delta: int) -> void:
	var origin: Vector2 = stat_bars.global_position + spawn_offset

	if trust_delta != 0:
		_spawn_one(origin, "Kepercayaan %+d" % trust_delta, trust_delta > 0)
		origin.y += stack_gap

	if trauma_delta != 0:
		_spawn_one(origin, "Trauma %+d" % trauma_delta, trauma_delta < 0)


func _spawn_one(pos: Vector2, text: String, is_favorable: bool) -> void:
	var fn = FloatingNumberScene.instantiate()
	add_child(fn)
	fn.position = pos
	var color := Color(0.4, 1.0, 0.4) if is_favorable else Color(1.0, 0.4, 0.4)
	fn.setup(text, color)
