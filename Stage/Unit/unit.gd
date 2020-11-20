class_name Unit
extends Node2D

signal done()

enum UnitType { ALLY, ENEMY, NEUTRAL }
enum HealthLevels { HEALTHY, WOUNDED, CRIPPLED, UNCONSCIOUS }
enum CombatStats { STR, END, AGI, INT, PER, FOR }

export(String) var unit_name: String = ""
export(HealthLevels) var health: int = HealthLevels.HEALTHY
export(Dictionary) var stats: Dictionary = {
	CombatStats.STR : 0,
	CombatStats.END : 0,
	CombatStats.AGI : 0,
	CombatStats.INT : 0,
	CombatStats.PER : 0,
	CombatStats.FOR : 0,
}

var type: int = UnitType.ENEMY
var ini: int = 0
var ini_base: int = 0
var ini_bonus: int = 0

var _greenlit = false


func _enter_tree() -> void:
	pass


func _process(delta: float) -> void:
	$"Sprite".animation = "blue_idle" if type == UnitType.ALLY else "red_idle"
	_update_ui()


func _update_ui() -> void:
	# Update initiative label
	if ini > 0:
		if ini_bonus > 0:
			$"Initiative".modulate = Color.lightgreen
		else:
			$"Initiative".modulate = Color.white
	else:
		$"Initiative".modulate = Color.deeppink

	$"Initiative".text = str(ini) if ini > 0 else "í ½í»‡í ½í»‡í ½í»‡-"

	# Update health label
	match health:
		HealthLevels.HEALTHY:
			$"Health".text = ""
		HealthLevels.WOUNDED:
			$"Health".text = "-1"
			$"Health".modulate = Color.deeppink
		HealthLevels.CRIPPLED:
			$"Health".text = "-2"
			$"Health".modulate = Color.red
		HealthLevels.UNCONSCIOUS:
			$"Health".text = "-3"
			$"Health".modulate = Color.crimson


func _on_Stage_unit_greenlit(unit: Unit) -> void:
	_greenlit = unit == self


func _on_Stage_unit_clicked(unit: Unit) -> void:
	if _greenlit and unit == self:
		emit_signal("done")
