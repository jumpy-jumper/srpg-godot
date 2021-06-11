class_name Follower
extends PlayerUnit


export(Array) var deployable_terrain = null
export var cost = 9


###############################################################################
#        Main logic                                                           #
###############################################################################


func _ready():
	yield(get_tree(), "idle_frame")
	if stage:
		update_range()


func _process(_delta):
	if (Input.is_action_just_pressed("debug_change_facing")):
		if (stage.get_node("Cursor").position == position):
			facing = int(facing + 90) % 360
	elif (Input.is_action_just_pressed("debug_activate_skill")):
		if (stage.get_node("Cursor").position == position):
			for skill in $Skills.get_children():
				if skill.activation != skill.Activation.NONE \
					and skill.activation != skill.Activation.TICK:
						if skill.active:
							skill.deactivate()
						else:
							skill.activate()
	if $Range.visible and stage:
		update_range()


func update_range():
	var skill_active = false
	for skill in $Skills.get_children():
		if skill.active:
			skill_active = true
			break
	$Range.update_range($Skills.get_children()[0].get_skill_range(), stage.get_cell_size(), skill_active)


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


func _on_Cursor_hovered(pos):
	$Range.visible = position == pos


###############################################################################
#        Tick and basic action                                                #
###############################################################################


func tick():
	for skill in $Skills.get_children():
		skill.tick()


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


func get_block_range():
	var ret = []
	for r in base_block_range:
		ret.append(r.rotate(deg2rad(facing)))


func attempt_block(enemy, pos):
	pass


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
