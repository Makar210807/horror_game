@tool
extends EditorPlugin
class_name GodoSound

## This is really only meant to be used by the GodoSound script.
static func _destroy_player(player : Node) -> void:
	await player.finished
	player.queue_free()

## Plays a sound using the AudioStreamPlayer Node.
## auto_free true means it will destroy the player when finished.
static func play_sound(sound : AudioStream, volume_db : float = 0.0, auto_free : bool = true, bus : StringName = &"Master", play_position : float = 0.0) -> AudioStreamPlayer:
	var tree : SceneTree = Engine.get_main_loop()
	if tree is not SceneTree:
		printerr("GodoSound play_sound(): Failed because there is no SceneTree!")
		return
	if not tree.current_scene:
		printerr("GodoSound play_sound(): Failed because tree.current_scene returned NULL!")
		return
	var player : AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = sound
	player.bus = bus
	player.volume_db = volume_db
	tree.root.add_child(player)
	player.play(play_position)
	if auto_free:
		_destroy_player.call_deferred(player)
	return player

## Plays a sound using the AudioStreamPlayer2D Node.
## auto_free true means it will destroy the player when finished.
static func play_sound2d(sound : AudioStream, position : Vector2 = Vector2(0,0), volume_db : float = 0.0, auto_free : bool = true, bus : StringName = &"Master", play_position : float = 0.0) -> AudioStreamPlayer2D:
	var tree : SceneTree = Engine.get_main_loop()
	if tree is not SceneTree:
		printerr("GodoSound play_sound2D(): Failed because there is no SceneTree!")
		return
	if not tree.current_scene:
		printerr("GodoSound play_sound2D(): Failed because tree.current_scene returned NULL!")
		return
	var player : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	player.stream = sound
	player.bus = bus
	player.volume_db = volume_db
	player.position = position
	tree.root.add_child(player)
	player.play(play_position)
	if auto_free:
		_destroy_player.call_deferred(player)
	return player

## Plays a sound using the AudioStreamPlayer3D Node.
## auto_free true means it will destroy the player when finished.
static func play_sound3d(sound : AudioStream, position : Vector3 = Vector3(0,0,0), volume_db : float = 0.0, auto_free : bool = true, bus : StringName = &"Master", play_position : float = 0.0) -> AudioStreamPlayer3D:
	var tree : SceneTree = Engine.get_main_loop()
	if tree is not SceneTree:
		printerr("GodoSound play_sound3D(): Failed because there is no SceneTree!")
		return
	if not tree.current_scene:
		printerr("GodoSound play_sound3D(): Failed because tree.current_scene returned NULL!")
		return
	var player : AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	player.stream = sound
	player.bus = bus
	player.volume_db = volume_db
	player.position = position
	tree.root.add_child(player)
	player.play(play_position)
	if auto_free:
		_destroy_player.call_deferred(player)
	return player
