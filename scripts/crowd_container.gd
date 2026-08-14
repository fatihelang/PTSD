extends Node3D

@export var crowd_count: int = 30
@export var area_width: float = 8.0
@export var area_depth: float = 2.5
@export var min_scale: float = 0.7
@export var max_scale: float = 1.1
@export var sprite_variants: int = 6
@export var placeholder_size_px: Vector2i = Vector2i(300, 700)
@export var idle_bob_amount: float = 0.02
@export var idle_bob_speed_min: float = 0.6
@export var idle_bob_speed_max: float = 1.4

const CrowdMemberScene = preload("res://scenes/CrowdMember.tscn")

var _placeholder_cache: Dictionary = {}


func _ready() -> void:
	_spawn_crowd()


func _spawn_crowd() -> void:
	for i in range(crowd_count):
		var member = CrowdMemberScene.instantiate()
		add_child(member)

		var x: float = randf_range(-area_width / 2.0, area_width / 2.0)
		var z: float = randf_range(-area_depth, 0.0)
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
		var hue: float = float(variant_index) / float(max(sprite_variants, 1))
		var color: Color = Color.from_hsv(hue, 0.35, 0.55)
		_placeholder_cache[variant_index] = PlaceholderTexture.make(color, placeholder_size_px)
	return _placeholder_cache[variant_index]
