extends Sprite3D

@export var idle_texture: Texture2D
@export var like_texture: Texture2D
@export var dislike_texture: Texture2D
@export var neutral_texture: Texture2D
@export var belittled_texture: Texture2D

var _placeholder_cache: Dictionary = {}


func _ready() -> void:
	set_expression("idle")


func set_expression(category: String) -> void:
	var tex: Texture2D = _get_texture_for(category)
	texture = tex


func _get_texture_for(category: String) -> Texture2D:
	var assigned: Texture2D = null
	var fallback_color: Color

	match category:
		"idle":
			assigned = idle_texture
			fallback_color = Color(0.6, 0.6, 0.65)
		"like":
			assigned = like_texture
			fallback_color = Color(0.3, 0.8, 0.4)
		"dislike":
			assigned = dislike_texture
			fallback_color = Color(0.85, 0.3, 0.3)
		"neutral":
			assigned = neutral_texture
			fallback_color = Color(0.9, 0.75, 0.2)
		"belittled":
			assigned = belittled_texture
			fallback_color = Color(0.5, 0.2, 0.6)
		_:
			fallback_color = Color(1, 1, 1)

	if assigned:
		return assigned

	if not _placeholder_cache.has(category):
		_placeholder_cache[category] = PlaceholderTexture.make(fallback_color)
	return _placeholder_cache[category]
