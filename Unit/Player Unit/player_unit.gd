class_name PlayerUnit
extends Unit


signal selected(unit)
signal deselected(unit)

var operatable = false
var selected = false


func get_state():
	var state = .get_state()
	state["operatable"] = operatable
	return state


func _process(_delta):
	$Selected.visible = selected


func _on_Stage_player_phase_started(cur_round):
	operatable = true


func _on_Stage_enemy_phase_started(cur_round):
	operatable = false


func _on_Stage_unit_clicked(unit):
	if operatable and unit == self and stage.selected_unit == null:
		selected = true
		emit_signal("selected", self)
