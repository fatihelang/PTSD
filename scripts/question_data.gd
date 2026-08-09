extends Resource
class_name QuestionData

@export var npc_name: String = "Nama NPC"
@export_multiline var question_text: String = "Keluhan/pertanyaan NPC"
@export var npc_portrait: Texture2D
@export var likes: Array[String] = []
@export var dislikes: Array[String] = []
@export_enum("Netral", "Supporter", "Hater") var disposition: String = "Netral"

@export_multiline var reaction_like: String = ""
@export_multiline var reaction_dislike: String = ""
@export_multiline var reaction_neutral: String = ""
@export_multiline var reaction_belittled: String = ""
