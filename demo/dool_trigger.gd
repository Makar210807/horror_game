extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "PlayerController":
		print("=== DOOR DEBUG ===")
		print("QuestData.washed: ", QuestData.washed)
		print("QuestData.eaten: ", QuestData.eaten)
		print("Result: ", QuestData.washed and QuestData.eaten)
		
		QuestData.use_spawn = true
		QuestData.spawn_position = Vector3(24.196, 1.5, -14.419)
		if QuestData.washed and QuestData.eaten:
			print("Exiting to street!")
			get_tree().change_scene_to_file("res://new_street.tscn")
		else:
			print("Cannot exit!")
			SubtitleLayer.show_subtitle("Сначала нужно умыться и поесть!", 2.0)
