class_name Unit
extends Node2D

signal acted()
signal dead(unit)

enum UnitType {NULL, SUMMONER, FOLLOWER, GATE, ENEMY}

export var unit_name = ""
export var max_hp = 2
export var hp = 2
export var max_ini = 8
export var ini = 8

var stage = null


func get_unit_type():
	return UnitType.NULL


func get_state():
	var state = {
		"unit_type" : get_unit_type(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"path_to_frames" : $Sprite.frames.resource_path,
		"unit_name" : unit_name,
		"max_hp" : max_hp,
		"hp" : hp,
		"max_ini" : max_ini,
		"ini" : ini,
	}
	return state


func load_state(state):
	for v in get_state().keys():
		set(v, state[v])
	position = Vector2(state["pos_x"], state["pos_y"])
	$Sprite.frames = load(state["path_to_frames"])


func die():
	emit_signal("dead", self)
	queue_free()


func _on_Stage_player_phase_started(cur_round):
	pass


func _on_Stage_enemy_phase_started(cur_round):
	pass


func _on_Stage_tile_hovered(tile):
	pass


func _on_Stage_tile_clicked(tile):
	pass


func _on_Stage_unit_hovered(unit):
	pass


func _on_Stage_unit_clicked(unit):
	pass
