extends Node3D

var quest_ui = null
var player_spawned = false
var enemy_node = null

func _ready():
	add_to_group("street")
	
	quest_ui = get_tree().get_first_node_in_group("quest_ui")
	
	# Находим врага в сцене
	enemy_node = get_node_or_null("Enemy")
	if enemy_node:
		print("Enemy node found in scene!")
	else:
		print("WARNING: Enemy node NOT found in scene!")
	
	# Спавн игрока если нужно
	if not player_spawned and QuestData.use_spawn and QuestData.spawn_position != Vector3(0, 0, 0):
		player_spawned = true
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.global_position = QuestData.spawn_position
			print("Player spawned at: ", QuestData.spawn_position)
			QuestData.use_spawn = false
			QuestData.spawn_position = Vector3(0, 0, 0)
	
	await get_tree().create_timer(0.5).timeout
	
	# Проверяем, нужно ли спавнить врага
	print("enemy_spawned flag: ", QuestData.enemy_spawned)
	print("enemy_node exists: ", enemy_node != null)
	
	if QuestData.enemy_spawned and enemy_node:
		print("SPAWNING ENEMY!")
		enemy_node.spawn()
		SubtitleLayer.show_subtitle("Кто-то приближается! Нужно бежать!", 2.5)
	elif QuestData.enemy_spawned and not enemy_node:
		print("ERROR: enemy_spawned is true but enemy_node is null!")
	
	if QuestData.quest_step == 2:
		if quest_ui:
			quest_ui.update_quest("Вернуться домой")
		SubtitleLayer.show_subtitle("Теперь можно идти домой.", 2.5)
	elif QuestData.needs_another_energy:
		if quest_ui:
			quest_ui.update_quest("Купить энергетик")
		SubtitleLayer.show_subtitle("Нужно сходить в магазин.", 2.5)
	elif QuestData.has_paid:
		if quest_ui:
			quest_ui.update_quest("Идти в университет")
		SubtitleLayer.show_subtitle("Теперь можно идти в университет.", 2.5)
	else:
		if quest_ui:
			quest_ui.update_quest("Идти на учёбу")
		SubtitleLayer.show_subtitle("Нужно зайти в магазин и купить энергетик.", 3.0)
