extends Control

@export var initial_float_distance: float = 40.0
@export var initial_duration: float = 0.3
@export var travel_duration: float = 0.5
@export var fade_out_duration: float = 0.2

@onready var icon_rect: TextureRect = $HBox/Icon
@onready var value_text: Label = $HBox/ValueText


func setup(icon: Texture2D, text: String, color: Color, target_pos: Vector2) -> void:
	icon_rect.texture = icon
	value_text.text = text
	value_text.add_theme_color_override("font_color", color)

	modulate.a = 0.0
	var start_pos := position

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.15)
	tween.parallel().tween_property(self, "position:y", start_pos.y - initial_float_distance, initial_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "position", target_pos, travel_duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	tween.tween_property(self, "modulate:a", 0.0, fade_out_duration)
	tween.tween_callback(queue_free)
