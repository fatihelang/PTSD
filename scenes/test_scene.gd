extends Node
#test doang, semoga bisa
func _ready() -> void:
	GameManager.new_question_shown.connect(_on_question_shown)
	GameManager.game_ended.connect(_on_game_ended)
	GameManager.start_new_game()
	
func _on_question_shown(question: QuestionData, hand: Array) -> void:
	print("--- Pertanyaan ke-", GameManager.current_question_index, " ---")
	print(question.npc_name, ": ", question.question_text)
	print("Kartu di tangan:")
	for card in hand:
		print(" - ", card.card_name, " (Trust: ", card.trust_effect, ", Rep: ", card.trauma_effect, ")")

	
	await get_tree().create_timer(0.5).timeout
	GameManager.choose_card(hand[0])

func _on_game_ended(final_trust: int, final_trauma: int) -> void:
	print("=== GAME SELESAI ===")
	print("Trust akhir: ", final_trust, " | Trauma akhir: ", final_trauma)
