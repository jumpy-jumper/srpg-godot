extends Node


onready var _cursor : Cursor = $Cursor
onready var _hud : PlayerHUD = $"Player HUD"


func _process(delta: float) -> void:
	_hud.cur_unit = _cursor.hovered_unit
	_hud.cur_terrain = _cursor.hovered_terrain
