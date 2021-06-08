class_name Unit
extends Node2D


export var unit_name = ""


###############################################################################
#        Main logic                                                           #
###############################################################################


signal acted(unit, description)


var stage = null


func _process(_delta):
	if stage:
		$Selected.visible = stage.selected_unit == self


func _on_Stage_player_phase_started(cur_tick):
	pass


func _on_Stage_enemy_phase_started(cur_tick):
	pass


func _on_Cursor_moved(pos):
	pass


func _on_Cursor_hovered(pos):
	pass


func _on_Cursor_confirm_issued(pos):
	pass


func _on_Cursor_cancel_issued(pos):
	pass
	

###############################################################################
#        Stats logic                                                          #
###############################################################################


export var base_level = 1
export var base_max_hp = 2000
export var base_max_sp = 99
export var base_atk = 500
export var base_def = 200
export var base_res = 0

export (int) var hp = base_max_hp	
export (int) var sp = 20



###############################################################################
#        Combat logic                                                         #
###############################################################################


signal dead(unit)


enum DamageType {PHYSICAL, MAGIC, TRUE}


func take_damage(amount, damage_type):
	hp -= max(amount, 0)
	if hp <= 0:
		die()


func die():
	emit_signal("dead", self)
	queue_free()


###############################################################################
#        State logic                                                          #
###############################################################################


var skill_template = preload("res://Skill/skill.tscn")


enum UnitType {UNDEFINED, SUMMONER, FOLLOWER, GATE, ENEMY}


func get_type_of_self():
	return UnitType.UNDEFINED


func get_state():
	var state = {
		"node_name" : name,
		"unit_type" : get_type_of_self(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"frames" : $Sprite.frames.resource_path,
		"unit_name" : unit_name,
		"base_max_hp" : base_max_hp,
		"hp" : hp,
		"base_max_sp" : base_max_sp,
		"sp" : sp,
		"skills" : []
	}
	
	for s in $Skills.get_children():
		state["skills"].append(s.get_state())
	
	return state


func load_state(state):
	for v in get_state().keys():
		set(v, state[v])
	name = state["node_name"]
	position = Vector2(state["pos_x"], state["pos_y"])
	$Sprite.frames = load(state["frames"])
	
	for skill in $Skills.get_children():
		skill.queue_free()
	
	for skill_state in state["skills"]:
		var new_skill = skill_template.instance()
		$Skills.add_child(new_skill)
		new_skill.script = load(skill_state["script_path"])
		new_skill.unit = self
		new_skill.load_state(skill_state)
