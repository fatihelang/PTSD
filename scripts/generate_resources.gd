#daripada input 1 per 1, mending pakai kek ginian aja
@tool
extends EditorScript


const CARDS_CSV := "res://import_data/cards.csv"
const QUESTIONS_CSV := "res://import_data/questions.csv"
const ENDINGS_CSV := "res://import_data/endings.csv"

const CARDS_OUT_DIR := "res://resources/cards/"
const QUESTIONS_OUT_DIR := "res://resources/questions/"
const ENDINGS_OUT_DIR := "res://resources/endings/"


func _run() -> void:
	print("=== Mulai generate resources ===")
	_generate_cards()
	_generate_questions()
	_generate_endings()
	print("=== Selesai! Cek folder resources/ ===")


func _read_csv(path: String) -> Array:
	var rows: Array = []
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Gagal buka file: " + path)
		return rows

	var headers: PackedStringArray = file.get_csv_line()
	while not file.eof_reached():
		var line: PackedStringArray = file.get_csv_line()
		if line.size() == 1 and line[0] == "":
			continue
		var row := {}
		for i in range(headers.size()):
			row[headers[i]] = line[i] if i < line.size() else ""
		rows.append(row)
	file.close()
	return rows


func _split_tags(raw: String) -> Array[String]:
	var result: Array[String] = []
	if raw.strip_edges() == "":
		return result
	for part in raw.split(","):
		var trimmed := part.strip_edges()
		if trimmed != "":
			result.append(trimmed)
	return result


func _generate_cards() -> void:
	var rows := _read_csv(CARDS_CSV)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CARDS_OUT_DIR))

	for row in rows:
		var card := CardData.new()
		card.card_name = row.get("Card Name", "")
		card.tag = row.get("Tag", "")
		card.trust_effect = int(row.get("Trust Effect", "0"))
		card.trauma_effect = int(row.get("Trauma Effect", "0"))

		var id: String = row.get("ID", "card_unknown")
		var out_path: String = CARDS_OUT_DIR + id + ".tres"
		var err := ResourceSaver.save(card, out_path)
		if err != OK:
			push_error("Gagal simpan: " + out_path)
		else:
			print("Card OK: ", out_path)


func _generate_questions() -> void:
	var rows := _read_csv(QUESTIONS_CSV)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(QUESTIONS_OUT_DIR))

	for row in rows:
		var q := QuestionData.new()
		q.npc_name = row.get("NPC Name", "")
		q.question_text = row.get("Question Text", "")
		q.likes = _split_tags(row.get("Likes", ""))
		q.dislikes = _split_tags(row.get("Dislikes", ""))
		q.disposition = row.get("Fixed Reaction", "Netral")
		q.reaction_like = row.get("Reaction Like", "")
		q.reaction_dislike = row.get("Reaction Dislike", "")
		q.reaction_neutral = row.get("Reaction Neutral", "")
		q.reaction_belittled = row.get("Reaction Belittled", "")

		var id: String = row.get("ID", "q_unknown")
		var out_path: String = QUESTIONS_OUT_DIR + id + ".tres"
		var err := ResourceSaver.save(q, out_path)
		if err != OK:
			push_error("Gagal simpan: " + out_path)
		else:
			print("Question OK: ", out_path)


func _generate_endings() -> void:
	var rows := _read_csv(ENDINGS_CSV)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ENDINGS_OUT_DIR))

	for row in rows:
		var e := EndingData.new()
		e.ending_title = row.get("Ending Title", "")
		e.ending_text = row.get("Ending Text", "")
		e.min_trust = int(row.get("Min Trust", "0"))
		e.max_trust = int(row.get("Max Trust", "100"))
		e.min_trauma = int(row.get("Min Trauma", "0"))
		e.max_trauma = int(row.get("Max Trauma", "100"))

		var id: String = row.get("ID", "end_unknown")
		var out_path: String = ENDINGS_OUT_DIR + id + ".tres"
		var err := ResourceSaver.save(e, out_path)
		if err != OK:
			push_error("Gagal simpan: " + out_path)
		else:
			print("Ending OK: ", out_path)
