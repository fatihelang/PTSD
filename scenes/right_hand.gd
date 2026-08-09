extends Node3D

@export var rest_position: Vector3 = Vector3(0.25, -0.3, -0.6)


func _ready() -> void:
	position = rest_position
