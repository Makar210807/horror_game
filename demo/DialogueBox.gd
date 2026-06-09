extends CanvasLayer

signal dialogue_finished

var current_lines = []
var current_line_index = 0
var color_rect: ColorRect
var panel: Panel
var label: RichTextLabel
var is_printing = false  # Флаг: идёт ли печать текста

# Настройки печати
var print_speed = 0.02  # Скорость появления букв (секунд на букву)
var full_text = ""      # Полный текст текущей строки

func _ready():
	hide()
	
	# Находим узлы
	color_rect = get_node_or_null("ColorRect")
	panel = get_node_or_null("Panel")
	label = get_node_or_null("Panel/RichTextLabel")
	
	# Изначально фон прозрачный, панель скрыта
	if color_rect:
		color_rect.modulate = Color(0, 0, 0, 0)
	
	if panel:
		panel.modulate = Color(1, 1, 1, 0)

func start_dialogue(lines: Array):
	print("Starting dialogue with lines: ", lines)
	current_lines = lines
	current_line_index = 0
	
	
	# Показываем затемнение и панель с анимацией
	if color_rect:
		var tween = create_tween()
		tween.tween_property(color_rect, "modulate", Color(0, 0, 0, 0.7), 0.2)
	
	if panel:
		var tween = create_tween()
		tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.2)
	
	show()
	
	await get_tree().create_timer(2.0).timeout  # задержка перед первой строкой
	
	show_next_line()

func hide_dialogue():
	# Скрываем затемнение и панель с анимацией
	if color_rect:
		var tween = create_tween()
		tween.tween_property(color_rect, "modulate", Color(0, 0, 0, 0), 0.2)
	
	if panel:
		var tween = create_tween()
		tween.tween_property(panel, "modulate", Color(1, 1, 1, 0), 0.2)
	
	await get_tree().create_timer(0.2).timeout
	hide()
	dialogue_finished.emit()

func show_next_line():
	if current_line_index >= current_lines.size():
		hide_dialogue()
		return
	
	# Получаем полный текст текущей строки
	full_text = current_lines[current_line_index]
	current_line_index += 1
	
	# Очищаем и начинаем печать
	if label:
		label.text = ""
		is_printing = true
		await print_text(full_text)
		is_printing = false
	
	# Ждём нажатия ЛКМ для продолжения
	await wait_for_continue()

func print_text(text: String):
	# Печатаем текст по одной букве
	for i in range(len(text)):
		if not is_printing:  # Если печать была прервана
			break
		if label:
			label.text = text.substr(0, i + 1)
		await get_tree().create_timer(print_speed).timeout

func wait_for_continue():
	# Ждём нажатия ЛЕВОЙ КНОПКИ МЫШИ (БЕЗ АВТОМАТИЧЕСКОГО ТАЙМЕРА)
	while true:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			# Небольшая задержка, чтобы не срабатывало несколько раз подряд
			await get_tree().create_timer(0.1).timeout
			
			if is_printing:
				# Если текст ещё печатается - показываем весь сразу
				stop_printing()
			else:
				# Если текст уже напечатан - переходим к следующей строке
				break
			
			# Ждём, пока кнопка отпустится
			while Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				await get_tree().process_frame
		await get_tree().process_frame
	
	show_next_line()

func stop_printing():
	# Прерываем печать и показываем весь текст сразу
	is_printing = false
	if label:
		label.text = full_text
