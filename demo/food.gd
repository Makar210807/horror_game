extends Area3D

@export var food_name = "Food"
@export var health_restore = 10

var fade_rect: ColorRect
var eat_sound: AudioStreamPlayer3D
var tween: Tween
var hint_label: Label3D
var quest_ui = null

func _ready():
	print("Food ready: ", food_name)
	
	quest_ui = get_tree().get_first_node_in_group("quest_ui")
	
	hint_label = get_node_or_null("Label3D")
	if hint_label:
		hint_label.visible = false
	
	eat_sound = get_node_or_null("EatSound")
	if not eat_sound:
		eat_sound = AudioStreamPlayer3D.new()
		eat_sound.name = "EatSound"
		add_child(eat_sound)

func _process(delta):
	if hint_label:
		hint_label.visible = QuestData.washed and not QuestData.eaten

func can_interact():
	return QuestData.washed and not QuestData.eaten

func interact():
	if not can_interact():
		if not QuestData.washed:
			SubtitleLayer.show_subtitle("Сначала нужно умыться!", 2.0)
		else:
			SubtitleLayer.show_subtitle("Я уже поел.", 1.5)
		return
	
	print("interact() called on: ", food_name)
	
	await create_fade_effect()
	
	if eat_sound and eat_sound.stream:
		eat_sound.play()
		SubtitleLayer.show_subtitle("Вкусно! Я подкрепился.", 2.0)
		await eat_sound.finished
	
	await get_tree().create_timer(0.3).timeout
	
	# Сохраняем в глобальное состояние
	QuestData.set_eaten(true)
	
	# Обновляем UI квеста
	if quest_ui:
		quest_ui.update_quest("Идти на учёбу")
	
	var house = get_tree().get_first_node_in_group("house")
	if house and house.has_method("on_player_ate"):
		house.on_player_ate()
		print("Notified house that player ate")
	
	await fade_back()
	queue_free()
	print("Food removed!")

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
