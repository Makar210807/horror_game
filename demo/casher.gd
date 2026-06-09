extends Area3D

var hint_label: Label3D
var is_paid = false
var dialogue_box = null
var quest_ui = null
var cashier_anim_player = null

# Защита от спама
var can_interact = true
var interact_cooldown = 1.0

func _ready():
	add_to_group("cash_register")
	quest_ui = get_tree().get_first_node_in_group("quest_ui")
	
	var parent = get_parent()
	if parent:
		cashier_anim_player = parent.get_node_or_null("AnimationPlayer")
	
	hint_label = get_node_or_null("Label3D")
	if hint_label:
		hint_label.visible = false
	
	var dialogue_scene = preload("res://DialogueBox.tscn")
	dialogue_box = dialogue_scene.instantiate()
	add_child(dialogue_box)
	dialogue_box.hide()

func show_hint():
	if hint_label and not is_paid and can_interact:
		if QuestData.has_energy_drink:
			hint_label.text = "Нажмите E для оплаты"
			hint_label.visible = true
		else:
			hint_label.visible = false

func interact():
	if not can_interact:
		return
	
	if is_paid:
		can_interact = false
		SubtitleLayer.show_subtitle("Я уже оплатил.", 1.5)
		await get_tree().create_timer(interact_cooldown).timeout
		can_interact = true
		return
	
	if not QuestData.has_energy_drink:
		can_interact = false
		SubtitleLayer.show_subtitle("Сначала нужно взять энергетик!", 2.0)
		await get_tree().create_timer(interact_cooldown).timeout
		can_interact = true
		return
	
	can_interact = false
	
	if hint_label:
		hint_label.visible = false
	
	# НЕМЕДЛЕННО запускаем диалог (без await, без таймеров)
	start_cashier_dialogue()

func start_cashier_dialogue():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(false)
	
	if cashier_anim_player:
		cashier_anim_player.play("ArmatureAction")
	
	var lines = []
	
	if QuestData.needs_another_energy:
		lines = [
			"Кассир: Опять ты? Снова за энергетиком?",
			"Кассир: Ладно, держи. Только никому не говори, что я тебе два продал.",
			"Игрок: Спасибо! Очень нужно было."
		]
	else:
		lines = [
			"Кассир: Зачем тебе эта таблица Менделеева, мальчик?",
			"Кассир: Ничего хорошего тебя от них не ждёт.",
			"Игрок: Мне нужно сдать экзамен, без этого никак.",
			"Кассир: Ладно, держи. Только осторожнее с ними."
		]
	
	# Показываем диалог сразу
	dialogue_box.show()
	dialogue_box.start_dialogue(lines)
	
	if not dialogue_box.dialogue_finished.is_connected(_on_dialogue_finished):
		dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

func _on_dialogue_finished():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(true)
	
	if cashier_anim_player:
		cashier_anim_player.stop()
	
	# Оплата после диалога
	is_paid = true
	QuestData.has_paid = true
	
	if QuestData.needs_another_energy:
		SubtitleLayer.show_subtitle("Оплатил! Теперь можно идти домой.", 2.5)
		if quest_ui:
			quest_ui.update_quest("Вернуться домой")
		QuestData.quest_step = 2
		QuestData.use_spawn = false
		QuestData.spawn_position = Vector3(0, 0, 0)
	else:
		SubtitleLayer.show_subtitle("Оплатил! Теперь можно идти в университет.", 2.5)
		if quest_ui:
			quest_ui.update_quest("Идти в университет")
	
	await get_tree().create_timer(interact_cooldown).timeout
	can_interact = true
