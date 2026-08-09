extends PanelContainer

@export var slide_distance: float = 400.0
@export var slide_duration: float = 0.18

@onready var card_text: Label = $ContentVBox/CardText
@onready var card_art: TextureRect = $ContentVBox/CardArt

var rest_position: Vector2
var is_animating: bool = false
var pending_data: CardData = null


func _ready() -> void:
	rest_position = position
	visible = false


func show_card(data: CardData) -> void:
	if not visible:
		_apply_data(data)
		visible = true
		position = rest_position - Vector2(slide_distance, 0)
		modulate.a = 0.0

		await get_tree().process_frame
		reset_size()

		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "position", rest_position, slide_duration)
		tween.tween_property(self, "modulate:a", 1.0, slide_duration)
	else:
		pending_data = data
		if not is_animating:
			_slide_out_then_in()


func _slide_out_then_in() -> void:
	is_animating = true

	var out_tween := create_tween()
	out_tween.set_parallel(true)
	out_tween.tween_property(self, "position", rest_position - Vector2(slide_distance, 0), slide_duration)
	out_tween.tween_property(self, "modulate:a", 0.0, slide_duration)
	await out_tween.finished

	if pending_data:
		_apply_data(pending_data)
		pending_data = null

	await get_tree().process_frame
	reset_size()

	position = rest_position - Vector2(slide_distance, 0)

	var in_tween := create_tween()
	in_tween.set_parallel(true)
	in_tween.tween_property(self, "position", rest_position, slide_duration)
	in_tween.tween_property(self, "modulate:a", 1.0, slide_duration)
	await in_tween.finished

	is_animating = false


func _apply_data(data: CardData) -> void:
	card_text.text = data.card_name
	if data.card_art:
		card_art.texture = data.card_art
		card_art.visible = true
	else:
		card_art.visible = false


func hide_display() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", rest_position - Vector2(slide_distance, 0), slide_duration)
	tween.tween_property(self, "modulate:a", 0.0, slide_duration)
	tween.chain().tween_callback(func(): visible = false)
