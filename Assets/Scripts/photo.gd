extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var img_data: PackedByteArray
@export var pos: Vector2 = Vector2.ZERO
@export var fixed: bool = false
@export var score: int = 0

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

func set_score(value: int) -> void:
	score = value

func get_score() -> int:
	return score

func set_fixed(value: bool) -> void:
	fixed = value

func get_fixed() -> bool:
	return fixed

func set_pos(value: Vector2) -> void:
	pos = value
	global_position = value

func get_pos() -> Vector2:
	return pos
