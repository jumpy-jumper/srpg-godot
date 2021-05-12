class_name Unit
extends Node2D

signal acted(unit, description)
signal dead(unit)

enum UnitType {NULL, SUMMONER, FOLLOWER, GATE, ENEMY}

export var unit_name = ""
export var max_hp = 2
var hp = max_hp

var stage = null


func get_unit_type():
	return UnitType.NULL


func get_state():
	var state = {
		"unit_type" : get_unit_type(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"frames" : $Sprite.frames.resource_path,
		"unit_name" : unit_name,
		"max_hp" : max_hp,
		"hp" : hp,
	}
	return state


func load_state(state):
	for v in get_state().keys():
		set(v, state[v])
	position = Vector2(state["pos_x"], state["pos_y"])
	$Sprite.frames = load(state["frames"])


func die():
	emit_signal("dead", self)
	queue_free()


func _on_Stage_player_phase_started(cur_round):
	pass


func _on_Stage_enemy_phase_started(cur_round):
	pass


func _on_Cursor_confirm_issued(pos):
	pass


func _on_Cursor_cancel_issued(pos):
	pass
