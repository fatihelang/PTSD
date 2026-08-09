extends Sprite3D

@export var hand_texture: Texture2D

@export var placeholder_size_px: Vector2i = Vector2i(64, 80)


func _ready() -> void:
	
	if hand_texture:
		texture = hand_texture
	
