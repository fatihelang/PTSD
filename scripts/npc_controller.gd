extends Node3D
#npc controller
@export var speech_bubble_path: NodePath
@export var sprite_path: NodePath
@export var change_duration: float = 0.35

@onready var speech_bubble: Control = get_node(speech_bubble_path)
@onready var sprite: Sprite3D = get_node(sprite_path)


func change_npc(npc_name: String, question_text: String) -> void:
	hide_bubble()

	scale = Vector3.ZERO
	sprite.set_expression("idle")

	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ONE, change_duration)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished

	speech_bubble.show_question(npc_name, question_text)


func show_reaction(text: String, category: String) -> void:
	sprite.set_expression(category)
	speech_bubble.show_question(speech_bubble.name_text.text, text)


func hide_bubble() -> void:
	speech_bubble.hide_question()


func show_bubble() -> void:
	speech_bubble.show_question(speech_bubble.name_text.text, speech_bubble.question_text.text)
