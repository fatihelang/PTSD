extends Node3D

@onready var sprite: Sprite3D = $Sprite

var bob_amount: float = 0.02
var bob_speed: float = 1.0
var bob_offset: float = 0.0
var base_y: float = 0.0


func setup(texture: Texture2D, member_scale: float, amount: float, speed: float) -> void:
	sprite.texture = texture
	scale = Vector3.ONE * member_scale
	bob_amount = amount
	bob_speed = speed
	bob_offset = randf() * TAU
	base_y = position.y


func _process(_delta: float) -> void:
	var t: float = Time.get_ticks_msec() / 1000.0 * bob_speed + bob_offset
	position.y = base_y + sin(t) * bob_amount
