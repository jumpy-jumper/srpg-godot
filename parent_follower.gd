extends Node

onready var parent = $".."
onready var grandparent = $"../.."

export var speed = 10
onready var parent_position = parent.global_position
onready var initial_pos = parent.position

func _process(delta):
	parent_position += (grandparent.position - parent_position) * delta * speed
	parent.global_position = parent_position + initial_pos


func snap():
	parent_position = grandparent.position + initial_pos
