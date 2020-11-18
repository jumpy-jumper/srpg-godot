extends Sprite

class_name UnitMovementTile

enum tile_type { free, costly, attack }
export(tile_type) var type = tile_type.free

const colors = { tile_type.free : Color(85.0 / 255.0, 205.0 / 255.0, 252.0 / 255.0), 
tile_type.costly : Color.white, 
tile_type.attack : Color(247.0 / 255.0, 168.0 / 255.0, 184.0 / 255.0) }

func _process(delta):
	modulate = colors[type]
