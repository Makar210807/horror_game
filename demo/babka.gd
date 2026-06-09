extends Node3D

@onready var animation_player = $AnimationPlayer

func _ready():
	if animation_player:
		# Проверяем, какие анимации есть
		var animations = animation_player.get_animation_list()
		print("Available animations: ", animations)
		
		# Запускаем анимацию зацикленно
		animation_player.play("ArmatureAction")
		
		# Настройки зацикливания
		var anim = animation_player.get_animation("ArmatureAction")
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR  # Зацикливание
			animation_player.play("ArmatureAction")
			print("Cashier animation playing with loop")
	else:
		print("ERROR: AnimationPlayer not found on cashier!")
