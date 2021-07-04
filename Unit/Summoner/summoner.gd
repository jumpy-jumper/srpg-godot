class_name Summoner
extends Unit


export(Array, Resource) var followers = []


func get_type_of_self():
	return UnitType.SUMMONER


###############################################################################
#        Stats logic                                                          #
###############################################################################


export var base_max_faith = 99
export (int) var faith = 20


###############################################################################
#        Main logic                                                           #
###############################################################################


func _on_Cursor_confirm_issued(pos):
	._on_Cursor_confirm_issued(pos)
	if stage.selected_unit == self:
		if stage.get_unit_at(pos) == null:		
			var unit = followers[randi() % len(followers)].instance()
			if stage.get_terrain_at(pos) in unit.deployable_terrain:
				stage.add_unit(unit, stage.get_node("Cursor").position)
				faith -= unit.cost
				stage.deselect_unit()
	elif pos == position:
		stage.select_unit(self)


func _on_Cursor_cancel_issued(pos):
	._on_Cursor_cancel_issued(pos)
	if stage.selected_unit == self:
		stage.deselect_unit()


###############################################################################
#        Combat logic                                                         #
###############################################################################


func take_damage(amount = 1, damage_type = DamageType.PHYSICAL):
	hp -= 1
	if hp <= 0:
		die()


func die():
	emit_signal("dead", self)
