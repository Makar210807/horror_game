extends Area3D

var hint_label: Label3D
var is_taken = false
var quest_ui = null

func _ready():
	quest_ui = get_tree().get_first_node_in_group("quest_ui")
	hint_label = get_node_or_null("Label3D")
	if hint_label:
		hint_label.visible = true

func interact():
	if is_taken:
		return
	
	# Второй энергетик (после университета)
	if QuestData.quest_step == 1:
		is_taken = true
		QuestData.has_energy_drink = true
		
		if hint_label:
			hint_label.visible = false
		
		SubtitleLayer.show_subtitle("Взял энергетик. Нужно оплатить.", 2.5)
		
		if quest_ui:
			quest_ui.update_quest("Оплатить покупку")
		
		var cash_register = get_tree().get_first_node_in_group("cash_register")
		if cash_register:
			cash_register.show_hint()
		
		var mesh = get_node_or_null("MeshInstance3D")
		if mesh:
			mesh.visible = false
	
	# Первый энергетик
	elif not QuestData.has_energy_drink:
		is_taken = true
		QuestData.has_energy_drink = true
		
		if hint_label:
			hint_label.visible = false
		
		SubtitleLayer.show_subtitle("Взял энергетик. Теперь нужно оплатить.", 2.5)
		
		if quest_ui:
			quest_ui.update_quest("Оплатить покупку")
		
		var cash_register = get_tree().get_first_node_in_group("cash_register")
		if cash_register:
			cash_register.show_hint()
		
		var mesh = get_node_or_null("MeshInstance3D")
		if mesh:
			mesh.visible = false
