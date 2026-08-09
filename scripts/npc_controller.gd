extends Node3D

@export var speech_bubble_path: NodePath
@export var change_duration: float = 0.35
@onready var speech_bubble: Control = get_node(speech_bubble_path)


func change_npc(npc_name: String, question_text: String) -> void:
	hide_bubble()

	scale = Vector3.ZERO
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ONE, change_duration)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished

	speech_bubble.show_question(npc_name, question_text)


func show_reaction(text: String) -> void:
	speech_bubble.show_question(speech_bubble.name_text.text, text)


func hide_bubble() -> void:
	speech_bubble.hide_question()


func show_bubble() -> void:
	speech_bubble.show_question(speech_bubble.name_text.text, speech_bubble.question_text.text)
