extends AudioStreamPlayer3D

func _ready():
	# Убедимся, что звук загружен
	if stream:
		play()
	else:
		print("Ошибка: звук не назначен!")
