extends Line2D


export var duration = 0.2

onready var start = points[0]
onready var end = points[1]

func _ready():	
	$Tween.interpolate_method(self, "update_p1",
	start, end, duration,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
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
