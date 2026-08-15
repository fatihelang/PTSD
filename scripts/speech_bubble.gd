extends Control
#speech buble
@export var camera_path: NodePath
@export var extra_lift: float = 20.0
@export var fade_duration: float = 0.25
@export var char_delay: float = 0.025

@onready var camera: Camera3D = get_node(camera_path)
@onready var bubble: PanelContainer = $Bubble
@onready var name_text: Label = $Bubble/BubbleVBox/NameText
@onready var question_text: Label = $Bubble/BubbleVBox/QuestionText
@onready var type_sfx: AudioStreamPlayer = $TypeSfx

var world_anchor: Node3D = null
var manual_alpha: float = 0.0
var fade_tween: Tween

var is_typing: bool = false
var skip_requested: bool = false


func _ready() -> void:
	bubble.visible = false
	bubble.modulate.a = 0.0


func set_world_anchor(node: Node3D) -> void:
	world_anchor = node


func type_text(npc_name: String, full_text: String) -> void:
	name_text.text = npc_name
	question_text.text = ""
	bubble.visible = true
	_fade_to(1.0)

	is_typing = true
	skip_requested = false

	# Mulai sound typing
	if type_sfx.stream:
		type_sfx.play()

	for i in range(full_text.length()):
		if skip_requested:
			break

		question_text.text += full_text[i]

		await get_tree().create_timer(char_delay).timeout

	# Pastikan seluruh text muncul
	question_text.text = full_text

	# Stop sound setelah typing selesai
	type_sfx.stop()

	is_typing = false


func skip_typing() -> void:
	if is_typing:
		skip_requested = true


func hide_question() -> void:
	_fade_to(0.0)


func _fade_to(target: float) -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(self, "manual_alpha", target, fade_duration)
	if target <= 0.0:
		fade_tween.finished.connect(
			func(): bubble.visible = false,
			CONNECT_ONE_SHOT
		)


func _unhandled_input(event: InputEvent) -> void:
	if is_typing and event.is_action_pressed("card_confirm"):
		skip_typing()


func _process(_delta: float) -> void:
	if not bubble.visible or world_anchor == null or camera == null:
		return
	var world_pos: Vector3 = world_anchor.global_position
	var cam_local: Vector3 = camera.global_transform.affine_inverse() * world_pos
	var camera_alpha: float = 0.0 if cam_local.z > 0 else 1.0
	bubble.modulate.a = camera_alpha * manual_alpha
	var screen_pos: Vector2 = camera.unproject_position(world_pos)
	bubble.position = Vector2(
		screen_pos.x - bubble.size.x / 2.0,
		screen_pos.y - bubble.size.y - extra_lift
	)
