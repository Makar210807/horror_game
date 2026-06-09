extends CanvasLayer

@onready var subtitle_label = $SubtitleLabel
@onready var subtitle_timer = $SubtitleTimer
@onready var subtitle_sound = $SubtitleSound

var subtitle_queue = []
var is_showing = false
var current_text = ""
var current_duration = 0.0
var current_char_index = 0
var type_speed = 0.05

func _ready():
	subtitle_label.visible = false
	subtitle_label.bbcode_enabled = true
	subtitle_timer.timeout.connect(_on_timer_timeout)

func _input(event):
	if event.is_action_pressed("ui_click") and is_showing:
		skip_current()

func show_subtitle(text: String, duration: float = 3.0):
	print("show_subtitle called: ", text)
	subtitle_queue.append({"text": text, "duration": duration})
	if not is_showing:
		_show_next()

func _show_next():
	if subtitle_queue.is_empty():
		is_showing = false
		subtitle_label.visible = false
		if subtitle_sound.stream:
			subtitle_sound.stop()
		return
	
	is_showing = true
	var current = subtitle_queue.pop_front()
	current_text = current["text"]
	current_duration = current["duration"]
	current_char_index = 0
	
	subtitle_label.text = ""
	subtitle_label.visible = true
	subtitle_timer.wait_time = type_speed
	subtitle_timer.start()
	
	if subtitle_sound.stream:
		subtitle_sound.play()

func _on_timer_timeout():
	if current_char_index < current_text.length():
		subtitle_label.text += current_text[current_char_index]
		current_char_index += 1
		subtitle_timer.start()
	else:
		subtitle_timer.stop()
		if subtitle_sound.stream:
			subtitle_sound.stop()
		await get_tree().create_timer(current_duration).timeout
		_show_next()

func skip_current():
	if not is_showing:
		return
	
	subtitle_timer.stop()
	if subtitle_sound.stream:
		subtitle_sound.stop()
	
	subtitle_label.text = current_text
	current_char_index = current_text.length()
	
	await get_tree().create_timer(0.5).timeout
	_show_next()

func clear_queue():
	subtitle_timer.stop()
	if subtitle_sound.stream:
		subtitle_sound.stop()
	subtitle_queue.clear()
	is_showing = false
	subtitle_label.visible = false
