class_name MovementTile
extends Sprite


enum TileType { FREE, COSTLY, ATTACK }

const COLORS: Dictionary = { 
	TileType.FREE : Color(85.0 / 255, 205.0 / 255, 252.0 / 255), 
	TileType.COSTLY : Color.white, 
	TileType.ATTACK : Color(247.0 / 255, 168.0 / 255, 184.0 / 255),
}

export(TileType) var type: int = TileType.FREE


func _process(_delta: float) -> void:
	modulate = COLORS[type]
