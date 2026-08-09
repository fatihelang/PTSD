extends PanelContainer

@export var horizontal_offset: float = 180.0
@export var screen_margin: float = 16.0
@export var fade_duration: float = 0.2

@onready var text_label: Label = $InspectVBox/InspectText

var fade_tween: Tween


func _ready() -> void:
	visible = false
	modulate.a = 0.0


func show_info(data: CardData) -> void:
	var effect_text := "Trust %+d | Trauma %+d" % [data.trust_effect, data.trauma_effect]
	var tag_text := "Tag: %s" % (data.tag if data.tag != "" else "-")
	text_label.text = "%s\n%s\n%s" % [data.card_name, tag_text, effect_text]
	visible = true

	await get_tree().process_frame
	reset_size()
	_reposition()

	_fade_to(1.0)


func _reposition() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size

	var target_x: float = viewport_size.x / 2.0 - horizontal_offset - size.x
	var target_y: float = viewport_size.y / 2.0 - size.y / 2.0

	target_x = clampf(target_x, screen_margin, viewport_size.x - size.x - screen_margin)
	target_y = clampf(target_y, screen_margin, viewport_size.y - size.y - screen_margin)

	position = Vector2(target_x, target_y)


func hide_info() -> void:
	_fade_to(0.0)


func _fade_to(target: float) -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", target, fade_duration)
	if target <= 0.0:
		fade_tween.finished.connect(
			func(): visible = false,
			CONNECT_ONE_SHOT
		)
