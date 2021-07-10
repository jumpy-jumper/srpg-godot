extends Control


signal exited


export var fade_in_duration = 0.25


var saved_unit = null


func _ready():
	modulate.a = 0


func _process(_delta):
	if (Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("unit_ui")) and modulate.a == 1:
		hide()
		emit_signal("exited")


onready var base_sprite_pos = $Sprite.position


func update_unit(unit):
	saved_unit = unit
	if unit.get_type_of_self() == unit.UnitType.FOLLOWER:
		$Sprite.texture = unit.portrait
		$Sprite.position = base_sprite_pos - Vector2(unit.mugshot_top_left.x - 220, unit.mugshot_top_left.y - 45) #220 is dieck's offset which is what i set the default to
	else:
		$Sprite.texture = null

	$Retreat.visible = true
	$"Terrain 1".visible = false
	$"Terrain 2".visible = false
	
	$"Name/Name Label".text = unit.unit_name
	
	
	var basic_stats = ""
	basic_stats += "Level: " + str(unit.get_stat("level", unit.base_level)) + ""
	
	if unit.get_type_of_self() == unit.UnitType.FOLLOWER \
		or unit.get_type_of_self() == unit.UnitType.ENEMY:
			var max_hp = unit.get_stat("max_hp", unit.base_max_hp)
			var base_max_hp = unit.get_stat_after_level("max_hp", unit.base_max_hp)
			basic_stats += "\nHP: " + str(unit.hp)
			if unit.shield > 0:
				basic_stats += " (+" + str(unit.shield) + ")"
			basic_stats += " / " + str(max_hp)
			if base_max_hp != max_hp:
				basic_stats += " (+" if base_max_hp < max_hp else " (-"
				basic_stats += str(abs(base_max_hp - max_hp)) + ")"
			
			var atk = unit.get_stat("atk", unit.base_atk)
			var base_atk = unit.get_stat_after_level("atk", unit.base_atk)
			basic_stats += "\nATK: " + str(atk)
			if base_atk != atk:
				basic_stats += " (" + "+" if base_atk < atk else " (-"
				basic_stats += str(abs(base_atk - atk)) + ")"
			
			var def = unit.get_stat("def", unit.base_def)
			var base_def = unit.get_stat_after_level("def", unit.base_def)
			basic_stats += "\nDEF: " + str(def)
			if base_def != def:
				basic_stats += " (" + "+" if base_def < def else " (-"
				basic_stats += str(abs(base_def - def)) + ")"
			
			var res = unit.get_stat("res", unit.base_res)
			basic_stats += "\nRES: " + str(res)
			if unit.base_res != res:
				basic_stats += " (" + "+" if unit.base_res < res else " (-"
				basic_stats += str(abs(unit.base_res - res)) + ")"
		
	$"Basic Stats/Stats Label".text = basic_stats
	
	
	var other_stats = ""
	
	if unit.get_type_of_self() == unit.UnitType.FOLLOWER or unit.get_type_of_self() == unit.UnitType.ENEMY:
		var base_damage_type = unit.get_node("Skills").get_children()[0].damage_type
		var damage_type = unit.get_stat("damage_type", base_damage_type)
		other_stats += "Damage: " + unit.DamageType.keys()[damage_type]


	if unit.get_type_of_self() == unit.UnitType.FOLLOWER \
		or unit.get_type_of_self() == unit.UnitType.ENEMY:
			var base_target_count = unit.get_node("Skills").get_children()[0].base_target_count
			var target_count = unit.get_stat("target_count", base_target_count)
			if target_count > 129873:
				other_stats += "\nTarget Count: ∞"
			else:
				other_stats += "\nTarget Count: " + str(target_count)
				if base_target_count != target_count:
					other_stats += " (" + "+" if base_target_count < target_count else " (-"
					other_stats += str(abs(base_target_count - target_count)) + ")"
		
			var base_attack_count = unit.get_node("Skills").get_children()[0].base_attack_count
			var attack_count = unit.get_stat("attack_count", unit.get_node("Skills").get_children()[0].base_attack_count)
			if attack_count > 129873:
				other_stats += "\nAttack Count: ∞"
			else:
				other_stats += "\nAttack Count: " + str(attack_count)
				if base_attack_count != attack_count:
					other_stats += " (" + "+" if base_attack_count < attack_count else " (-"
					other_stats += str(abs(base_attack_count - attack_count)) + ")"
					
	if unit.get_type_of_self() == unit.UnitType.FOLLOWER:
		var base_block_count = unit.base_block_count
		var block_count = unit.get_stat("block_count", base_block_count)
		if block_count > 129873:
			other_stats += "\nBlock Count: ∞"
		else:
			other_stats += "\nBlock Count: " + str(block_count)
			if base_block_count != block_count:
				other_stats += " (" + "+" if base_block_count < block_count else " (-"
				other_stats += str(abs(base_block_count - block_count)) + ")"
				
		var base_cooldown = unit.base_cooldown
		var cooldown = unit.get_stat("cooldown", base_cooldown)
		if cooldown > 129873:
			other_stats += "\nResummon CD: ∞"
		else:
			other_stats += "\nResummon CD: " + str(cooldown)
			if base_cooldown != cooldown:
				other_stats += " (" + "+" if base_cooldown < cooldown else " (-"
				other_stats += str(abs(base_cooldown - cooldown)) + ")"
		
		for i in range(min(len(unit.deployable_terrain), 2)):
			var tile = unit.deployable_terrain[i]
			var node = $"Terrain 1" if i == 0 else $"Terrain 2"
			node.visible = true
			node.region_rect.position.x = int(unit.stage.terrain_types.find(tile) * unit.stage.get_cell_size())


	if not unit.alive or unit.get_type_of_self() != unit.UnitType.FOLLOWER:
		$Retreat.visible = false
	if unit.get_type_of_self() == unit.UnitType.ENEMY:
		other_stats += "\nMovement: " + str(unit.get_stat("movement", unit.base_movement))
		other_stats += "\nNext Movement: " + str(unit.movement)
		
	$"Other Stats/Stats Label".text = other_stats
	
	
	var skills = unit.get_node("Skills").get_children()
	
	$"Skill 1".update_skill(skills[0] if len(skills) > 0 else null, unit)
	$"Skill 2".update_skill(skills[1] if len(skills) > 1 else null, unit)


	$"Enemy Panels".visible = false
	
	if unit.get_type_of_self() == unit.UnitType.GATE:
		$"Enemy Panels".visible = true
		var panels = $"Enemy Panels".get_children()
		for i in range(len(panels)):
			if i >= unit.enemies.size():
				panels[i].visible = false
			else:
				panels[i].visible = true
				var key = unit.enemies.keys()[i]
				panels[i].get_node("Label").text = str(key)
				panels[i].get_node("AnimatedSprite").frames = unit.enemies[key].get_node("Sprite").frames


func show():
	$Tween.interpolate_property(self, "modulate:a",
		0, 1, fade_in_duration,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	yield(get_tree(), "idle_frame")
	visible = true
	$Retreat.disabled = false


func hide():
	$Tween.interpolate_property(self, "modulate:a",
		1, 0, fade_in_duration,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	$Retreat.disabled = true
