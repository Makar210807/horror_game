extends CanvasLayer

@onready var quest_label = $QuestLabel

func _ready():
	print("=== QuestUI _ready called ===")
	
	if not quest_label:
		print("ERROR: QuestLabel not found! Creating new one...")
		quest_label = Label.new()
		quest_label.name = "QuestLabel"
		add_child(quest_label)
		
		quest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		quest_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		quest_label.add_theme_font_size_override("font_size", 20)
		quest_label.add_theme_color_override("font_color", Color(1, 1, 1))
		quest_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
		quest_label.add_theme_constant_override("shadow_offset_x", 1)
		quest_label.add_theme_constant_override("shadow_offset_y", 1)
	
	_update_label_position()
	
	get_tree().root.size_changed.connect(_update_label_position)
	
	await get_tree().create_timer(0.2).timeout
	
	# Восстанавливаем квест из глобального состояния
	var saved_quest = QuestData.get_quest()
	print("Saved quest from QuestData: ", saved_quest)
	
	if saved_quest != "" and saved_quest != null:
		quest_label.text = "📋 " + saved_quest
		quest_label.visible = true
		print("Quest restored: ", saved_quest)
	else:
		quest_label.visible = false
		quest_label.text = ""

func _update_label_position():
	if quest_label:
		var viewport_size = get_viewport().size
		quest_label.set_position(Vector2(viewport_size.x - 230, 20))
		quest_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)

# ДОБАВЛЯЕМ ФУНКЦИЮ refresh_quest
func refresh_quest():
	print("=== refresh_quest called ===")
	var current_quest = QuestData.get_quest()
	print("Current quest from QuestData: ", current_quest)
	
	if current_quest != "" and current_quest != null:
		quest_label.text = "📋 " + current_quest
		quest_label.visible = true
		print("Quest refreshed: ", current_quest)
	else:
		quest_label.visible = false
		quest_label.text = ""

func update_quest(new_quest: String):
	print("=== update_quest called: ", new_quest, " ===")
	QuestData.set_quest(new_quest)
	quest_label.text = "📋 " + new_quest
	quest_label.visible = true
	print("Quest updated, QuestData.quest_name is now: ", QuestData.get_quest())

func complete_current():
	print("=== complete_current called ===")
	var current = QuestData.get_quest()
	if current == "":
		return
	
	quest_label.text = "✅ " + current
	print("Quest completed: ", current)
	
	await get_tree().create_timer(1.5).timeout
	quest_label.visible = false
	quest_label.text = ""
	print("Quest hidden, QuestData.quest_name still: ", QuestData.get_quest())
