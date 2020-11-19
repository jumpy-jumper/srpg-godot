class_name PlayerHUD
extends CanvasLayer


onready var _cursor: Cursor = $"../Cursor"
onready var _hover_panel: Panel = $"Unit Hover Panel"
onready var _hover_panel_name: Label = $"Unit Hover Panel/Unit Name"

func _process(_delta) -> void:
	if _cursor.hovered_unit:
		_hover_panel.visible = true
		_hover_panel_name.text = _cursor.hovered_unit.name
	else:
		_hover_panel.visible = false
