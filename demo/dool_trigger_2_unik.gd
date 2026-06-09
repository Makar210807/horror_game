extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "PlayerController":
		print("=== UNIVERSITY DOOR TRIGGERED ===")
		
		# Проверяем, оплатил ли первый энергетик и не нужен ли второй
		if QuestData.has_paid and not QuestData.needs_another_energy:
			print("Entering university!")
			get_tree().change_scene_to_file("res://university.tscn")
		elif QuestData.needs_another_energy:
			SubtitleLayer.show_subtitle("Я уже был здесь. Нужно купить энергетик!", 2.0)
		else:
			SubtitleLayer.show_subtitle("Сначала нужно купить энергетик в магазине!", 2.0)
