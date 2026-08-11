extends Node3D
class_name NPCWalker

@onready var sprite: Sprite3D = $NPCSprite
@onready var speech_anchor: Marker3D = $SpeechAnchor


func place_at(pos: Vector3, sprite_id: String) -> void:
	visible = true
	scale = Vector3.ONE
	global_position = pos
	sprite.set_sprite_id(sprite_id)
	sprite.texture = sprite._get_texture_for("idle")
	sprite.current_category = "idle"


func walk_to(target_pos: Vector3, duration: float, jiggle_amp: float, jiggle_speed: float, vanish_on_arrival: bool = false) -> void:
	var start: Vector3 = global_position
	var t: float = 0.0
	while t < 1.0:
		t = min(t + get_process_delta_time() / duration, 1.0)
		var pos: Vector3 = start.lerp(target_pos, t)
		pos.y += sin(t * TAU * jiggle_speed) * jiggle_amp
		global_position = pos
		rotation_degrees.z = sin(t * TAU * jiggle_speed) * 5.0
		await get_tree().process_frame
	global_position = target_pos
	rotation_degrees.z = 0.0

	if vanish_on_arrival:
		await _play_vanish()


func _play_vanish() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await tween.finished
	visible = false
