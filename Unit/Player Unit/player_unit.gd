class_name PlayerUnit
extends Unit


signal selected(unit)
signal deselected(unit)

var operatable = false


func get_state():
	var state = .get_state()
	state["operatable"] = operatable
	return state


func _process(_delta):
	$Selected.visible = stage.selected_unit == self


func _on_Stage_player_phase_started(cur_round):
	._on_Stage_player_phase_started(cur_round)
	operatable = true


func _on_Stage_enemy_phase_started(cur_round):
	._on_Stage_enemy_phase_started(cur_round)
	operatable = false


func _on_Cursor_confirm_issued(pos):
	._on_Cursor_confirm_issued(pos)
	if operatable and stage.get_unit_at(pos) == self and stage.selected_unit == null:
		emit_signal("selected", self)
