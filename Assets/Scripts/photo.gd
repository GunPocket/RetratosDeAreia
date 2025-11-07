extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var img_data: PackedByteArray
@export var pos: Vector2 = Vector2.ZERO
@export var fixed: bool = false
@export var score: int = 0
@export var animals: Array[int] = []

func _ready() -> void:
	add_to_group("foto")

func set_texture(tex: Texture2D) -> void:
	if sprite == null:
		sprite = $Sprite2D
	if collision_shape == null:
		collision_shape = $CollisionShape2D
	if tex == null:
		return
	sprite.texture = tex
	var size = tex.get_size()
	if size != Vector2.ZERO:
		var shape = RectangleShape2D.new()
		shape.extents = size / 2
		collision_shape.shape = shape
		collision_shape.disabled = false

func get_texture() -> Texture2D:
	return sprite.texture if sprite else null
	
func get_score() -> int:
	return score

func get_fixed() -> bool:
	return fixed
	
func get_pos() -> Vector2:
	return pos
	
func get_animals() -> Array[int]:
	return animals

func set_score(value: int) -> void:
	score = value

func set_fixed(value: bool) -> void:
	fixed = value

func set_pos(value: Vector2) -> void:
	pos = value
	global_position = value

func set_animals(values: Array) -> void:
	animals = []
	for v in values:
		if typeof(v) == TYPE_INT:
			animals.append(v)
		elif typeof(v) == TYPE_OBJECT and v is EventController.Animal:
			animals.append(int(v))
