extends Control

const CardScene = preload("res://scenes/Card.tscn")

@onready var npc_name_label: Label = $VBoxContainer/NPCInfo/NPCNameLabel
@onready var question_label: Label = $VBoxContainer/QuestionLabel
@onready var trust_bar: ProgressBar = $VBoxContainer/ProgressBars/TrustBox/TrustBar
@onready var rep_bar: ProgressBar = $VBoxContainer/ProgressBars/RepBox/RepBar
@onready var card_container: HBoxContainer = $VBoxContainer/CardContainer
@onready var ending_label: Label = $EndingLabel
@onready var reaction_label: Label = $VBoxContainer/ReactionLabel


func _ready() -> void:
	GameManager.new_question_shown.connect(_on_question_shown)
	GameManager.stats_changed.connect(_on_stats_changed)
	GameManager.game_ended.connect(_on_game_ended)
	GameManager.npc_reacted.connect(_on_npc_reacted)

	ending_label.visible = false
	reaction_label.visible = false
	trust_bar.max_value = 100
	rep_bar.max_value = 100

	GameManager.start_new_game()
	_on_stats_changed(GameManager.trust, GameManager.trauma)

func _on_npc_reacted(text: String) -> void:
	reaction_label.text = text
	reaction_label.visible = true
	await get_tree().create_timer(1.5).timeout
	reaction_label.visible = false
	GameManager.advance_to_next_question()


func _on_question_shown(question: QuestionData, hand: Array) -> void:
	npc_name_label.text = question.npc_name
	question_label.text = question.question_text
	reaction_label.visible = false

	for child in card_container.get_children():
		child.queue_free()

	for card_data in hand:
		var card_ui = CardScene.instantiate()
		card_container.add_child(card_ui)
		card_ui.setup(card_data)
		card_ui.card_selected.connect(_on_card_selected)

func _on_card_selected(card: CardData) -> void:
	for child in card_container.get_children():
		child.disabled = true  # cegah player klik 2 kartu sekaligus
	GameManager.choose_card(card)


func _on_stats_changed(trust: int, trauma: int) -> void:
	trust_bar.value = trust
	rep_bar.value = trauma
	

func _on_game_ended(_final_trust: int, _final_trauma: int) -> void:
	npc_name_label.text = ""
	question_label.text = ""
	for child in card_container.get_children():
		child.queue_free()

	var ending: EndingData = GameManager.get_matching_ending()

	ending_label.visible = true
	if ending:
		ending_label.text = "%s\n\n%s" % [ending.ending_title, ending.ending_text]
	else:
		ending_label.text = "Ending tidak ditemukan (cek konfigurasi EndingData)"
