extends TextureRect

@export var custom_texture: Texture2D
@export var max_alpha: float = 0.55
@export var fade_duration: float = 0.3
@export var pulse_amount: float = 0.12
@export var pulse_speed: float = 2.0

var tween: Tween
var pulse_tween: Tween
var is_active: bool = false


func _ready() -> void:
	modulate.a = 0.0
	texture = custom_texture if custom_texture else _make_vignette_placeholder()


func show_danger() -> void:
	is_active = true
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", max_alpha, fade_duration)
	tween.finished.connect(_start_pulse, CONNECT_ONE_SHOT)


func hide_danger() -> void:
	is_active = false
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)


func _start_pulse() -> void:
	if not is_active:
		return
	pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(self, "modulate:a", max_alpha + pulse_amount, pulse_speed * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(self, "modulate:a", max_alpha - pulse_amount, pulse_speed * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _make_vignette_placeholder() -> ImageTexture:
	var tex_size := 512
	var img := Image.create(tex_size, tex_size, false, Image.FORMAT_RGBA8)
	var center := Vector2(tex_size / 2.0, tex_size / 2.0)
	var max_dist := center.length()

	for y in range(tex_size):
		for x in range(tex_size):
			var dist_ratio: float = Vector2(x, y).distance_to(center) / max_dist
			var a: float = clampf((dist_ratio - 0.35) / 0.65, 0.0, 1.0)
			img.set_pixel(x, y, Color(0.55, 0.05, 0.05, a))

	return ImageTexture.create_from_image(img)
