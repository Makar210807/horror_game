extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "PlayerController":
		print("=== HOUSE DOOR TRIGGERED ===")
		
		if QuestData.quest_step == 2:
			print("Entering house!")
			get_tree().change_scene_to_file("res://final_house.tscn")
		else:
			SubtitleLayer.show_subtitle("Нужно сначала закончить дела!", 2.0)
