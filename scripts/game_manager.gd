extends Node

@export var testing_mode_sprite_only: bool = true #ngetest sprite npc

# ====== STATE UTAMA ======
var trust: int = 50        # Kepercayaan Rakyat (0-100)
var trauma: int = 50   
var current_question_index: int = 0
var max_questions: int = 10

# ====== DECK & KARTU ======
var all_cards: Array[CardData] = []     # semua kartu 
var deck: Array[CardData] = []          # kartu yg masih bisa di gooning
var discard_pile: Array[CardData] = []  # kartu yg sudah pernah dipilih player
var current_hand: Array[CardData] = []  # kartu yg ditampilkan ke player

# ====== PERTANYAAN ======
var all_questions: Array[QuestionData] = []
var remaining_questions: Array[QuestionData] = []
var current_question: QuestionData = null

# ====== ENDING ======
var all_endings: Array[EndingData] = []

# ====== SIGNAL ======
signal stats_changed(trust: int, trauma: int)
signal stats_delta(trust_delta: int, trauma_delta: int)
signal new_question_shown(question: QuestionData, hand: Array)
signal card_chosen(card: CardData)
signal npc_reacted(reaction_text: String, reaction_category: String)
signal game_ended(final_trust: int, final_trauma: int)

# back up kalau semisal belum tak input di resource
const FALLBACK_REACTIONS := {
	"like": [
		"Wah, akhirnya didengar juga! Terima kasih, Pak!",
		"Ini baru namanya presiden rakyat!",
	],
	"dislike": [
		"Yah, gitu doang jawabannya?",
		"Saya kecewa sama jawaban Bapak.",
	],
	"neutral": [
		"Hmm, jawabannya standar aja sih.",
		"Ya begitu deh, biasa.",
	],
	"belittled": [
		"Kok saya berasa diremehkan ya, Pak?",
		"Jangan anggap enteng masalah kami!",
	],
}



func _ready() -> void:
	_load_all_cards()
	_load_all_questions()
	_load_all_endings()


#func start_new_game() -> void:
	#trust = 50
	#trauma = 50
	#current_question_index = 0
#
	#deck = all_cards.duplicate()
	#discard_pile.clear()
	#current_hand.clear()
#
	#remaining_questions = all_questions.duplicate()
	#remaining_questions.shuffle()
#
	#next_question()
	 
func start_new_game() -> void: #ngetest sprite npc
	trust = 50
	trauma = 50
	current_question_index = 0

	deck = all_cards.duplicate()
	discard_pile.clear()
	current_hand.clear()

	var question_pool: Array[QuestionData] = all_questions

	if testing_mode_sprite_only:
		question_pool = all_questions.filter(func(q): return q.sprite_id.strip_edges() != "")
		print("Testing mode: cuma pakai ", question_pool.size(), " NPC yang punya sprite")

	remaining_questions = question_pool.duplicate()
	remaining_questions.shuffle()

	next_question()



func _load_all_cards() -> void:
	var dir = DirAccess.open("res://resources/cards/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var card = load("res://resources/cards/" + file_name) as CardData
				all_cards.append(card)
			file_name = dir.get_next()
	print("Total kartu di-load: ", all_cards.size())


func _load_all_questions() -> void:
	var dir = DirAccess.open("res://resources/questions/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var q = load("res://resources/questions/" + file_name) as QuestionData
				all_questions.append(q)
			file_name = dir.get_next()
	print("Total pertanyaan di-load: ", all_questions.size())


func _load_all_endings() -> void:
	var dir = DirAccess.open("res://resources/endings/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var e = load("res://resources/endings/" + file_name) as EndingData
				all_endings.append(e)
			file_name = dir.get_next()
	print("Total ending di-load: ", all_endings.size())



func next_question() -> void:
	if current_question_index >= max_questions:
		game_ended.emit(trust, trauma)
		return

	if remaining_questions.is_empty():
		push_warning("Pertanyaan habis sebelum ronde selesai!")
		game_ended.emit(trust, trauma)
		return

	current_question = remaining_questions.pop_front()
	current_question_index += 1

	_draw_hand()
	new_question_shown.emit(current_question, current_hand)


func advance_to_next_question() -> void:
	next_question()



func _draw_hand() -> void:
	current_hand.clear()
	deck.shuffle()

	for i in range(5):
		if deck.is_empty():
			_reshuffle_discard_into_deck()
		if deck.is_empty():
			break
		current_hand.append(deck.pop_front())


func _reshuffle_discard_into_deck() -> void:
	deck.append_array(discard_pile)
	discard_pile.clear()
	deck.shuffle()
	print("Deck habis! Discard pile dikocok ulang jadi deck baru.")



func _get_tag_multiplier(card_tag: String, likes: Array, dislikes: Array) -> float:
	if card_tag in likes:
		return 2.0
	elif card_tag in dislikes:
		return -1.0
	else:
		return 1.0



func _get_reaction_category(card: CardData, question: QuestionData) -> String:
	if card.tag == "Meremehkan":
		return "belittled"

	match question.disposition:
		"Supporter":
			return "like"
		"Hater":
			return "dislike"
		_:
			if card.tag in question.likes:
				return "like"
			elif card.tag in question.dislikes:
				return "dislike"
			else:
				return "neutral"


func _get_reaction_text(category: String, question: QuestionData) -> String:
	var custom_text: String = ""
	match category:
		"like":
			custom_text = question.reaction_like
		"dislike":
			custom_text = question.reaction_dislike
		"neutral":
			custom_text = question.reaction_neutral
		"belittled":
			custom_text = question.reaction_belittled

	if custom_text.strip_edges() != "":
		return custom_text

	var pool: Array = FALLBACK_REACTIONS[category]
	return pool.pick_random()



func choose_card(chosen_card: CardData) -> void:
	var final_trust_delta: float
	var final_rep_delta: float

	match current_question.disposition:
		"Supporter":
			final_trust_delta = abs(chosen_card.trust_effect) * 2.0
			final_rep_delta = abs(chosen_card.trauma_effect) * 2.0
		"Hater":
			final_trust_delta = -abs(chosen_card.trust_effect) * 2.0
			final_rep_delta = -abs(chosen_card.trauma_effect) * 2.0
		_:
			var mult = _get_tag_multiplier(chosen_card.tag, current_question.likes, current_question.dislikes)
			final_trust_delta = chosen_card.trust_effect * mult
			final_rep_delta = chosen_card.trauma_effect * mult

	trust = clampi(trust + int(round(final_trust_delta)), 0, 100)
	trauma = clampi(trauma + int(round(final_rep_delta)), 0, 100)

	stats_delta.emit(int(round(final_trust_delta)), int(round(final_rep_delta)))

	for card in current_hand:
		if card == chosen_card:
			discard_pile.append(card)
		else:
			deck.append(card)
	current_hand.clear()

	var category := _get_reaction_category(chosen_card, current_question)
	var reaction_text := _get_reaction_text(category, current_question)

	card_chosen.emit(chosen_card)
	stats_changed.emit(trust, trauma)
	npc_reacted.emit(reaction_text, category)



func get_matching_ending() -> EndingData:
	for ending in all_endings:
		if trust >= ending.min_trust and trust <= ending.max_trust \
		and trauma >= ending.min_trauma and trauma <= ending.max_trauma:
			return ending
	push_warning("Tidak ada ending yang cocok untuk trust=%d, trauma=%d! Cek rentang EndingData kamu." % [trust, trauma])
	return null
