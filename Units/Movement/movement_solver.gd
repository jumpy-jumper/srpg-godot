class_name MovementSolver

extends Node2D

export(PackedScene) var tile

const faint_visibility = 0.2
const normal_visibility = 0.4

var hovered = false
var selected = false

func _process(_delta):
	if selected:
		$Tiles.modulate.a = normal_visibility
	elif hovered:
		$Tiles.modulate.a = faint_visibility
	else:
		$Tiles.modulate.a = 0.0

func calculate_movement(unit):
	var parent = $Tiles/MovementTile
	for t in parent.get_children():
		t.queue_free()
	var units = unit.stage.get_all_units()
	var terrain = unit.stage.get_all_terrain()
	#TODO
