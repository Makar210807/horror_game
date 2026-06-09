extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "PlayerController":
		print("=== SHOP EXIT TRIGGERED ===")
		
		if QuestData.has_paid:
			print("Paid, exiting shop")
			
			# Спавн у магазина
			QuestData.use_spawn = true
			QuestData.spawn_position = Vector3(-110.392, 1.8, -92.084)
			
			# Сбрасываем флаг смерти
			QuestData.killed_by_enemy = false
			
			# Спавним врага при втором выходе
			if QuestData.needs_another_energy and not QuestData.enemy_spawned:
				QuestData.enemy_spawned = true
				print("Will spawn enemy on street at: (-144.157, 1.8, -100.333)")
			
			SubtitleLayer.show_subtitle("Выхожу из магазина.", 1.5)
			await get_tree().create_timer(1.5).timeout
			get_tree().change_scene_to_file("res://new_street.tscn")
		else:
			print("Cannot exit - not paid")
			SubtitleLayer.show_subtitle("Сначала нужно оплатить покупку!", 2.0)
