class_name Follower
extends PlayerUnit


enum Facing {RIGHT, DOWN, LEFT, UP}


export(Array) var deployable_terrain = null
export var cost = 9


var facing = Facing.UP


###############################################################################
#        Main logic                                                           #
###############################################################################


func _on_Cursor_confirm_issued(pos):
	._on_Cursor_confirm_issued(pos)
	if stage.selected_unit == self and stage.get_unit_at(pos) == null:
		position = pos
		emit_signal("acted", self, "moved to " + str(pos))
		stage.deselect_unit()


func _on_Cursor_cancel_issued(pos):
	._on_Cursor_cancel_issued(pos)
	if stage.selected_unit == null and stage.get_unit_at(pos) == self:
		die()
		emit_signal("acted", self, "retreated")
	elif stage.selected_unit == self:
		stage.deselect_unit()


###############################################################################
#        Tick and basic action                                                #
###############################################################################


func tick():
	for skill in $Skills.get_children():
		skill.tick()


###############################################################################
#        State logic                                                          #
###############################################################################


func get_type_of_self():
	return UnitType.FOLLOWER


func get_type_of_enemy():
	return UnitType.ENEMY


func get_state():
	var state = .get_state()
	state["facing"] = facing
	return state


func load_state(state):
	.load_state(state)
