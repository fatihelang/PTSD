extends Button
class_name CardUI

signal card_selected(card: CardData)

var card_data: CardData

@onready var text_label: Label = $VBoxContainer/TextLabel
@onready var art_rect: TextureRect = $VBoxContainer/ArtRect


func setup(data: CardData) -> void:
	card_data = data
	text_label.text = data.card_name
	if data.card_art:
		art_rect.texture = data.card_art


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	card_selected.emit(card_data)
