extends Control

const room = preload("res://Scenes/room.tscn")
const grid = preload("res://Scenes/grid.tscn")

var RANDOM_PERCENT = 65

@export var mapSize = Vector2(1,1)
@export var gridCount = Vector2(1,1)
@export var horizontal = false
@export var downhillForVertical = true
@export var pathLoopCount = 2
@export var maxSideRange = 1
@export var shakePosition = 0.01

@onready var map = $Map

var grids = []
var depth = 0
var breadth = 0

func _ready():
	map.size = mapSize
	map.position = get_viewport_rect().get_center() - map.size * 0.5
	make_grid()
	make_path()
	remove_empty_room()
		
func make_grid():
	if horizontal:
		depth = gridCount.x
		breadth = gridCount.y
	else:
		depth = gridCount.y
		breadth = gridCount.x
		
	for i in range(depth):
		grids.append([])
		grids[i] = []
		for j in range(breadth):
			grids[i].append([])
			grids[i][j] = grid.instantiate()
			grids[i][j].set_name("Grid[" + str(i + 1) + ", " + str(j + 1) + "]")
			map.add_child(grids[i][j])
			var roomInstance = room.instantiate()
			grids[i][j].add_child(roomInstance)
			grids[i][j].size = Vector2(map.size.x / gridCount.x, map.size.y / gridCount.y)
			var sprite = roomInstance.get_child(0)
			roomInstance.position = Vector2(grids[i][j].size.x * 0.5 - sprite.size.x * 0.5, grids[i][j].size.y * 0.5 - sprite.size.y * 0.5)
			var rand = [randf_range(-get_viewport_rect().size.x * shakePosition, get_viewport_rect().size.x * shakePosition), randf_range(-get_viewport_rect().size.y * shakePosition, get_viewport_rect().size.y * shakePosition)]
			roomInstance.position += Vector2(rand[0], rand[1])
			if horizontal:
				grids[i][j].position = Vector2(map.size.x / gridCount.x * i, map.size.y / gridCount.y * j)
			else:
				if downhillForVertical:
					grids[i][j].position = Vector2(map.size.x / gridCount.x * j, map.size.y / gridCount.y * i)
				else:
					grids[i][j].position = Vector2(map.size.x / gridCount.x * j, map.size.y - map.size.y / gridCount.y * (i + 1))

func make_path():
	for i in range(pathLoopCount):
		var curRoomIndex = randi_range(0, breadth - 1)
		for j in range(depth - 1):
			var curRoom = get_room(j, curRoomIndex)
			curRoomIndex = randi_range(curRoomIndex - maxSideRange, curRoomIndex + maxSideRange)
			curRoomIndex = clampi(curRoomIndex, 0, breadth - 1)
			curRoom.add_path(get_room(j + 1, curRoomIndex))
	
func remove_empty_room():
	for i in range(depth):
		for j in range(breadth):
			if !get_room(i, j).get_path_count() and get_room(i, j).connected == false:
				get_room(i, j).queue_free()
		

func get_room(x, y):
	return grids[x][y].get_child(0)

func exist_room(x, y):
	return grids[x][y].get_child_count() > 0
