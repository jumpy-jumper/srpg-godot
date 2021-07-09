extends Line2D


func update_path(path):
	for i in range(len(path)):
		path[i] -= global_position
	points = PoolVector2Array(path)
