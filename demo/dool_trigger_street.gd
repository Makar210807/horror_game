extends Area3D

func _on_body_entered(body):
	if body.name == "PlayerController":
		print("Переход на scene_3!")
		get_node("/root/GlobalSceneManager").change_scene("res://market.scn")

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
