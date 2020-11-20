class_name Weapon
extends Node

export(String) var weapon_name: String = ""
export(int) var might: int = 0
export(int) var weight: int = 0
export(Unit.CombatStats) var main_stat: int = Unit.CombatStats.STR
