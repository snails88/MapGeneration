extends Control

const room = preload("res://Scenes/room.tscn")
const grid = preload("res://Scenes/grid.tscn")

var RANDOM_PERCENT = 65

@export var mapSize = Vector2(1,1)
@export var depth = Vector2(1,1)
@export var minRoom = 1
@export var maxRoom = 1
@export var horizontal = false
@export var downhillForVertical = true

@onready var map = $Map

var grids = []
var floor = 0
var num = 0

func _ready():
	map.size = mapSize
	map.position = mapSize * -0.5
	make_grid()
	make_room()
		
func make_grid():
	if horizontal:
		floor = depth.x
		num = depth.y
	else:
		floor = depth.y
		num = depth.x
		
	for i in range(floor):
		grids.append([])
		grids[i] = []
		for j in range(num):
			grids[i].append([])
			grids[i][j] = grid.instantiate()
			grids[i][j].set_name("Grid[" + str(i + 1) + ", " + str(j + 1) + "]")
			map.add_child(grids[i][j])
			grids[i][j].size = Vector2(map.size.x / depth.x, map.size.y / depth.y)
			
			if horizontal:
				grids[i][j].position = Vector2(map.size.x / depth.x * i, map.size.y / depth.y * j)
			else:
				if downhillForVertical:
					grids[i][j].position = Vector2(map.size.x / depth.x * j, map.size.y / depth.y * i)
				else:
					grids[i][j].position = Vector2(map.size.x / depth.x * j, map.size.y - map.size.y / depth.y * (i + 1))
			
func make_room():
	var roomCnt = 0
	var loop = 0
	while loop < floor:
		for i in range(num):
			if exist_room(loop,i):
				continue
			var rand = randi_range(0, 100)
			if rand >= RANDOM_PERCENT:
				var roomInstance = room.instantiate()
				grids[loop][i].add_child(roomInstance)
				#포지션 랜덤으로 할거라 일단 매직넘버로 가운데로 두게 해둠
				roomInstance.position = Vector2(grids[loop][i].size.x * 0.5 - 32 * 0.5, grids[loop][i].size.y * 0.5 - 32 * 0.5)
				print(roomInstance.size.x)
				roomCnt += 1
				if roomCnt >= maxRoom:
					break
		if roomCnt >= minRoom:
			loop += 1
			roomCnt = 0
		
	for i in range(floor):
		for j in range(num):
			if !exist_room(i, j):
				grids[i][j].queue_free()

func exist_room(x, y):
	return grids[x][y].get_child_count() > 0
