extends Node

var washed = false
var eaten = false
var has_energy_drink = false
var has_paid = false
var needs_another_energy = false
var quest_step = 0
var quest_name = "Проснуться и умыться"
var spawn_position = Vector3(0, 0, 0)
var use_spawn = false
var enemy_spawned = false
var killed_by_enemy = false

func set_washed(value: bool):
	washed = value
	if washed and not eaten:
		quest_name = "Поесть"

func set_eaten(value: bool):
	eaten = value
	if eaten:
		quest_name = "Идти на учёбу"

func set_has_energy_drink(value: bool):
	has_energy_drink = value
	if has_energy_drink and not has_paid:
		quest_name = "Оплатить покупку"

func set_has_paid(value: bool):
	has_paid = value
	if has_paid:
		quest_name = "Идти в университет"

func set_quest(name: String):
	quest_name = name

func get_quest() -> String:
	return quest_name
func set_killed_by_enemy(value: bool):
	killed_by_enemy = value
	print("killed_by_enemy set to: ", value)
