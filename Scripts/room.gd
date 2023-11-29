extends Control

signal room_selected(_value)

var type = ""
var nextRoom = []
var connected = false

@onready var button = $Button

func _ready():
	button.disabled = true

func _draw():
	for i in range(nextRoom.size()):
		draw_line(Vector2.ZERO, nextRoom[i].global_position - self.global_position, Color.WHITE, 1)

func add_path(_path):
	if nextRoom.find(_path) < 0:
		nextRoom.append(_path)
		_path.connected = true

func get_path_count():
	return nextRoom.size()

func set_selectable(_value):
	if _value:
		button.disabled = false
	else:
		button.disabled = true
		
func set_type(_value, _normal, _pressed, _hover, _disabled):
	type = _value
	get_child(0).texture_normal = _normal
	get_child(0).texture_pressed = _pressed
	get_child(0).texture_hover = _hover
	get_child(0).texture_disabled = _disabled
	get_child(0).position = Vector2(-_normal.get_size().x * 0.5, -_normal.get_size().y * 0.5)

func _on_button_pressed():
	emit_signal("room_selected", self)
