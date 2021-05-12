extends Node2D


export(PackedScene) var default_tile


func _process(delta: float) -> void:
	#print($Tiles.get_children())
	pass


class MovNode:
	var pos
	var cost
	var prev
	func get_cost():
		return prev.get_cost() + cost


func get_cheapest_path(pos):
	# Rule out any tile that is further away than the unit's initiative + 1
	var diff = (pos - get_parent().position) / get_parent().stage.GRID_SIZE
	diff = abs(diff.x) + abs(diff.y)
	if diff > get_parent().get_ini() + 1:
		return null

	return []


func visualize_movement():
	for t in $Tiles.get_children():
		t.queue_free()
	for t in get_parent().stage.get_node("Terrain").get_children():
		if get_cheapest_path(t.position) != null:
			var new = default_tile.instance()
			$Tiles.add_child(new)
			new.global_position = t.position
