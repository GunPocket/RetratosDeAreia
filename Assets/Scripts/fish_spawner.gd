extends Node

const BG_BAD = preload("uid://cyejr3ftltil2")
const BG_GOOD = preload("uid://c0obh5bxgh4fc")

@onready var background: Sprite2D = $"../background"

@onready var spawn_area: Polygon2D = $"../Spawn Area"

var current_animals: Array = []

@export var max_animals := 10
@export var min_distance := 32.0

var animals_active := false

# --- FishData ---
const FISH_PARGO: FishData = preload("res://Assets/Resorces/fish_pargo.tres")
const FISH_TARTARUGA: FishData = preload("res://Assets/Resorces/fish_tartaruga.tres")
const BIRD_ALBATROZ: FishData = preload("res://Assets/Resorces/bird_albatroz.tres")
const FISH_ARRAIA: FishData = preload("res://Assets/Resorces/fish_arraia.tres")

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
	if EventController.day >= 3:
		background.texture = BG_BAD
	else:
		background.texture = BG_GOOD

func _start_spawn_animals() -> void:
	animals_active = true
	_update_fishes()

# --- Spawn de peixes ---
func _update_fishes():
	var available_animals = animals_per_day.get(EventController.day)
	while current_animals.size() < max_animals:
		_spawn_peixe_random(available_animals)

func _spawn_peixe_random(available_animals: Array):
	var pos = get_random_spawn_position()
	var animal = available_animals[randi() % available_animals.size()]
	spawn_peixe(animal, pos)

func spawn_peixe(fish_data: FishData, position: Vector2):
	var instance = fish_data.scene.instantiate()
	add_child(instance)
	instance.global_position = position

	# Aplica escala no AnimatedSprite2D da cena
	var sprite = instance.get_node_or_null("AnimatedSprite2D")
	if sprite:
		sprite.scale = Vector2(fish_data.sprite_scale, fish_data.sprite_scale)

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
			if _posicao_valida(global_pos):
				return global_pos
	return spawn_area.global_position

func _posicao_valida(pos: Vector2) -> bool:
	for animal in current_animals:
		if not is_instance_valid(animal):
			current_animals.erase(animal)
			continue
		if animal.global_position.distance_to(pos) < min_distance:
			return false
	return true
