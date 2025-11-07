extends Node

const BG_BAD = preload("uid://cyejr3ftltil2")
const BG_GOOD = preload("uid://c0obh5bxgh4fc")

@onready var background: Sprite2D = $"../background"
@onready var spawn_area: Polygon2D = $"../Spawn Area"

var current_animals: Array = []

@export var max_animals := 10
@export var min_distance := 32.0
var animals_active := false

const FISH_PARGO: PackedScene = preload("res://Assets/Scenes/pargo.tscn")
const FISH_TARTARUGA: PackedScene = preload("res://Assets/Scenes/tartaruga.tscn")
const BIRD_ALBATROZ: PackedScene = preload("res://Assets/Scenes/albatroz.tscn")
const FISH_ARRAIA: PackedScene = preload("res://Assets/Scenes/arraia.tscn")

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
	if EventController.day <= 3:
		background.texture = BG_BAD
	else:
		background.texture = BG_GOOD

func _start_spawn_animals() -> void:
	animals_active = true
	_update_fishes()

func _update_fishes():
	var available_animals = animals_per_day.get(EventController.day)
	while current_animals.size() < max_animals:
		_spawn_animal_random(available_animals)

func _spawn_animal_random(available_animals: Array):
	var pos = get_random_spawn_position()
	var animal_scene = available_animals[randi() % available_animals.size()]
	spawn_animal(animal_scene, pos)

func spawn_animal(animal_scene: PackedScene, position: Vector2):
	var instance = animal_scene.instantiate()
	add_child(instance)
	instance.global_position = position
	current_animals.append(instance)


func get_random_spawn_position() -> Vector2:
	var poly := spawn_area.polygon
	var rect := Rect2(poly[0], Vector2.ZERO)
	for p in poly:
		rect = rect.expand(p)
	for i in range(50):
		var local_pos = Vector2(
			randf_range(rect.position.x, rect.position.x + rect.size.x),
			randf_range(rect.position.y, rect.position.y + rect.size.y)
		)
		if Geometry2D.is_point_in_polygon(local_pos, poly):
			var global_pos = spawn_area.to_global(local_pos)
			if _position_valid(global_pos):
				return global_pos
	return spawn_area.global_position

func _position_valid(pos: Vector2) -> bool:
	for animal in current_animals:
		if not is_instance_valid(animal):
			current_animals.erase(animal)
			continue
		if animal.global_position.distance_to(pos) < min_distance:
			return false
	return true
