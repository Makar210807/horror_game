extends Area3D

var hint_label: Label3D
var is_paid = false
var dialogue_box = null
var quest_ui = null

func _ready():
	add_to_group("cash_register")
	quest_ui = get_tree().get_first_node_in_group("quest_ui")
	
	hint_label = get_node_or_null("Label3D")
	if hint_label:
		hint_label.visible = false
	
	# Загружаем сцену диалога
	var dialogue_scene = preload("res://DialogueBox.tscn")
	dialogue_box = dialogue_scene.instantiate()
	add_child(dialogue_box)
	dialogue_box.hide()

func show_hint():
	if hint_label and not is_paid:
		if QuestData.has_energy_drink:
			hint_label.text = "Нажмите E для оплаты"
			hint_label.visible = true
		else:
			hint_label.visible = false

func interact():
	if is_paid:
		SubtitleLayer.show_subtitle("Я уже оплатил.", 1.5)
		return
	
	if not QuestData.has_energy_drink:
		SubtitleLayer.show_subtitle("Сначала нужно взять энергетик!", 2.0)
		return
	
	# ОПЛАТА (энергетик взят)
	is_paid = true
	QuestData.has_paid = true
	
	if hint_label:
		hint_label.visible = false
	
	# Определяем, какая это покупка (первая или вторая)
	if QuestData.needs_another_energy:
		# Вторая покупка (после университета)
		SubtitleLayer.show_subtitle("Оплатил! Теперь можно идти домой.", 2.5)
		if quest_ui:
			quest_ui.update_quest("Вернуться домой")
		QuestData.quest_step = 2
	else:
		# Первая покупка
		SubtitleLayer.show_subtitle("Оплатил! Теперь можно идти в университет.", 2.5)
		if quest_ui:
			quest_ui.update_quest("Идти в университет")
	
	# Запускаем диалог с кассиром
	start_cashier_dialogue()

func start_cashier_dialogue():
	# Замораживаем игрока
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(false)
	
	# Разный диалог для первой и второй покупки
	var lines = []
	
	if QuestData.needs_another_energy:
		# Диалог для второй покупки
		lines = [
			"Кассир: Опять ты? Снова за энергетиком?",
			"Кассир: Ладно, держи. Только не говори никому, что я тебе два продал.",
			"Игрок: Спасибо! Очень нужно было."
		]
	else:
		# Диалог для первой покупки
		lines = [
			"Кассир: Зачем тебе эта таблица Менделеева, мальчик?",
			"Кассир: Ничего хорошего тебя от них не ждёт.",
			"Игрок: Мне нужно сдать экзамен, без этого никак.",
			"Кассир: Ладно, держи. Только осторожнее с ними."
		]
	
	dialogue_box.show()
	dialogue_box.start_dialogue(lines)
	
	if not dialogue_box.dialogue_finished.is_connected(_on_dialogue_finished):
		dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

func _on_dialogue_finished():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(true)
	
	# Обновляем квест после диалога
	if quest_ui:
		if QuestData.needs_another_energy:
			quest_ui.update_quest("Вернуться домой")
		else:
			quest_ui.update_quest("Идти в университет")
