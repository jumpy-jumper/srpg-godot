extends CanvasLayer


var cur_unit: Unit = null

onready var _hover_panel: Panel = $"Unit Hover Panel"
onready var _hover_panel_name: Label = $"Unit Hover Panel/Unit Name"

func _process(_delta) -> void:
	if cur_unit:
		_hover_panel.visible = true
		_hover_panel_name.text = cur_unit.name
	else:
		_hover_panel.visible = false
