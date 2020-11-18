extends Node2D

var order = []
var cur_unit = null

func ini_sort(a, b):
	if a.initiative > b.initiative:
		return true
	return false

var cur_round = 0

func start_round():
	cur_round += 1
	print("Round ", cur_round, " start.")
	order = []
	for u in $Units/Ally.get_children() + $Units/Enemy.get_children():
		u.initiative = u.foresight
		u.done = false
		order.append(u)
	order.sort_custom(self, "ini_sort")		
	cur_unit = order[0]
	
func end_round():
	print("Round ", cur_round, " end.")

func next_unit():
	for i in range (len(order)):
		if order[i] == cur_unit:
			if i == len(order) - 1:
				start_round()
			else:
				cur_unit = order[i+1]
			break

func _process(delta):
	# Set units that already acted to "done"
	var found = false
	for u in order:
		if u == cur_unit:
			found = true
		u.done = not found
		
	if not cur_unit:
		start_round()
		print(cur_unit.name, "'s turn.")
		cur_unit.act()
	elif not cur_unit.acting:
		next_unit()
		print(cur_unit.name, "'s turn.")
		cur_unit.act()