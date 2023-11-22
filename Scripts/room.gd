extends Control

var nextRoom = []
var connected = false

func _draw():
	var center = self.get_child(0).size * 0.5
	for i in range(nextRoom.size()):
		draw_line(Vector2.ZERO + center, nextRoom[i].global_position - self.global_position + center, Color.WHITE, 5)

func add_path(path):
	if nextRoom.find(path) < 0:
		nextRoom.append(path)
		path.connected = true

func get_path_count():
	return nextRoom.size()
