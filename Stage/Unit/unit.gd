class_name Unit
extends Node2D

signal acted()
signal dead(unit)

export var unit_name = ""
export var max_hp = 2
export var hp = 2
export var ini = 8

var stage = null

func get_state():
	var state = {
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


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		print(to_json(get_state()))
	if Input.is_action_just_pressed("ui_cancel"):
		var savefile = File.new()
		savefile.open("user://testsave.sav", File.READ)
		load_state(parse_json(savefile.get_line()))
		savefile.close()
