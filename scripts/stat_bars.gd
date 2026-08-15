extends Control

@export var icon_trust: Texture2D
@export var icon_trauma: Texture2D
@export var animate_duration: float = 0.35

@onready var trust_icon: TextureRect = $BarsVBox/TrustRow/TrustIcon
@onready var trust_value: Label = $BarsVBox/TrustRow/TrustValue
@onready var trauma_icon: TextureRect = $BarsVBox/TraumaRow/TraumaIcon
@onready var trauma_value: Label = $BarsVBox/TraumaRow/TraumaValue

var displayed_trust: float = 50.0
var displayed_trauma: float = 50.0


func _ready() -> void:
	if icon_trust:
		trust_icon.texture = icon_trust
	if icon_trauma:
		trauma_icon.texture = icon_trauma
	trust_value.text = str(int(displayed_trust))
	trauma_value.text = str(int(displayed_trauma))


func set_stats(trust: int, trauma: int, animate: bool = true) -> void:
	if not animate:
		displayed_trust = trust
		displayed_trauma = trauma
		trust_value.text = str(trust)
		trauma_value.text = str(trauma)
		return

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_method(_set_trust_label, displayed_trust, float(trust), animate_duration)
	tween.tween_method(_set_trauma_label, displayed_trauma, float(trauma), animate_duration)
	displayed_trust = trust
	displayed_trauma = trauma


func _set_trust_label(v: float) -> void:
	trust_value.text = str(int(round(v)))


func _set_trauma_label(v: float) -> void:
	trauma_value.text = str(int(round(v)))
