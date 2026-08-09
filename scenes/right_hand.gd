extends Node3D

@export var rest_position: Vector3 = Vector3(0.25, -0.3, -0.6)
@export var fade_duration: float = 0.15

@onready var hand_sprite: Sprite3D = $HandSprite


func _ready() -> void:
	position = rest_position
	hand_sprite.modulate.a = 0.0


func fade_in() -> void:
	var tween := create_tween()
	tween.tween_property(hand_sprite, "modulate:a", 1.0, fade_duration)


func fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(hand_sprite, "modulate:a", 0.0, fade_duration)
