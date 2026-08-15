extends Node3D

@export var crowd_count: int = 40
@export var ring_radius_min: float = 4.5
@export var ring_radius_max: float = 6.5
@export var min_scale: float = 0.75
@export var max_scale: float = 1.15
@export var sprite_variants: int = 6
@export var placeholder_size_px: Vector2i = Vector2i(300, 700)
@export var silhouette_color: Color = Color(0.05, 0.05, 0.08, 1.0)
@export var idle_bob_amount: float = 0.02
@export var idle_bob_speed_min: float = 0.6
@export var idle_bob_speed_max: float = 1.4
@export var angle_range_degrees: float = 340.0

const CrowdMemberScene = preload("res://scenes/CrowdMember.tscn")

var _placeholder_cache: Dictionary = {}


func _ready() -> void:
	_spawn_crowd()


func _spawn_crowd() -> void:
	for i in range(crowd_count):
		var member = CrowdMemberScene.instantiate()
		add_child(member)

		var angle: float = deg_to_rad(randf_range(-angle_range_degrees / 2.0, angle_range_degrees / 2.0) - 90.0)
		var radius: float = randf_range(ring_radius_min, ring_radius_max)
		var x: float = cos(angle) * radius
		var z: float = sin(angle) * radius
		member.position = Vector3(x, 0, z)

		var s: float = randf_range(min_scale, max_scale)
		member.setup(
			_get_variant_texture(randi() % sprite_variants),
			s,
			idle_bob_amount,
			randf_range(idle_bob_speed_min, idle_bob_speed_max)
		)


func _get_variant_texture(variant_index: int) -> Texture2D:
	var path := "res://assets/crowd/crowd_%d.png" % variant_index
	if ResourceLoader.exists(path):
		return load(path)

	if not _placeholder_cache.has(variant_index):
		_placeholder_cache[variant_index] = PlaceholderTexture.make(silhouette_color, placeholder_size_px)
	return _placeholder_cache[variant_index]
