extends Node3D

func _ready():
	add_to_group("shop")
	
	print("=== SHOP SCENE LOADED ===")
	print("killed_by_enemy: ", QuestData.killed_by_enemy)
	
	# Проверяем, умер ли игрок от врага
	if QuestData.killed_by_enemy:
		print("=== RESPAWNING PLAYER ===")
		QuestData.killed_by_enemy = false
		
		# Показываем сообщение
		SubtitleLayer.show_subtitle("Враг догнал тебя... Начни сначала.", 2.5)
		
		# Сбрасываем все флаги
		QuestData.enemy_spawned = false
		QuestData.needs_another_energy = true
		QuestData.has_energy_drink = false
		QuestData.has_paid = false
		QuestData.quest_step = 1
		
		# Сбрасываем позицию и здоровье игрока
		await get_tree().create_timer(0.1).timeout
		
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.global_position = Vector3(-8.524, 0, 0)
			player.set_rotation(Vector3(0, -1.570796, 0))
			if player.has_method("heal"):
				player.heal(100)
			print("Player respawned at shop")
		
		# Обновляем квест
		var quest_ui = get_tree().get_first_node_in_group("quest_ui")
		if quest_ui:
			quest_ui.update_quest("Купить энергетик")
		
		print("State reset complete")
		return  # Выходим, чтобы не показывать лишние сообщения
	
	await get_tree().create_timer(0.5).timeout
	
	var quest_ui = get_tree().get_first_node_in_group("quest_ui")
	
	# Обычный вход в магазин (не после смерти)
	if QuestData.quest_step == 1:
		SubtitleLayer.show_subtitle("Нужно снова купить энергетик.", 2.5)
		if quest_ui:
			quest_ui.update_quest("Купить энергетик")
	elif not QuestData.has_energy_drink:
		SubtitleLayer.show_subtitle("Нужно взять энергетик с полки.", 2.5)
		if quest_ui:
			quest_ui.update_quest("Взять энергетик")
	elif not QuestData.has_paid:
		SubtitleLayer.show_subtitle("Нужно оплатить на кассе.", 2.5)
		if quest_ui:
			quest_ui.update_quest("Оплатить покупку")
	else:
		SubtitleLayer.show_subtitle("Можно выходить.", 2.5)
