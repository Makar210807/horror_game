extends Area3D

var can_trigger = true
var trigger_cooldown = 1.0

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if not can_trigger:
		return
	QuestData.use_spawn = true
	QuestData.spawn_position = Vector3(24.196, 1.5, -14.419)
	
	if body.name == "PlayerController":
		print("=== DOOR TRIGGERED ===")
		
		if QuestData.washed and QuestData.eaten:
			can_trigger = false
			SubtitleLayer.show_subtitle("Выхожу на улицу.", 1.5)
			await get_tree().create_timer(1.5).timeout
			get_tree().change_scene_to_file("res://new_street.tscn")
		else:
			can_trigger = false
			if not QuestData.washed:
				SubtitleLayer.show_subtitle("Сначала нужно умыться!", 2.0)
			else:
				SubtitleLayer.show_subtitle("Сначала нужно поесть!", 2.0)
			
			await get_tree().create_timer(trigger_cooldown).timeout
			can_trigger = true
