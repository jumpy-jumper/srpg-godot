extends Line2D


export var duration = 0.2

var attacker = null
var attackee = null

var y_step = 0

onready var start = attacker.position + Vector2(attacker.stage.get_cell_size() / 2, attacker.stage.get_cell_size() / 2)
onready var end = attackee.position + Vector2(attackee.stage.get_cell_size() / 2, attackee.stage.get_cell_size() / 2)


func _ready():
	visible = false
	position = Vector2.ZERO
	points[0] = start
	$Tween.interpolate_method(self, "update_p1",
	start, end, duration,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
	yield(get_tree(), "idle_frame")
	visible = true
	
	yield(get_tree().create_timer(duration), "timeout")
	
	$Tween.interpolate_method(self, "update_p0",
	start, end, duration,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
	yield(get_tree().create_timer(duration), "timeout")
	
	queue_free()

func update_p0(pos):
	set_point_position(0, pos)

func update_p1(pos):
	set_point_position(1, pos)
