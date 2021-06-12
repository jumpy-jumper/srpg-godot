class_name Follower
extends Unit


export(Array) var deployable_terrain = null
export var cost = 9


func get_type_of_self():
	return UnitType.FOLLOWER


func get_type_of_enemy():
	return UnitType.ENEMY


###############################################################################
#        Main logic                                                           #
###############################################################################


func _process(_delta):
	if (Input.is_action_just_pressed("debug_change_facing")):
		if (stage.get_node("Cursor").position == position):
			facing = int(facing + 90) % 360


func _on_Cursor_confirm_issued(pos):
	._on_Cursor_confirm_issued(pos)
	if stage.selected_unit == self and stage.get_unit_at(pos) == null:
		position = pos
		stage.deselect_unit()


func _on_Cursor_cancel_issued(pos):
	._on_Cursor_cancel_issued(pos)
	if stage.selected_unit == null and stage.get_unit_at(pos) == self:
		die()
	elif stage.selected_unit == self:
		stage.deselect_unit()


###############################################################################
#        Facing logic                                                         #
###############################################################################


enum Facing {RIGHT = 0, DOWN = 90, LEFT = 180, UP = 270}
export(Facing) var facing = Facing.RIGHT


###############################################################################
#        Block logic                                                          #
###############################################################################


var base_block_range = [Vector2(0, -1)]
var is_blocking = [false, false, false, false]


func attempt_block(enemy, pos):
	pass
