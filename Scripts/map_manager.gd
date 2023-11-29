extends Control

const room = preload("res://Scenes/room.tscn")
const grid = preload("res://Scenes/grid.tscn")

var RANDOM_PERCENT = 65

@export_group("Map Generation")
@export var mapSize = Vector2(1,1)
@export var gridCount = Vector2(1,1)
@export var horizontal = false
@export var downhillForVertical = true
@export var pathLoopCount = 2
@export var maxSideRange = 1
@export var shakePosition = 0.01

@export_subgroup("Boss")
@export var existBoss = true
@export var bossMargin = 0.0

# 종류, 확률
@export_subgroup("Room Type")
@export var type: Array[String]
@export var probability: Array[int]

# 고정할 층, 종류
@export_subgroup("Fixed Room")
@export var floor: Array[int]
@export var roomType: Array[String]

@export_subgroup("Anti Fixed Room")
@export var ignoreFloor: Array[int]
@export var ignoreType: Array[String]

# 방 이미지
@export_subgroup("Room Texture")
@export var normal: Array[Texture2D]
@export var pressed: Array[Texture2D]
@export var hover: Array[Texture2D]
@export var disabled: Array[Texture2D]

@onready var map = $Map

var grids = []
var depth = 0
var breadth = 0
var selectable = false : set = set_selectable
var currentRoom = null
var bossRoom = null

func _ready():
	map.size = mapSize
	map.position = get_viewport_rect().get_center() - map.size * 0.5
	make_grid()
	make_path()
	remove_empty_room()
	set_selectable(true)
	
func select_room(_value):
	set_selectable(false)
	currentRoom = _value
	# 임시로 바로 선택가능하게 해둠
	set_selectable(true)
	
func set_selectable(_value):
	if currentRoom != null:
		for i in range(currentRoom.nextRoom.size()):
			currentRoom.nextRoom[i].set_selectable(_value)
	else:
		for i in range(breadth):
			if exist_room(0, i):
				get_room(0, i).set_selectable(_value)
		
func make_grid():
	var marginX = 0
	var marginY = 0
	if horizontal:
		depth = gridCount.x
		breadth = gridCount.y
		if existBoss:
			gridCount.x += 1
			marginX = bossMargin
	else:
		depth = gridCount.y
		breadth = gridCount.x
		if existBoss:
			gridCount.y += 1
			marginY = bossMargin
		
	for i in range(depth):
		grids.append([])
		grids[i] = []
		for j in range(breadth):
			grids[i].append([])
			grids[i][j] = grid.instantiate()
			grids[i][j].set_name("Grid[" + str(i + 1) + ", " + str(j + 1) + "]")
			map.add_child(grids[i][j])
			var roomInstance = room.instantiate()
			roomInstance.room_selected.connect(select_room)
			select_room_type(i, roomInstance)
			grids[i][j].add_child(roomInstance)
			grids[i][j].size = Vector2((map.size.x - marginX) / gridCount.x, (map.size.y - marginY) / gridCount.y)
			roomInstance.position = Vector2(grids[i][j].size.x * 0.5, grids[i][j].size.y * 0.5)
			var rand = [randf_range(-get_viewport_rect().size.x * shakePosition, get_viewport_rect().size.x * shakePosition), randf_range(-get_viewport_rect().size.y * shakePosition, get_viewport_rect().size.y * shakePosition)]
			roomInstance.position += Vector2(rand[0], rand[1])
			if horizontal:
				grids[i][j].position = Vector2((map.size.x - marginX) / gridCount.x * i, map.size.y / gridCount.y * j)
			else:
				if downhillForVertical:
					grids[i][j].position = Vector2(map.size.x / gridCount.x * j, (map.size.y - marginY) / gridCount.y * i)
				else:
					grids[i][j].position = Vector2(map.size.x / gridCount.x * j, map.size.y - (map.size.y - marginY) / gridCount.y * (i + 1))
		
	if existBoss:
		var bossIndex = -1
		for i in range(type.size()):
			if type[i] == "Boss":
				bossIndex = i
				break

		if bossIndex >= 0:
			bossRoom = room.instantiate()
			bossRoom.set_type("Boss", normal[bossIndex], pressed[bossIndex], hover[bossIndex], disabled[bossIndex])
			bossRoom.room_selected.connect(select_room)
			map.add_child(bossRoom)
			if horizontal:
				bossRoom.position = Vector2(mapSize.x - (mapSize.x / gridCount.x) * 0.5 - (marginX * 0.5), mapSize.y * 0.5)
			else:
				if downhillForVertical:
					bossRoom.position = Vector2(mapSize.x * 0.5, mapSize.y - (mapSize.y / gridCount.y) * 0.5 - (marginY * 0.5))
				else:
					bossRoom.position = Vector2(mapSize.x * 0.5, marginY * 0.5 + (mapSize.y / gridCount.y) * 0.5)

func make_path():
	for i in range(pathLoopCount):
		var curRoomIndex = randi_range(0, breadth - 1)
		for j in range(depth - 1):
			var curRoom = get_room(j, curRoomIndex)
			curRoomIndex = randi_range(curRoomIndex - maxSideRange, curRoomIndex + maxSideRange)
			curRoomIndex = clampi(curRoomIndex, 0, breadth - 1)
			curRoom.add_path(get_room(j + 1, curRoomIndex))
			if j == depth - 2 and existBoss:
				curRoom = get_room(j + 1, curRoomIndex)
				curRoom.add_path(bossRoom)
			
	
func remove_empty_room():
	for i in range(depth):
		for j in range(breadth):
			if !get_room(i, j).get_path_count() and get_room(i, j).connected == false:
				get_room(i, j).queue_free()
		

func select_room_type(_depth, _instance):
	for i in range(floor.size()):
		if floor[i] == _depth + 1:
			var texIndex = 0
			for j in range(type.size()):
				if type[j] == roomType[i]:
					texIndex = j
					break
			_instance.set_type(roomType[i], normal[texIndex], pressed[texIndex], hover[texIndex], disabled[texIndex])
			return
	
	var totalP = 0
	for i in range(probability.size()):
		totalP += probability[i]
	
	for i in range(ignoreFloor.size()):
		if _depth + 1 == ignoreFloor[i]:
			for j in range(type.size()):
				if ignoreFloor[i] == _depth + 1 and ignoreType[i] == type[j]:
					totalP -= probability[j]
					break
	
	var rand = randi_range(0, totalP)
	for i in range(probability.size()):
		var ignore = false
		for j in range(ignoreFloor.size()):
			if _depth + 1 == ignoreFloor[j]:
				if ignoreFloor[j] == _depth + 1 and ignoreType[j] == type[i]:
					ignore = true
		if ignore:
			continue
		if rand <= probability[i]:
			_instance.set_type(type[i], normal[i], pressed[i], hover[i], disabled[i])
			return
		else:
			rand -= probability[i]

func get_room(_x, _y):
	return grids[_x][_y].get_child(0)

func exist_room(_x, _y):
	return grids[_x][_y].get_child_count() > 0
