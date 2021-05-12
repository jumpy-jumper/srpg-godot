class_name Follower
extends PlayerUnit


enum Facing {RIGHT, DOWN, LEFT, UP}

export(Array) var deployable_terrain = null
export var cost = 9

var facing = Facing.UP


func get_unit_type():
	return UnitType.FOLLOWER


func get_state():
	var state = .get_state()
	state["facing"] = facing
	return state


func load_state(state):
	.load_state(state)


func _on_Cursor_confirm_issued(pos):
	._on_Cursor_confirm_issued(pos)
	if stage.selected_unit == self and stage.get_unit_at(pos) == null:
		position = pos
		emit_signal("acted", self, "moved to " + str(pos))
		stage.selected_unit = null


func _on_Cursor_cancel_issued(pos):
	._on_Cursor_cancel_issued(pos)
	if stage.selected_unit == null and stage.get_unit_at(pos) == self:
		die()
		emit_signal("acted", self, "retreated")
	elif stage.selected_unit == self:
		stage.selected_unit = null
