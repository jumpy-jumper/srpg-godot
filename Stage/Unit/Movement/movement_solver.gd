class_name MovementSolver
extends Node2D


const FAINT: float = 0.2
const NORMAL: float = 0.4

export(PackedScene) var tile: PackedScene

var hovered: bool = false
var selected: bool = false

onready var _unit : Unit = get_parent()
onready var _tiles : Node2D = $Tiles

func _process(_delta) -> void:
	if _unit.selected:
		_tiles.modulate.a = NORMAL
	elif hovered:
		_tiles.modulate.a = FAINT
	else:
		_tiles.modulate.a = 0.0


func calculate_movement() -> void:
	for t in _tiles.get_children():
		t.queue_free()
	var units = _unit.stage.get_all_units()
	var terrain = _unit.stage.get_all_terrain()
	#TODO
