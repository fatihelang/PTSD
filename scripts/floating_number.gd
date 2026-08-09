extends Control

@export var float_distance: float = 60.0
@export var duration: float = 1.0

@onready var value_text: Label = $ValueText


func setup(text: String, color: Color) -> void:
	value_text.text = text
	value_text.add_theme_color_override("font_color", color)

	modulate.a = 0.0
	var start_pos := position

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, duration * 0.2)
	tween.tween_property(self, "position:y", start_pos.y - float_distance, duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(self, "modulate:a", 0.0, duration * 0.3)
	tween.chain().tween_callback(queue_free)
