extends Control
#speech buble
@export var camera_path: NodePath
@export var extra_lift: float = 20.0
@export var fade_duration: float = 0.25
@onready var camera: Camera3D = get_node(camera_path)
@onready var bubble: PanelContainer = $Bubble
@onready var name_text: Label = $Bubble/BubbleVBox/NameText
@onready var question_text: Label = $Bubble/BubbleVBox/QuestionText

var world_anchor: Node3D = null
var manual_alpha: float = 0.0
var fade_tween: Tween


func _ready() -> void:
	bubble.visible = false
	bubble.modulate.a = 0.0


func set_world_anchor(node: Node3D) -> void:
	world_anchor = node


func show_question(npc_name: String, text: String) -> void:
	name_text.text = npc_name
	question_text.text = text
	bubble.visible = true
	_fade_to(1.0)


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
