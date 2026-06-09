extends Area3D

@export var action_name = "Wash"
@export var hygiene_restore = 20

var fade_rect: ColorRect
var bath_sound: AudioStreamPlayer3D
var tween: Tween
var is_used = false
var hint_label: Label3D
var quest_ui = null

# Защита от спама
var can_interact = true
var interact_cooldown = 1.0

func _ready():
	print("Bath ready: ", action_name)
	
	quest_ui = get_tree().get_first_node_in_group("quest_ui")
	
	hint_label = get_node_or_null("Label3D")
	
	bath_sound = get_node_or_null("BathSound")
	if not bath_sound:
		bath_sound = AudioStreamPlayer3D.new()
		bath_sound.name = "BathSound"
		add_child(bath_sound)

func _process(delta):
	if hint_label:
		hint_label.visible = not QuestData.washed and not is_used and can_interact

func can_interact_condition():
	return not QuestData.washed and not is_used and can_interact

func interact():
	if not can_interact:
		return
	
	if is_used:
		can_interact = false
		SubtitleLayer.show_subtitle("Я уже умывался сегодня.", 1.5)
		await get_tree().create_timer(interact_cooldown).timeout
		can_interact = true
		return
	
	if not can_interact_condition():
		can_interact = false
		SubtitleLayer.show_subtitle("Я уже умылся.", 1.5)
		await get_tree().create_timer(interact_cooldown).timeout
		can_interact = true
		return
	
	can_interact = false
	
	print("interact() called on: ", action_name)
	
	await create_fade_effect()
	
	if bath_sound and bath_sound.stream:
		bath_sound.play()
		SubtitleLayer.show_subtitle("Свежесть! Теперь я чистый.", 2.0)
		await bath_sound.finished
		print("Sound finished")
	
	is_used = true
	
	if hint_label:
		hint_label.visible = false
		print("Hint label hidden")
	
	await get_tree().create_timer(0.3).timeout
	
	# Сохраняем в глобальное состояние
	QuestData.set_washed(true)
	
	# Обновляем UI квеста
	if quest_ui and not QuestData.eaten:
		quest_ui.update_quest("Поесть")
	
	# Сообщаем дому, что игрок умылся
	var house = get_tree().get_first_node_in_group("house")
	if house and house.has_method("on_player_washed"):
		house.on_player_washed()
	
	await fade_back()
	
	# Восстанавливаем возможность взаимодействия
	can_interact = true
	print("Bath used")

func create_fade_effect():
	fade_rect = ColorRect.new()
	fade_rect.name = "FadeRect"
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = Vector2(1920, 1080)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().root.add_child(fade_rect)
	
	tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 0.3)
	await tween.finished
	print("Faded to black")

func fade_back():
	tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.3)
	await tween.finished
	fade_rect.queue_free()
	print("Fade back complete")
