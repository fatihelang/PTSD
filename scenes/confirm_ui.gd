extends Control

signal confirmed
signal cancelled

@onready var pakai_button: Button = $ButtonRow/PakaiButton
@onready var batal_button: Button = $ButtonRow/BatalButton


func _ready() -> void:
	visible = false
	pakai_button.pressed.connect(func(): confirmed.emit())
	batal_button.pressed.connect(func(): cancelled.emit())


func show_ui() -> void:
	visible = true


func hide_ui() -> void:
	visible = false
