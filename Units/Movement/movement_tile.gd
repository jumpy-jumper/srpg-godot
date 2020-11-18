class_name UnitMovementTile
extends Sprite


enum TileType { FREE, COSTLY, ATTACK }

const COLORS = { TileType.FREE : Color(85.0 / 255, 205.0 / 255, 252.0 / 255), 
	TileType.COSTLY : Color.white, 
	TileType.ATTACK : Color(247.0 / 255, 168.0 / 255, 184.0 / 255),
}

export(TileType) var type = TileType.FREE


func _process(delta):
	modulate = COLORS[type]
