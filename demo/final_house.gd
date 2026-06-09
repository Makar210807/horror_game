extends Node3D

var thoughts_shown = false
var fade_rect: ColorRect

func _ready():
	print("=== FINAL HOUSE SCENE LOADED ===")
	
	# Замораживаем движение игрока
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(false)
	
	# Скрываем квест UI
	var quest_ui = get_tree().get_first_node_in_group("quest_ui")
	if quest_ui:
		quest_ui.visible = false
	
	# Запускаем мысли персонажа
	start_thoughts()

func start_thoughts():
	print("=== STARTING FINAL THOUGHTS ===")
	
	# Пауза перед первой мыслью
	await get_tree().create_timer(1.0).timeout
	
	# Мысли персонажа (субтитры внизу экрана)
	SubtitleLayer.show_subtitle("АААААА!", 2.0)
	await get_tree().create_timer(2.5).timeout
	
	SubtitleLayer.show_subtitle("Фух...", 1.5)
	await get_tree().create_timer(2.0).timeout
	
	SubtitleLayer.show_subtitle("Это было всего лишь сон.", 2.5)
	await get_tree().create_timer(3.0).timeout
	
	SubtitleLayer.show_subtitle("Нужно прекратить пить чертовы энергетики...", 3.0)
	await get_tree().create_timer(3.5).timeout
	
	# Затемнение
	await fade_to_black()
	
	# Финальный текст на чёрном экране
	await show_text_on_black("Спасибо за игру!", 3.0)
	
	await get_tree().create_timer(2.0).timeout
	
	# Переход в главное меню
	get_tree().change_scene_to_file("res://main_menu.tscn")

func fade_to_black():
	print("Fading to black...")
	
	fade_rect = ColorRect.new()
	fade_rect.name = "FadeRect"
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = Vector2(1920, 1080)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().root.add_child(fade_rect)
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 1.0)
	await tween.finished
	print("Black screen")

func show_text_on_black(text: String, duration: float):
	print("Showing text: ", text)
	
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	get_tree().root.add_child(label)
	await get_tree().create_timer(duration).timeout
	label.queue_free()
