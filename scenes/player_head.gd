extends Node3D

@export var mouse_sensitivity: float = 0.15
@export var max_yaw_degrees: float = 35.0
@export var max_pitch_degrees: float = 20.0
@export var default_fov: float = 75.0
@export var zoom_fov: float = 50.0

var yaw: float = 0.0
var pitch: float = 0.0
var input_enabled: bool = true

var stored_yaw: float = 0.0
var stored_pitch: float = 0.0

@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.fov = default_fov


func _input(event: InputEvent) -> void:
	if not input_enabled:
		return

	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		yaw = clampf(yaw, -max_yaw_degrees, max_yaw_degrees)
		pitch = clampf(pitch, -max_pitch_degrees, max_pitch_degrees)
		rotation_degrees = Vector3(pitch, yaw, 0)

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled


func look_at_target(target_global_pos: Vector3, duration: float) -> void:
	stored_yaw = yaw
	stored_pitch = pitch

	var dir: Vector3 = target_global_pos - global_position
	var look_basis: Basis = Basis.looking_at(dir, Vector3.UP)
	var euler: Vector3 = look_basis.get_euler()
	var target_pitch: float = rad_to_deg(euler.x)
	var target_yaw: float = rad_to_deg(euler.y)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "rotation_degrees:x", target_pitch, duration)
	tween.tween_property(self, "rotation_degrees:y", target_yaw, duration)
	tween.tween_property(camera, "fov", zoom_fov, duration)
	await tween.finished

	pitch = target_pitch
	yaw = target_yaw


func restore_look(duration: float) -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "rotation_degrees:x", stored_pitch, duration)
	tween.tween_property(self, "rotation_degrees:y", stored_yaw, duration)
	tween.tween_property(camera, "fov", default_fov, duration)
	await tween.finished

	pitch = stored_pitch
	yaw = stored_yaw
	input_enabled = true
