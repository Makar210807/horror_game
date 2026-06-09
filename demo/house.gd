extends Node3D

var thoughts_shown = false
var quest_ui = null

func _ready():
	add_to_group("house")
	
	# Находим UI квестов
	quest_ui = get_tree().get_first_node_in_group("quest_ui")
	
	await get_tree().create_timer(0.5).timeout
	
	if not QuestData.washed:
		SubtitleLayer.show_subtitle("Я проснулся... Нужно умыться и покушать.", 3.0)
	elif not QuestData.eaten:
		SubtitleLayer.show_subtitle("Я уже умылся. Теперь нужно поесть.", 2.5)
	else:
		start_quest_thoughts()
	
	# Обновляем UI
	if quest_ui:
		quest_ui.refresh_quest()

func start_quest_thoughts():
	if thoughts_shown:
		return
	thoughts_shown = true
	
	await get_tree().create_timer(1.0).timeout
	SubtitleLayer.show_subtitle("Нужно идти на учёбу.", 2.0)
	
	await get_tree().create_timer(2.5).timeout
	SubtitleLayer.show_subtitle("По пути нужно зайти в магазин и купить энергетик.", 3.0)

func on_player_ate():
	print("on_player_ate called")
	QuestData.set_eaten(true)
	if quest_ui:
		quest_ui.update_quest("Идти на учёбу")
		start_quest_thoughts()

func on_player_washed():
	print("on_player_washed called")
	QuestData.set_washed(true)
	if quest_ui and not QuestData.eaten:
		quest_ui.update_quest("Поесть")
