extends Control

signal room_selected(value)

var nextRoom = []
var connected = false

@onready var button = $Button

func _ready():
	button.disabled = true

func _draw():
	for i in range(nextRoom.size()):
		draw_line(Vector2.ZERO, nextRoom[i].global_position - self.global_position, Color.WHITE, 1)

func add_path(path):
	if nextRoom.find(path) < 0:
		nextRoom.append(path)
		path.connected = true

func get_path_count():
	return nextRoom.size()

func set_selectable(value):
	if value:
		button.disabled = false
	else:
		button.disabled = true

func _on_button_pressed():
	emit_signal("room_selected", self)
