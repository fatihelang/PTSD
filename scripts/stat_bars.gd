extends Control

@export var animate_duration: float = 0.35

@onready var trust_bar: ProgressBar = $BarsVBox/TrustBar
@onready var rep_bar: ProgressBar = $BarsVBox/RepBar


func set_stats(trust: int, trauma: int, animate: bool = true) -> void:
	if animate:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(trust_bar, "value", float(trust), animate_duration)
		tween.tween_property(rep_bar, "value", float(trauma), animate_duration)
	else:
		trust_bar.value = trust
		rep_bar.value = trauma
