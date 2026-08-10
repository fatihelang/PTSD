extends Sprite3D

@export var placeholder_size_px: Vector2i = Vector2i(512, 822)
@export var squash_amount: float = 0.22
@export var squash_duration: float = 0.35
@export var idle_breathe_amount: float = 0.025
@export var idle_breathe_speed: float = 1.8
@export var flash_color: Color = Color(1.5, 1.5, 1.5)
@export var flash_duration: float = 0.12

var sprite_id: String = ""
var base_scale: Vector3 = Vector3.ONE
var idle_time: float = 0.0
var current_category: String = "idle"
var is_squashing: bool = false
var _placeholder_cache: Dictionary = {}


func _ready() -> void:
	base_scale = scale


func set_sprite_id(id: String) -> void:
	sprite_id = id


func set_expression(category: String) -> void:
	texture = _get_texture_for(category)
	current_category = category
	_play_flash()
	_play_squash()
	


func _play_squash() -> void:
	is_squashing = true
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3(base_scale.x * (1.0 + squash_amount), base_scale.y * (1.0 - squash_amount), base_scale.z), squash_duration * 0.3)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", base_scale, squash_duration * 0.7)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func(): is_squashing = false, CONNECT_ONE_SHOT)


func _play_flash() -> void:
	modulate = flash_color
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, flash_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	if current_category == "idle" and not is_squashing:
		idle_time += delta * idle_breathe_speed
		var breathe: float = 1.0 + sin(idle_time) * idle_breathe_amount
		scale = Vector3(base_scale.x, base_scale.y * breathe, base_scale.z)


func _get_texture_for(category: String) -> Texture2D:
	if sprite_id.strip_edges() != "":
		var path := "res://assets/npc/%s_%s.png" % [sprite_id, category]
		if ResourceLoader.exists(path):
			return load(path)
	var fallback_color := _fallback_color_for(category)
	if not _placeholder_cache.has(sprite_id + category):
		_placeholder_cache[sprite_id + category] = PlaceholderTexture.make(fallback_color, placeholder_size_px)
	return _placeholder_cache[sprite_id + category]


func _fallback_color_for(category: String) -> Color:
	match category:
		"idle": return Color(0.6, 0.6, 0.65)
		"like": return Color(0.3, 0.8, 0.4)
		"dislike": return Color(0.85, 0.3, 0.3)
		"neutral": return Color(0.9, 0.75, 0.2)
		"belittled": return Color(0.5, 0.2, 0.6)
		_: return Color(1, 1, 1)
