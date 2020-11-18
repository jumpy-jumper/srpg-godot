class_name MovementSolver
extends Node2D


const FAINT = 0.2
const NORMAL = 0.4

export(PackedScene) var tile

var hovered = false
var selected = false


func _process(_delta):
	if selected:
		$Tiles.modulate.a = NORMAL
	elif hovered:
		$Tiles.modulate.a = FAINT
	else:
		$Tiles.modulate.a = 0.0


func calculate_movement(unit):
	var parent = $Tiles/MovementTile
	for t in parent.get_children():
		t.queue_free()
	var units = unit.stage.get_all_units()
	var terrain = unit.stage.get_all_terrain()
	#TODO
