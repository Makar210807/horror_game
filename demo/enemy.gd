extends CharacterBody3D

@export var speed = 5.0
@export var damage = 100

var player = null
var is_chasing = false
var spawn_position = Vector3(-144.157, 1.8, -100.333)
var has_attacked = false
var animation_player = null
var sound_2d = null
var is_sound_playing = false

func _ready():
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	
	# Находим AnimationPlayer
	animation_player = get_node_or_null("AnimationPlayer")
	
	# Создаём 2D звук (AudioStreamPlayer, не 3D)
	sound_2d = AudioStreamPlayer.new()
	sound_2d.name = "ScarySound2D"
	add_child(sound_2d)
	
	# Загружаем звук
	var sound_path = "res://sounds/fears-to-fathom-jumpscare(1).mp3"
	var sound_stream = load(sound_path)
	if sound_stream:
		sound_2d.stream = sound_stream
		print("Scary sound loaded")
	else:
		print("Sound file not found: ", sound_path)
	
	visible = false
	set_process(false)
	print("Enemy ready")

func spawn():
	global_position = spawn_position
	print("Enemy spawning at: ", global_position)
	visible = true
	set_process(true)
	is_chasing = true
	has_attacked = false
	player = get_tree().get_first_node_in_group("player")
	
	# Включаем страшный 2D звук (будет играть пока враг жив)
	start_scary_sound()
	
	# Запускаем анимацию бега
	play_run_animation()

func start_scary_sound():
	if sound_2d and sound_2d.stream:
		sound_2d.play()
		is_sound_playing = true
		print("Scary sound started (2D)")
		# Зацикливаем звук
		sound_2d.finished.connect(_on_scary_sound_finished)

func _on_scary_sound_finished():
	# Зацикливаем звук
	if is_sound_playing and sound_2d:
		sound_2d.play()

func stop_scary_sound():
	if sound_2d and is_sound_playing:
		sound_2d.stop()
		is_sound_playing = false
		if sound_2d.finished.is_connected(_on_scary_sound_finished):
			sound_2d.finished.disconnect(_on_scary_sound_finished)
		print("Scary sound stopped")

func play_run_animation():
	if animation_player:
		var anim_list = animation_player.get_animation_list()
		
		if anim_list.has("running"):
			animation_player.play("running")
		elif anim_list.has("run"):
			animation_player.play("run")
		elif anim_list.size() > 0:
			animation_player.play(anim_list[0])
		
		var current_anim = animation_player.current_animation
		if current_anim:
			var anim = animation_player.get_animation(current_anim)
			if anim:
				anim.loop_mode = Animation.LOOP_LINEAR

func _physics_process(delta):
	if not is_chasing:
		return
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return
	
	velocity.y = 0
	var direction = (player.global_position - global_position).normalized()
	direction.y = 0
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()
	
	if direction != Vector3.ZERO:
		var target_angle = atan2(direction.x, direction.z)
		rotation.y = target_angle
	
	var distance = global_position.distance_to(player.global_position)
	if distance < 1.5 and not has_attacked:
		attack_player()

func attack_player():
	print("=== ENEMY ATTACK ===")
	has_attacked = true
	
	# Останавливаем страшный звук
	stop_scary_sound()
	
	if animation_player:
		animation_player.stop()
	
	QuestData.killed_by_enemy = true
	get_tree().change_scene_to_file("res://market.scn")
