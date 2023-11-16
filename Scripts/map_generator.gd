extends Control

const room = preload("res://Scenes/room.tscn")
const grid = preload("res://Scenes/grid.tscn")

var RANDOM_PERCENT = 65

@export var mapSize = Vector2(1,1)
@export var depth = Vector2(1,1)
@export var minRoom = 1
@export var maxRoom = 1

@onready var map = $Map

var grids = []

func _ready():
	map.size = mapSize
	map.position = mapSize * -0.5
	make_grid()
	make_room()
		
func make_grid():
	for i in range(depth.y):
		grids.append([])
		grids[i] = []
		for j in range(depth.x):
			grids[i].append([])
			grids[i][j] = grid.instantiate()
			grids[i][j].set_name("Grid[" + str(i + 1) + ", " + str(j + 1) + "]")
			map.add_child(grids[i][j])
			grids[i][j].get_child(0).size = Vector2(map.size.x / depth.x, map.size.y / depth.y)
			grids[i][j].position = Vector2(map.size.x / depth.x * j, map.size.y / depth.y * i)
			
func make_room():
	var roomCnt = 0
	var loop = 0
	while loop < depth.y:
		for i in range(depth.x):
			if exist_room(loop,i):
				continue
			var rand = randi_range(0, 100)
			if rand >= RANDOM_PERCENT:
				var roomInstance = room.instantiate()
				grids[loop][i].get_child(0).add_child(roomInstance)
				roomCnt += 1
				if roomCnt >= maxRoom:
					break
		if roomCnt >= minRoom:
			loop += 1
			roomCnt = 0
		
	for i in range(depth.y):
		for j in range(depth.x):
			if !exist_room(i, j):
				grids[i][j].queue_free()

func exist_room(x, y):
	return grids[x][y].get_child(0).get_child_count() > 0
