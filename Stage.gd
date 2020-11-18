extends Node

class_name Stage

# There must be a cursor
var cursor
func _ready():
	cursor = $Player/Cursor

# Grid elements getters

const grid_size = 64

func get_unit_at(pos):
	for cat in $Units.get_children():
		for u in cat.get_children():
			if u.position == pos:
				return u
	return null
	
func get_all_units(offset = Vector2()):
	var all = []
	for cat in $Units.get_children():
		for u in cat.get_children():
			all.append(u)
			
	var ret = {}
	for u in all:
		var pos = (u.position - offset) / grid_size
		if ret.has(pos):
			ret[pos].append(u)
		else:
			ret[pos] = [u]
	return ret
	
# Round logic

var order = []
var cur_unit = null	# only null at the beginning of round

# Round flow:
#	1. Creates round order with all non-unconscious units
#	2. Waits for every unit to act once.
#		(checks events after every action)
#	3. Go to 1
func _process(_delta):
	if not cur_unit:
		start_round()
		cur_unit.turn_start()
	elif cur_unit.idle:	# unit finished turn
		cur_unit.on_deselected()
		check_events()
		next_unit()
		cur_unit.turn_start()
		
	if cur_unit.type == Unit.unit_type.ally:
		cursor.selected = cur_unit
		cur_unit.on_selected()
	else:
		cursor.selected = null

func unit_order(a, b):
	if a.initiative > b.initiative:
		return true
	return false

var cur_round = 0

func start_round():
	cur_round += 1
	print("Round ", cur_round, " start.")
	order = []
	for u in $Units/Ally.get_children() + $Units/Enemy.get_children():
		if u.health != Unit.health_levels.unconscious:
			u.initiative = u.stats[Unit.combat_stats.foresight]
			order.append(u)
	order.sort_custom(self, "unit_order")		
	cur_unit = order[0]
	
func end_round():
	print("Round ", cur_round, " end.")

# Events are map conditions that trigger some behavior
func check_events():
	pass

func next_unit():
	for i in range (len(order)):
		if order[i] == cur_unit:
			if i == len(order) - 1:
				end_round()
				start_round()
			else:
				cur_unit = order[i+1]
			break
