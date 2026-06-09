extends Node3D

var fade_rect: ColorRect
var quest_ui = null

func _ready():
	add_to_group("university")
	
	quest_ui = get_tree().get_first_node_in_group("quest_ui")
	
	if quest_ui:
		quest_ui.visible = false
	
	await start_sequence()

func start_sequence():
	print("=== UNIVERSITY SEQUENCE STARTED ===")
	
	await fade_to_black()
	
	await show_text_with_delay("Прошло 5 часов...", 2.0)
	await show_text_with_delay("Как же я устал...", 2.0)
	await show_text_with_delay("Нужен ещё один энергетик.", 2.5)
	
	QuestData.needs_another_energy = true
	QuestData.quest_step = 1
	QuestData.has_energy_drink = false
	QuestData.has_paid = false
	
	# Спавн У УНИВЕРСИТЕТА
	QuestData.use_spawn = true
	QuestData.spawn_position = Vector3(-209.341, 1.999, -86.24)
	
	await fade_from_black()
	
	if quest_ui:
		quest_ui.visible = true
		quest_ui.update_quest("Купить энергетик")
	
	SubtitleLayer.show_subtitle("Нужно сходить в магазин.", 2.5)
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://new_street.tscn")

func fade_to_black():
	fade_rect = ColorRect.new()
	fade_rect.name = "FadeRect"
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = Vector2(1920, 1080)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().root.add_child(fade_rect)
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 1.0)
	await tween.finished

func fade_from_black():
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 1.0)
	await tween.finished
	fade_rect.queue_free()

func show_text_with_delay(text: String, duration: float):
	var temp_label = Label.new()
	temp_label.text = text
	temp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	temp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	temp_label.add_theme_font_size_override("font_size", 20)
	temp_label.add_theme_color_override("font_color", Color(1, 1, 1))
	temp_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	temp_label.add_theme_constant_override("shadow_offset_x", 2)
	temp_label.add_theme_constant_override("shadow_offset_y", 2)
	temp_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	get_tree().root.add_child(temp_label)
	await get_tree().create_timer(duration).timeout
	temp_label.queue_free()
