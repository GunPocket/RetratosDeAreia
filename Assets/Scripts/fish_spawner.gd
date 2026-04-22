extends Node

#const BG_TERRIBLE
const BG_BAD = preload("uid://cyejr3ftltil2")
const BG_GOOD = preload("res://Assets/Sprites/BGS/tchau seu chico.png")
#const BG_PERFECT

@onready var background: Sprite2D = $"../background"
@onready var spawn_area: Polygon2D = $"../Spawn Area"

var current_animals: Array = []

@export var max_animals := 10
var animals_active := false

const FISH_PARGO: PackedScene = preload("res://Assets/Scenes/pargo.tscn")
const FISH_TARTARUGA: PackedScene = preload("res://Assets/Scenes/tartaruga.tscn")
const BIRD_ALBATROZ: PackedScene = preload("res://Assets/Scenes/albatroz.tscn")
const FISH_ARRAIA: PackedScene = preload("res://Assets/Scenes/arraia.tscn")
const FISH_TUBARAO: PackedScene = preload("res://Assets/Scenes/tubarao_serra.tscn")
const FISH_ERMITAO: PackedScene = preload("res://Assets/Scenes/ermitao.tscn")

var animals_per_day: Dictionary = {
	1: [FISH_PARGO],
	2: [FISH_PARGO, FISH_TARTARUGA],
	3: [FISH_PARGO, FISH_TARTARUGA, BIRD_ALBATROZ],
	4: [FISH_PARGO, FISH_TARTARUGA, BIRD_ALBATROZ, FISH_ARRAIA]
}

func _ready():
	_check_background()
	_start_spawn_animals()

func _check_background() -> void:
	#if EventController.day <= 3:
		#background.texture = BG_BAD
	#else:
		background.texture = BG_GOOD #god is good all the time

func _start_spawn_animals() -> void:
	animals_active = true
	_update_fishes()

func _update_fishes():
	_clean_invalid_animals()
	var available_animals = animals_per_day.get(EventController.day)
	while current_animals.size() < max_animals:
		_spawn_animal_random(available_animals)

func _spawn_animal_random(available_animals: Array):
	var pos = _find_valid_spawn_position()
	var animal_scene = available_animals[randi() % available_animals.size()]
	spawn_animal(animal_scene, pos)

func spawn_animal(animal_scene: PackedScene, position: Vector2):
	var instance = animal_scene.instantiate()
	instance.global_position = position
	add_child(instance)
	current_animals.append(instance)

func _find_valid_spawn_position() -> Vector2:
	var poly := spawn_area.polygon

	if poly.is_empty():
		return get_viewport().get_visible_rect().size / 2

	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	for p in poly:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)

	for i in range(300):
		var local_pos = Vector2(
			randf_range(min_x, max_x),
			randf_range(min_y, max_y)
		)
		if Geometry2D.is_point_in_polygon(local_pos, poly):
			var global_pos = spawn_area.to_global(local_pos)
			return global_pos
	return get_viewport().get_visible_rect().size / 2

func _clean_invalid_animals():
	for i in range(current_animals.size() - 1, -1, -1):
		var a = current_animals[i]
		if not is_instance_valid(a):
			current_animals.remove_at(i)
