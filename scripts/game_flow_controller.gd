extends Node

@export var card_fan_path: NodePath
@export var npc_controller_path: NodePath
@export var ending_display_path: NodePath
@export var reaction_display_seconds: float = 1.5
@export var stat_bars_path: NodePath
@export var floating_numbers_path: NodePath

@onready var stat_bars: Control = get_node(stat_bars_path)
@onready var floating_numbers: Control = get_node(floating_numbers_path)

@onready var card_fan: Node3D = get_node(card_fan_path)
@onready var npc_controller: Node3D = get_node(npc_controller_path)
@onready var ending_display: Control = get_node(ending_display_path)


func _ready() -> void:
	GameManager.new_question_shown.connect(_on_question_shown)
	GameManager.npc_reacted.connect(_on_npc_reacted)
	GameManager.game_ended.connect(_on_game_ended)
	GameManager.stats_changed.connect(_on_stats_changed)
	GameManager.stats_delta.connect(_on_stats_delta)

	GameManager.start_new_game()
	stat_bars.set_stats(GameManager.trust, GameManager.trauma, false)

func _on_stats_changed(trust: int, trauma: int) -> void:
	stat_bars.set_stats(trust, trauma)


func _on_stats_delta(trust_delta: int, trauma_delta: int) -> void:
	floating_numbers.spawn_deltas(trust_delta, trauma_delta)
	
func _on_question_shown(question: QuestionData, hand: Array) -> void:
	npc_controller.change_npc(question.npc_name, question.question_text)
	card_fan.show_hand(hand)


func _on_npc_reacted(text: String) -> void:
	npc_controller.show_reaction(text)
	await get_tree().create_timer(reaction_display_seconds).timeout
	GameManager.advance_to_next_question()


func _on_game_ended(final_trust: int, final_trauma: int) -> void:
	npc_controller.hide_bubble()
	var ending: EndingData = GameManager.get_matching_ending()
	if ending:
		ending_display.show_ending(ending.ending_title, ending.ending_text)
	else:
		ending_display.show_ending("Ending tidak ditemukan", "Cek konfigurasi EndingData kamu.")
