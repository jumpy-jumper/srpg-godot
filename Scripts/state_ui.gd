extends Control


onready var stage = $"../.."

export var visible_for = 120
var act_time = visible_for

func _process(_delta):
	visible = act_time < visible_for

	var panels = get_children()
	var idx = 0
	for i in range(stage.cur_state_index - len(panels) / 2, stage.cur_state_index + len(panels) / 2):
		if i >= 0 and i < len(stage.states):
			panels[idx].visible = true
			panels[idx].get_node("Index").text = str(i)
			panels[idx].get_node("Description").text = stage.state_description[i]
			if i == stage.cur_state_index:
				panels[idx].modulate = Color.cyan
			else:
				panels[idx].modulate = Color.white
		else:
			panels[idx].visible = false
		idx += 1

	act_time += 1

func _on_Stage_undo_issued():
	act_time = 0

func _on_Stage_redo_issued():
	act_time = 0
