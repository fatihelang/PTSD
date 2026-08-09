extends Panel

@onready var title_label: Label = $Title
@onready var text_label: Label = $Text


func _ready() -> void:
	visible = false


func show_ending(title: String, text: String) -> void:
	title_label.text = title
	text_label.text = text
	visible = true
