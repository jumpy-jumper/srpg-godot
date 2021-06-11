extends Node
class_name Status


export(Dictionary) var stat_overwrites = {}
export(Dictionary) var stat_flat_bonuses = {}
export(Dictionary) var stat_additive_multipliers = {}
export(Dictionary) var stat_multiplicative_multipliers = {}

export(Array, int) var movement_overwrite = null
export(Array, int) var movement_flat_bonus = null

export(Array, Vector2) var skill_range_overwrite = null
